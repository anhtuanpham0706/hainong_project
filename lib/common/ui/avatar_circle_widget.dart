import 'package:flutter/material.dart';
import '../util/util.dart';

class AvatarCircleWidget extends StatefulWidget {
  final String link, assetsImageReplace;
  final double? size;
  final Border? border;
  final bool stack;

  const AvatarCircleWidget({this.link = '', this.stack = false, this.size, this.border,
      this.assetsImageReplace = 'assets/images/v2/ic_avatar_drawer_v2.png', Key? key}):super(key:key);

  @override
  _AvatarCircleWidgetState createState() => _AvatarCircleWidgetState();
}

class _AvatarCircleWidgetState extends State<AvatarCircleWidget> {
  bool isError = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.size??0);
    final error = Image.asset(widget.assetsImageReplace, width: widget.size, height: widget.size, fit: BoxFit.fill);
    if (widget.link.isEmpty || isError) return ClipRRect(child: error, borderRadius: radius);

    final child = ClipRRect(child: FadeInImage.assetNetwork(placeholder: widget.assetsImageReplace, width: widget.size, height: widget.size,
        image: Util.getRealPath(widget.link), fit: BoxFit.cover,
        imageScale: 0.5, imageErrorBuilder: (context, obj, track) {
          isError = true;
          return error;
        }), borderRadius: radius
    );
    if (widget.stack && widget.border != null && !isError) {
      return Stack(children: [
        child,
        Container(width: widget.size, height: widget.size, decoration: BoxDecoration(
              borderRadius: radius, border: widget.border))
      ]);
    }
    if (!widget.stack && widget.border != null && !isError) {
      return Container(width: widget.size, height: widget.size, decoration: BoxDecoration(
          borderRadius: radius, border: widget.border), child: child);
    }
    return isError || widget.link.isEmpty ? ClipRRect(child: error, borderRadius: radius) : child;
  }
}
