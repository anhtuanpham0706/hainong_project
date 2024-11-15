import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/slider_image_page.dart';

class DiaSimilarPhotosPage extends StatelessWidget {
  final dynamic images;
  final String title;
  const DiaSimilarPhotosPage(this.images, this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Scaffold(appBar: AppBar(titleSpacing: 0, centerTitle: true,
      title: UtilUI.createLabel('Hình ảnh liên quan bệnh ' + title)),
      body: AlignedGridView.count(padding: EdgeInsets.all(40.sp),
          crossAxisCount: 2, mainAxisSpacing: 20.sp, crossAxisSpacing: 20.sp, itemCount: images.list.length,
          itemBuilder: (BuildContext context, int index) {
            return ButtonImageWidget(0, () => UtilUI.goToNextPage(context, SliderImagePage(images, index: index)),
              FadeInImage.assetNetwork(placeholder: 'assets/images/ic_default.png', image:
                Util.getRealPath(images.list[index].name),
                width: 0.5.sw, height: 0.3.sw, fit: BoxFit.cover,
                imageErrorBuilder: (_,__,___) => Image.asset('assets/images/ic_default.png', width: 0.5.sw, height: 0.3.sw, fit: BoxFit.fill)));
          }
      ));
}