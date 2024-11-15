import 'import_lib_post_sub_ui.dart';

class IconPlayDefault extends StatelessWidget {
  final double? size;
  const IconPlayDefault({this.size, Key? key}):super(key:key);

  @override
  Widget build(context) => Icon(Icons.play_circle_fill,
      color: Colors.white, size: size??120.sp);
}
