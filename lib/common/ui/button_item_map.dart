import '../style_custom.dart';
import 'import_lib_base_ui.dart';
import 'button_image_widget.dart';
import 'label_custom.dart';
import 'shadow_decoration.dart';

class ButtonItemMap extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function action;
  const ButtonItemMap(this.icon, this.title, this.action, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Expanded(child:
  Padding(child: ButtonImageWidget(5, action, Column(children: [
    Icon(icon, color: const Color(0xFF1AAD80), size: 48.sp),
    SizedBox(height: 16.sp),
    LabelCustom(title, size: 36.sp, color: const Color(0xFF1AAD80), weight: FontWeight.normal, align: TextAlign.center, line: 2)
  ], mainAxisSize: MainAxisSize.min)), padding: EdgeInsets.all(10.sp)));
}

class ButtonMap extends StatelessWidget {
  final Function action;
  final String label;
  final bool active;
  final double? size, padding;
  final Color activeColor;
  const ButtonMap(this.label, this.action, {this.active = false, this.activeColor = StyleCustom.primaryColor, this.padding, this.size, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Expanded(child: ButtonImageWidget(12, action, Container(padding: EdgeInsets.all(padding??10),
      decoration: ShadowDecoration(size: 12, bgColor: active ? activeColor : Colors.white),
      child: LabelCustom(label, color: active ? Colors.white : Colors.black, size: size??36.sp, weight: FontWeight.normal, align: TextAlign.center, line: 1))));
}