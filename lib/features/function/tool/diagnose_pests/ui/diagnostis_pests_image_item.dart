import 'dart:typed_data';
import 'package:hainong/common/models/file_byte.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class DiagnosePestsImageItemPage extends StatelessWidget {
  final FileByte file;
  final Function delete;
  const DiagnosePestsImageItemPage(this.file, this.delete, {Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.topRight,
        width: 240.sp,
        margin: EdgeInsets.only(right: 20.sp),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: Image.memory(Uint8List.fromList(file.bytes)).image, fit: BoxFit.cover),
        ),
        child: SizedBox(
            height: 24,
            width: 24,
            child: IconButton(
                onPressed: () => delete(),
                icon: const Icon(Icons.close, color: Colors.white,size: 20),
                padding: EdgeInsets.zero)),
      );
}
