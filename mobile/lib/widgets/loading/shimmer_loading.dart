/// Shimmer loading widget
///
/// Content skeleton with shimmer effect

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  const ShimmerLoading.rectangular({
    super.key,
    required this.width,
    required this.height,
  }) : borderRadius = null;

  const ShimmerLoading.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ??
              (width == height
                  ? BorderRadius.circular(width / 2)
                  : BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

/// Card shimmer loading
class CardShimmerLoading extends StatelessWidget {
  const CardShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerLoading(width: 150, height: 20),
            const SizedBox(height: 8),
            const ShimmerLoading(width: double.infinity, height: 16),
            const SizedBox(height: 4),
            const ShimmerLoading(width: double.infinity, height: 16),
            const SizedBox(height: 4),
            ShimmerLoading(width: MediaQuery.of(context).size.width * 0.6, height: 16),
          ],
        ),
      ),
    );
  }
}
