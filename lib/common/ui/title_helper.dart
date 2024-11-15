import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/features/function/ui/wed_2nong.dart';
import '../multi_language.dart';
import '../util/util_ui.dart';
import 'button_image_widget.dart';

class TitleHelper extends StatelessWidget {
  final String title, url;
  const TitleHelper(this.title, {this.url = 'https://help.hainong.vn', Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) => Row(children: [
    Flexible(child: UtilUI.createLabel(MultiLanguage.get(title), textAlign: TextAlign.center)),
    const SizedBox(width: 5),
    ButtonImageWidget(100, () => UtilUI.goToNextPage(context, Web2Nong(url, hasTitle: true, isClose: true)),
        Icon(Icons.info_outline, color: Colors.white, size: 56.sp))
  ], mainAxisAlignment: MainAxisAlignment.center);
}