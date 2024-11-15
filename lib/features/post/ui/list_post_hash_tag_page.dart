import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/features/home/ui/home_page.dart';

class ListPostHashtagPage extends StatelessWidget {
  final String hashTag;
  final bool allowGotoShop, clearPage;
  const ListPostHashtagPage(this.hashTag, {this.allowGotoShop = true, this.clearPage = true, Key? key}):super(key:key);
  @override
  Widget build(context) => Scaffold(
    appBar: AppBar(title: Text(hashTag), centerTitle: true),
    body: HomePage(hasHighlight: false, hashTag: hashTag.replaceFirst('#', ''), allowGotoShop: allowGotoShop, clearPage: clearPage)
  );
}