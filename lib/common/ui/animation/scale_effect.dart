// Copyright 2023 Conezi. All rights reserved.

import 'base_scroll_effect.dart';
import 'enums.dart';
import 'package:flutter/material.dart';

class ScaleEffect extends ScrollEffect {
  /// Scale effect vertically
  final double verticalScale;

  /// Scale effect horizontally
  final double horizontalScale;

  /// Snap back to original size when not scrolling
  /// Only effective on the [AnimatedItem]
  final bool snap;

  /// The alignment of the origin, relative to the size of the child.
  final AlignmentGeometry alignment;

  /// Animation type
  final AnimationType type;
  const ScaleEffect(
      {this.verticalScale = 0.0,
      this.horizontalScale = 0.0,
      this.snap = true,
      this.alignment = Alignment.center,
      this.type = AnimationType.always})
      : assert(verticalScale >= 0.0),
        assert(horizontalScale >= 0.0);

  @override
  Widget buildEffect(
      {required Widget child,
      required int index,
      required double position,
      double? itemWidth,
      double? itemHeight,
      bool? isScrolling,
      required AnimationScrollDirection direction}) {
    double delta = index - position;
    if (isStatic(delta, type, direction, snap, isScrolling)) {
      return child;
    }
    delta = delta.abs();
    double verticalScale = 1.0 - delta * this.verticalScale;
    double horizontalScale = 1.0 - delta * this.horizontalScale;
    return Transform(
      transform: Matrix4.identity()..scale(horizontalScale, verticalScale),
      alignment: alignment,
      child: child,
    );
  }
}
