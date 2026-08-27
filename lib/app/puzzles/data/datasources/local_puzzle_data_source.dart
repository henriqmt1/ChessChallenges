import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/puzzle_model.dart';

class LocalPuzzleDataSource {
  const LocalPuzzleDataSource();

  Future<List<PuzzleModel>> loadDemoPuzzles() async {
    final payload = await rootBundle.loadString(
      'assets/puzzles/campaign_v1.json',
    );
    final json = jsonDecode(payload) as Map<String, dynamic>;
    final puzzles = json['puzzles'] as List;

    return puzzles
        .map((entry) => PuzzleModel.fromJson(entry as Map<String, dynamic>))
        .toList(growable: false);
  }
}
