import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';

class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: _animation.value * 0.3),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class SpendingSummaryCardSkeleton extends StatelessWidget {
  const SpendingSummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 110, height: 14, borderRadius: 4),
          const SizedBox(height: 10),
          const SkeletonBox(width: 140, height: 32, borderRadius: 6),
          const SizedBox(height: 24),

          // Skeleton Bars
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final heights = [50.0, 80.0, 30.0, 100.0, 60.0, 40.0, 70.0];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SkeletonBox(width: 22, height: heights[index], borderRadius: 4),
                    const SizedBox(height: 12),
                    const SkeletonBox(width: 24, height: 10, borderRadius: 3),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseTileSkeleton extends StatelessWidget {
  const ExpenseTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          SkeletonBox(width: 40, height: 40, borderRadius: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 100, height: 14, borderRadius: 4),
              SizedBox(height: 6),
              SkeletonBox(width: 60, height: 10, borderRadius: 3),
            ],
          ),
          Spacer(),
          SkeletonBox(width: 60, height: 16, borderRadius: 4),
        ],
      ),
    );
  }
}

class ExpenseGroupSkeleton extends StatelessWidget {
  final int itemCount;

  const ExpenseGroupSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: SkeletonBox(width: 80, height: 12, borderRadius: 3),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(itemCount, (index) {
              final isLast = index == itemCount - 1;
              return Column(
                children: [
                  const ExpenseTileSkeleton(),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.divider,
                    ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class InsightCardSkeleton extends StatelessWidget {
  const InsightCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          SkeletonBox(width: 90, height: 14, borderRadius: 4),
          SizedBox(height: 12),
          SkeletonBox(width: 130, height: 32, borderRadius: 6),
        ],
      ),
    );
  }
}
