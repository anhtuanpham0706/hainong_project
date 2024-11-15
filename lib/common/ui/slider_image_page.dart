import 'package:photo_view/photo_view.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/item_list_model.dart';
import '../util/util.dart';

class SliderImagePage extends StatelessWidget {
  final ItemListModel list;
  final int index;
  const SliderImagePage(this.list, {this.index = 0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(child: Scaffold(
    appBar: AppBar(backgroundColor: Colors.black),
    body: Column(children: [
      const Divider(height: 0.2, color: Colors.grey),
      Expanded(child: Center(child: CarouselSlider.builder(itemCount: list.list.length,
        options: CarouselOptions(height: 1.sh, viewportFraction: 1, initialPage: index),
        itemBuilder: (context, index, realIndex) =>
          PhotoView(imageProvider: FadeInImage.assetNetwork(
            imageErrorBuilder: (context, obj, trace) => Image.asset('assets/images/ic_default.png', fit: BoxFit.fill),
            placeholder: 'assets/images/ic_default.png', image: Util.getRealPath(list.list[index].name)).image))))
    ])));
}
