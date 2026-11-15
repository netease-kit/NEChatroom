import 'package:flutter/material.dart';

class AssetImageOr extends StatelessWidget {
  const AssetImageOr({super.key, required this.path, required this.fallback, this.fit = BoxFit.cover, this.borderRadius});
  final String path;
  final Widget fallback;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(path, fit: fit, errorBuilder: (_, __, ___) => fallback),
    );
  }
}
