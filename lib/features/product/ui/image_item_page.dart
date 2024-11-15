import 'dart:io';
import 'dart:typed_data';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class ImageItemProduct extends StatefulWidget {
  final File file;
  final Function delete;
  const ImageItemProduct(this.file, this.delete, {Key? key}) : super(key: key);
  @override
  _ImageItemProductState createState() => _ImageItemProductState();
}

class _ImageItemProductState extends State<ImageItemProduct> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(alignment: Alignment.topRight, width: 240.sp,
        margin: EdgeInsets.only(right: 20.sp),
        decoration: BoxDecoration(image: DecorationImage(image: Image.file(widget.file, width: 240.sp,
            cacheHeight: 480.sp.toInt()).image, fit: BoxFit.cover)),
        child: SizedBox(height: 24, width: 24, child: IconButton(onPressed: () => widget.delete(),
            icon: const Icon(Icons.close, color: Colors.white,size: 20), padding: EdgeInsets.zero)));
  }
}

class ImageItemPests extends StatefulWidget {
  final FileByte file;
  final int index;
  final Function funDelete, funAdd;
  final double? padding;
  const ImageItemPests(this.file, this.index, this.funAdd, this.funDelete, {Key? key, this.padding}) : super(key: key);
  @override
  _ImageItemPestsState createState() => _ImageItemPestsState();
}

class _ImageItemPestsState extends State<ImageItemPests> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      ClipRRect(child: Image.memory(Uint8List.fromList(widget.file.bytes), height: 0.28.sh, cacheHeight: 0.28.sh.toInt(), fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(16.sp)),
      ButtonImageWidget(100, () => widget.funDelete(widget.index), Container(
          margin: EdgeInsets.all(10.sp),
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(100)
          ),
          child: Icon(Icons.clear, color: Colors.white, size: 42.sp))),
      if (widget.padding != null) Container(margin: EdgeInsets.only(top: 80.sp),
          child: ButtonImageWidget(100, () => widget.funAdd(widget.index), Container(
              margin: EdgeInsets.all(10.sp), padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(100)),
              child: Icon(Icons.edit, color: Colors.white, size: 42.sp))))
    ], alignment: Alignment.topRight);
  }
}
