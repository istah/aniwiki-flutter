import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  const SkeletonBox({super.key, this.height = 160});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(height: height, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white)),
    );
  }
}