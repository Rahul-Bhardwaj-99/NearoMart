import 'package:flutter/material.dart';
import '../../core/values/app_assets.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final double? borderRadius;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size,
    this.borderRadius,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        child: Image.asset(
          AppAssets.appIcon,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
