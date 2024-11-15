import 'box_dec_custom.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class ContentShadow extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin, padding;
  final double? width, top, radius;
  const ContentShadow(this.child, {this.radius, this.width, this.top, this.margin, this.padding, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Container(width: width??1.sw,
    margin: margin??EdgeInsets.fromLTRB(40.sp, top??0, 40.sp, 40.sp),
    padding: padding??EdgeInsets.all(40.sp),
    decoration: BoxDecCustom(radius: radius),
    child: child);
}