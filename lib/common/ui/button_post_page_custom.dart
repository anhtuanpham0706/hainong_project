import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'avatar_circle_widget.dart';
import 'import_lib_base_ui.dart';

class ButtonPostCustom extends StatefulWidget {
  final Function clickEvent;
  final String titleMessage;
  const ButtonPostCustom(this.clickEvent ,{this.titleMessage ='', Key? key}) : super(key: key);

  @override
  State<ButtonPostCustom> createState() => _ButtonPostCustomState();
}

class _ButtonPostCustomState extends State<ButtonPostCustom> {
  String shopImage = '';
  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      setState(() => shopImage = value.getString(Constants().image)??'');
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) => GestureDetector(onTap:() => widget.clickEvent(false), child: Column(children: [
    Container(color: Colors.white, padding: EdgeInsets.all(20.sp), child: Row(children: [
      AvatarCircleWidget(link: shopImage, size: 120.sp),
      SizedBox(width: 32.sp,),
      Expanded(child: Text(widget.titleMessage, style: TextStyle(fontSize: 40.sp, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
      GestureDetector(onTap: () => widget.clickEvent(true), child: Image.asset('assets/images/ic_image.png', width: 60.sp)),
    ])),
    Divider(height: 20.sp, thickness: 20.sp, color: const Color(0xFFEFEFEF))
  ]));
}

