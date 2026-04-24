import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps a child with a staggered fade + slide-up entrance animation.
///
/// [index] controls the stagger delay so items in a list appear sequentially.
class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 350),
  });

  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          duration: duration,
          delay: baseDelay * index,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.08,
          end: 0,
          duration: duration,
          delay: baseDelay * index,
          curve: Curves.easeOutCubic,
        );
  }
}
