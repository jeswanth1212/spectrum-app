import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;
  final Border? border;

  const GlassMorphism({
    Key? key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.2,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.glassColor.withOpacity(opacity),
            borderRadius: borderRadius,
            border: border ?? Border.all(
              color: AppTheme.glassBorderColor,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Preset glass morphism styles for common use cases
class GlassMorphismPresets {
  // Card style with glassmorphism effect
  static Widget card({
    required Widget child,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return GlassMorphism(
      borderRadius: borderRadius,
      blur: 10,
      opacity: 0.1,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
  
  // Button style with glassmorphism effect
  static Widget button({
    required Widget child,
    required VoidCallback onPressed,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: borderRadius,
      child: GlassMorphism(
        borderRadius: borderRadius,
        blur: 5,
        opacity: 0.2,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
  
  // AppBar style with glassmorphism effect
  static PreferredSizeWidget appBar({
    required String title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    double height = kToolbarHeight,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: GlassMorphism(
        blur: 10,
        opacity: 0.1,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(
          color: AppTheme.glassBorderColor,
          width: 0.5,
        ),
        child: AppBar(
          title: Text(title),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: actions,
          bottom: bottom,
        ),
      ),
    );
  }
} 