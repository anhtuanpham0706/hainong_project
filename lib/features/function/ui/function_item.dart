import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class FunctionItem extends StatelessWidget {
  final String url, asset, name;
  final Function action;
  final bool hasPadding;
  const FunctionItem(this.name, this.url, this.action, {this.asset = 'assets/images/ic_default.png', this.hasPadding = true, Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    final img = url.isEmpty ? Image.asset(asset, fit: BoxFit.cover, width: 0.15.sw, height: 0.15.sw) :
      Image.network(url, fit: BoxFit.fitHeight, width: 0.15.sw, height: 0.15.sw,
        errorBuilder: (_,__,___) => SizedBox(width: 0.15.sw, height: 0.15.sw));
    return SizedBox(width: 0.25.sw - 20.sp, child: Column(children: [
      ButtonImageWidget(10, action, hasPadding ? Padding(padding: EdgeInsets.all(20.sp), child: img) :
        ClipRRect(child: img, borderRadius: BorderRadius.circular(10)), color: Colors.white, elevation: 4.0),
      SizedBox(height: 20.sp),
      Text(name, textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 45.sp))
    ]));
  }
}
