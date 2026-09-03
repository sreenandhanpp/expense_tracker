import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/date_formatter.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<double> dailyTotals;
  final double maxY;
  final int? selectedIndex;
  final ValueChanged<int>? onDayTap;

  const WeeklyBarChart({
    super.key,
    required this.dailyTotals,
    this.maxY = 80.0,
    this.selectedIndex,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    double currentMax = maxY;
    for (var val in dailyTotals) {
      if (val > currentMax) {
        currentMax = (val / 20).ceil() * 20.0;
      }
    }

    final ySteps = [currentMax, currentMax * 0.75, currentMax * 0.5, currentMax * 0.25, 0.0];

    return Container(
      height: 180,
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background grid lines and right side Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ySteps.map((stepVal) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.divider.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 24,
                          child: Text(
                            stepVal.toInt().toString(),
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),

                // Vertical Bars
                Padding(
                  padding: const EdgeInsets.only(right: 32.0, top: 6, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final isSelected = selectedIndex == index;
                      final val = index < dailyTotals.length ? dailyTotals[index] : 0.0;
                      final double heightFactor = (currentMax > 0) ? (val / currentMax).clamp(0.0, 1.0) : 0.0;

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final barHeight = constraints.maxHeight * heightFactor;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onDayTap?.call(index),
                            child: SizedBox(
                              width: 36,
                              height: constraints.maxHeight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Subtle selection dot indicator at top of bar column if selected
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: isSelected ? 1.0 : 0.0,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.textPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    width: 22,
                                    height: val > 0
                                        ? barHeight.clamp(6.0, constraints.maxHeight - 8)
                                        : (isSelected ? 4.0 : 0.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.textPrimary
                                          : AppColors.textPrimary.withValues(alpha: 0.85),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                        bottom: Radius.circular(1),
                                      ),
                                      border: isSelected
                                          ? Border.all(color: AppColors.textPrimary, width: 1.5)
                                          : null,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.15),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // X-Axis Day Labels
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onDayTap?.call(index),
                  child: SizedBox(
                    width: 36,
                    child: Text(
                      DateFormatter.getWeekdayAbbr(index),
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
