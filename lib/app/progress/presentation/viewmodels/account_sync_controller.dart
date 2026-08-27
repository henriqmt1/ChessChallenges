import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../data/remote_player_progress_repository.dart';
import 'player_progress_controller.dart';

final accountSyncControllerProvider =
    NotifierProvider<AccountSyncController, AccountSyncState>(
      AccountSyncController.new,
    );

class AccountSyncController extends Notifier<AccountSyncState> {
  StreamSubscription<User?>? _authSubscription;
  FirebaseAuth? _auth;

  static Future<void>? _googleInitializeFuture;

  @override
  AccountSyncState build() {
    _auth = ref.watch(firebaseAuthProvider);
    ref.onDispose(() => _authSubscription?.cancel());

    final auth = _auth;
    if (auth == null) {
      return const AccountSyncState(firebaseAvailable: false);
    }

    _authSubscription = auth.authStateChanges().listen((user) {
      if (!ref.mounted) {
        return;
      }

      state = AccountSyncState.fromUser(
        user,
        firebaseAvailable: true,
      ).copyWith(isBusy: state.isBusy);
    });

    return AccountSyncState.fromUser(auth.currentUser, firebaseAvailable: true);
  }

  Future<void> syncNow() async {
    await _runBusyAction(() async {
      await _ensureUser();
      await ref.read(playerProgressControllerProvider.notifier).refreshRemote();
    });
  }

  Future<void> linkGoogle() async {
    await _runBusyAction(() async {
      final auth = _requireAuth();
      await _initializeGoogle();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw const AccountSyncException(
          AccountSyncError.googleConfigurationMissing,
        );
      }

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AccountSyncException(
          AccountSyncError.googleConfigurationMissing,
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _linkOrSignIn(auth, credential);
      await ref.read(playerProgressControllerProvider.notifier).refreshRemote();
    });
  }

  Future<void> linkApple() async {
    await _runBusyAction(() async {
      final auth = _requireAuth();
      final available = await SignInWithApple.isAvailable();
      if (!available) {
        throw const AccountSyncException(AccountSyncError.appleUnavailable);
      }

      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = appleCredential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AccountSyncException(AccountSyncError.appleUnavailable);
      }

      final credential = OAuthProvider(
        'apple.com',
      ).credential(idToken: idToken, rawNonce: rawNonce);
      await _linkOrSignIn(auth, credential);
      await ref.read(playerProgressControllerProvider.notifier).refreshRemote();
    });
  }

  Future<void> _runBusyAction(Future<void> Function() action) async {
    if (state.isBusy) {
      return;
    }

    state = state.copyWith(isBusy: true);
    try {
      await action();
      state = AccountSyncState.fromUser(
        _auth?.currentUser,
        firebaseAvailable: _auth != null,
      );
    } on AccountSyncException {
      state = state.copyWith(isBusy: false);
      rethrow;
    } on FirebaseAuthException catch (error) {
      state = state.copyWith(isBusy: false);
      throw AccountSyncException.fromFirebase(error);
    } on GoogleSignInException catch (error) {
      state = state.copyWith(isBusy: false);
      throw AccountSyncException.fromGoogle(error);
    } on SignInWithAppleAuthorizationException {
      state = state.copyWith(isBusy: false);
      throw const AccountSyncException(AccountSyncError.canceled);
    } on SignInWithAppleException {
      state = state.copyWith(isBusy: false);
      throw const AccountSyncException(AccountSyncError.appleUnavailable);
    } on Object {
      state = state.copyWith(isBusy: false);
      throw const AccountSyncException(AccountSyncError.generic);
    }
  }

  Future<User?> _ensureUser() async {
    final auth = _requireAuth();
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      return currentUser;
    }

    final credential = await auth.signInAnonymously();
    return credential.user;
  }

  FirebaseAuth _requireAuth() {
    final auth = _auth;
    if (auth == null) {
      throw const AccountSyncException(AccountSyncError.firebaseUnavailable);
    }

    return auth;
  }

  Future<void> _linkOrSignIn(
    FirebaseAuth auth,
    AuthCredential credential,
  ) async {
    final user = await _ensureUser();
    if (user == null) {
      throw const AccountSyncException(AccountSyncError.firebaseUnavailable);
    }

    try {
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'provider-already-linked') {
        return;
      }
      if (error.code == 'credential-already-in-use' ||
          error.code == 'account-exists-with-different-credential') {
        await auth.signInWithCredential(credential);
        return;
      }

      rethrow;
    }
  }

  Future<void> _initializeGoogle() {
    final future = _googleInitializeFuture;
    if (future != null) {
      return future;
    }

    final nextFuture = GoogleSignIn.instance.initialize().catchError((error) {
      _googleInitializeFuture = null;
      throw error;
    });
    _googleInitializeFuture = nextFuture;
    return nextFuture;
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();

    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}

class AccountSyncState {
  const AccountSyncState({
    required this.firebaseAvailable,
    this.isBusy = false,
    this.isAnonymous = true,
    this.email,
    this.displayName,
    this.providerId,
  });

  factory AccountSyncState.fromUser(
    User? user, {
    required bool firebaseAvailable,
  }) {
    final providers = user?.providerData ?? const <UserInfo>[];
    final primaryProvider = providers.isEmpty ? null : providers.first;

    return AccountSyncState(
      firebaseAvailable: firebaseAvailable,
      isAnonymous: user?.isAnonymous ?? true,
      email: user?.email ?? primaryProvider?.email,
      displayName: user?.displayName ?? primaryProvider?.displayName,
      providerId: primaryProvider?.providerId,
    );
  }

  final bool firebaseAvailable;
  final bool isBusy;
  final bool isAnonymous;
  final String? email;
  final String? displayName;
  final String? providerId;

  bool get isLinked => firebaseAvailable && !isAnonymous;

  String? get accountLabel {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final accountEmail = email?.trim();
    if (accountEmail != null && accountEmail.isNotEmpty) {
      return accountEmail;
    }

    return null;
  }

  AccountSyncState copyWith({bool? isBusy}) {
    return AccountSyncState(
      firebaseAvailable: firebaseAvailable,
      isBusy: isBusy ?? this.isBusy,
      isAnonymous: isAnonymous,
      email: email,
      displayName: displayName,
      providerId: providerId,
    );
  }
}

class AccountSyncException implements Exception {
  const AccountSyncException(this.error);

  factory AccountSyncException.fromFirebase(FirebaseAuthException error) {
    return switch (error.code) {
      'network-request-failed' => const AccountSyncException(
        AccountSyncError.network,
      ),
      'credential-already-in-use' ||
      'account-exists-with-different-credential' => const AccountSyncException(
        AccountSyncError.accountAlreadyExists,
      ),
      'operation-not-allowed' => const AccountSyncException(
        AccountSyncError.providerDisabled,
      ),
      _ => const AccountSyncException(AccountSyncError.generic),
    };
  }

  factory AccountSyncException.fromGoogle(GoogleSignInException error) {
    final codeName = error.code.name;
    if (codeName == 'canceled' || codeName == 'interrupted') {
      return const AccountSyncException(AccountSyncError.canceled);
    }

    return const AccountSyncException(
      AccountSyncError.googleConfigurationMissing,
    );
  }

  final AccountSyncError error;
}

enum AccountSyncError {
  firebaseUnavailable,
  googleConfigurationMissing,
  appleUnavailable,
  providerDisabled,
  accountAlreadyExists,
  network,
  canceled,
  generic,
}
