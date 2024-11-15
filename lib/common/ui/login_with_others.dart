import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'button_image_widget.dart';
import 'dart:io';

class LoginWithOthers extends StatelessWidget {
  final Function funFacebook, funGoogle, funApple, funZalo;
  const LoginWithOthers(this.funFacebook, this.funGoogle, this.funApple, this.funZalo, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(padding: EdgeInsets.only(top: 60.sp, bottom: 32.sp),
        child: ButtonImageWidget(0, funZalo, Image.asset('assets/images/v5/ic_zalo.png', width: 1.sw - 160.sp, fit: BoxFit.fitWidth))),
    ButtonImageWidget(0, funGoogle, Image.asset('assets/images/v5/ic_google.png', width: 1.sw - 160.sp, fit: BoxFit.fitWidth)),
    if (Platform.isIOS) Padding(padding: EdgeInsets.only(top: 32.sp), child: ButtonImageWidget(0, funApple,
        Image.asset('assets/images/v5/ic_apple.png', width: 1.sw - 160.sp, fit: BoxFit.fitWidth))),
    //Padding(padding: EdgeInsets.symmetric(vertical: 32.sp),
    //  child: ButtonImageWidget(0, funFacebook, Image.asset('assets/images/v5/ic_facebook.png', width: 1.sw - 160.sp, fit: BoxFit.fitWidth)))
  ]);
}