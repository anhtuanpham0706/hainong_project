import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';

class DiagnosticItem extends StatelessWidget {
  final ItemModel item;
  final bool active;
  final Function funChange;
  const DiagnosticItem(this.item, this.active, this.funChange, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => ButtonImageWidget(0, funChange, Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: active?Border(bottom: BorderSide(color: const Color(0xFFFF8226), width: 6.sp)):null
    ),
    padding: EdgeInsets.all(40.sp), child: Text(item.name, style: TextStyle(color: active ?
  const Color(0xFF1F1F1F) : const Color(0xFF808080), fontSize: 42.sp, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center, maxLines: 2)
  ));
}
