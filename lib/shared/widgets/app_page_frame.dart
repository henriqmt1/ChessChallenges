import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';

/// Keeps page width, safe area and scrolling behavior consistent.
class AppPageFrame extends StatelessWidget {
  const AppPageFrame({
    super.key,
    this.slivers,
    this.sliverBuilder,
    this.scrollKey,
    this.physics = const AlwaysScrollableScrollPhysics(),
  }) : assert(
         (slivers == null) != (sliverBuilder == null),
         'Provide either slivers or sliverBuilder.',
       );

  final List<Widget>? slivers;
  final List<Widget> Function(BuildContext context, BoxConstraints constraints)?
  sliverBuilder;
  final Key? scrollKey;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth
              .clamp(0, AppSizes.contentMaxWidth)
              .toDouble();

          return Center(
            child: SizedBox(
              width: maxWidth,
              child: CustomScrollView(
                key: scrollKey,
                physics: physics,
                slivers: sliverBuilder?.call(context, constraints) ?? slivers!,
              ),
            ),
          );
        },
      ),
    );
  }
}
