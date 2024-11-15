import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hainong/features/cart/cart_bloc.dart';
import '../base_bloc.dart';

typedef void OnWidgetSizeChange(Size size);

/// [MeasuredSize] Calculated the size of it's child in runtime.
/// Simply wrap your widget with [MeasuredSize] and listen to size changes with [onChange].
class MeasuredSize extends StatefulWidget {
  /// Widget to calculate it's size.
  final Widget child;

  /// [onChange] will be called when the [Size] changes.
  /// [onChange] will return the value ONLY once if it didn't change, and it will NOT return a value if it's equals to [Size.zero]
  final OnWidgetSizeChange onChange;

  const MeasuredSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  _MeasuredSizeState createState() => _MeasuredSizeState();
}

class _MeasuredSizeState extends State<MeasuredSize> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) async {
    var context = widgetKey.currentContext!;
    await Future.delayed(const Duration(milliseconds: 200)); // wait till the image is drawn
    Size newSize = context.size!;
    if (newSize == Size.zero) return;
    if (oldSize == newSize) return;
    oldSize = newSize;
    widget.onChange(newSize);
  }
}

class SpaceCartOrder extends StatelessWidget {
  final BaseBloc? bloc;
  final String type;
  const SpaceCartOrder(this.bloc, this.type, {Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) => BlocBuilder(bloc: bloc,
    buildWhen: (oldS, newS) => newS is ChangeSizeState,
    builder: (context, state) {
      double? width;
      if (state is ChangeSizeState) {
        switch(type) {
          case 'total': width = state.total; break;
          case 'dis': width = state.dis; break;
          case 'pay': width = state.pay;
        }
      }
      return SizedBox(width: width);
    }
  );
}