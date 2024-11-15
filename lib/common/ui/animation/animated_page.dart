import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'base_scroll_effect.dart';
import 'enums.dart';
import 'scale_effect.dart';

class AnimatedPage extends StatefulWidget {
  /// Page controller
  final PageController controller;

  /// Index of the page
  final int index;

  /// Page-view page widget
  final Widget child;

  /// Animated page scroll effect
  final ScrollEffect effect;

  /// Use this to build your PageView pages and apply [effect]
  const AnimatedPage(
      {Key? key, required this.controller,
        required this.index,
        required this.child,
        this.effect = const ScaleEffect(),
        }) : super(key: key);

  @override
  State<AnimatedPage> createState() => _AnimatedPageState();
}

class _AnimatedPageState extends State<AnimatedPage> {
  double _pagePosition = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.controller.position.haveDimensions) {
      widget.controller.addListener(_listener);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  _listener() {
    if (mounted) {
      setState(() {
        _pagePosition =
        num.parse(widget.controller.page!.toStringAsFixed(4)) as double;
      });
    }
  }

  AnimationScrollDirection get _scrollDirection {
    if (widget.controller.position.userScrollDirection ==
        ScrollDirection.reverse) {
      return AnimationScrollDirection.forward;
    }
    return AnimationScrollDirection.reverse;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) => widget.effect.buildEffect(
            child: widget.child,
            index: widget.index,
            position: _pagePosition,
            direction: _scrollDirection));
  }
}