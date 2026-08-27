import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/campaign_level_node.dart';
import 'campaign_level_button.dart';

class CampaignPath extends StatelessWidget {
  const CampaignPath({super.key, required this.nodes, required this.onNodeTap});

  final List<CampaignLevelNode> nodes;
  final ValueChanged<CampaignLevelNode> onNodeTap;

  @override
  Widget build(BuildContext context) {
    const verticalGap = AppSizes.campaignPathGap;
    const topPadding = 44.0;
    const horizontalTravel = 78.0;
    final height = topPadding + ((nodes.length - 1) * verticalGap) + 92;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centerX = constraints.maxWidth / 2;
          final positions = [
            for (var index = 0; index < nodes.length; index++)
              Offset(
                centerX + (nodes[index].xOffset * horizontalTravel),
                topPadding + (index * verticalGap),
              ),
          ];

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CampaignPathPainter(
                    positions: positions,
                    nodes: nodes,
                    lockedColor: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              for (var index = 0; index < nodes.length; index++)
                Positioned(
                  left: positions[index].dx - 36,
                  top: positions[index].dy - 36,
                  child: CampaignLevelButton(
                    node: nodes[index],
                    onTap: () => onNodeTap(nodes[index]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CampaignPathPainter extends CustomPainter {
  const _CampaignPathPainter({
    required this.positions,
    required this.nodes,
    required this.lockedColor,
  });

  final List<Offset> positions;
  final List<CampaignLevelNode> nodes;
  final Color lockedColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) {
      return;
    }

    for (var index = 0; index < positions.length - 1; index++) {
      final from = positions[index];
      final to = positions[index + 1];
      final completed =
          nodes[index].status == CampaignLevelNodeStatus.completed;

      final paint = Paint()
        ..color = completed ? AppColors.success : lockedColor
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final controlY = (from.dy + to.dy) / 2;
      final path = Path()
        ..moveTo(from.dx, from.dy + 36)
        ..cubicTo(from.dx, controlY, to.dx, controlY, to.dx, to.dy - 36);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CampaignPathPainter oldDelegate) {
    return oldDelegate.positions != positions ||
        oldDelegate.nodes != nodes ||
        oldDelegate.lockedColor != lockedColor;
  }
}
