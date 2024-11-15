import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';

class DialogListAddressCustom extends StatefulWidget {
  final String? title, lblOK;
  final String message, hintText;
  final Alignment alignMessage;
  final TextAlign alignMessageText;
  final Color colorMessage;
  final TextInputType inputType;
  final int? maxLength;
  final bool hasSubOK, isCheckEmpty, showMsg;

  const DialogListAddressCustom(
      {this.hintText = '',
        this.message = '',
        this.title,
        this.lblOK,
        this.alignMessage = Alignment.centerLeft,
        this.alignMessageText = TextAlign.left,
        this.colorMessage = const Color(0xFF1F1F1F),
        this.inputType = TextInputType.text,
        this.maxLength,
        this.hasSubOK = false, this.showMsg = true,
        this.isCheckEmpty = true, Key? key}):super(key:key);

  @override
  _DialogListAddressCustomState createState() => _DialogListAddressCustomState();
}

class _DialogListAddressCustomState extends State<DialogListAddressCustom> {
  final TextEditingController ctr = TextEditingController();
  List<String> _list_address = [];

  @override
  void dispose() {
    ctr.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getAddress();
    super.initState();
  }
  void _getAddress() {
    SharedPreferences.getInstance().then((prefs) {
       _list_address = prefs.getStringList('list_address')??[];
       setState(() {});
    });
  }

  @override
  Widget build(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.sp))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(alignment: Alignment.center,
              child: Container(width: 0.9.sw, constraints: BoxConstraints(maxHeight: 0.8.sh),
                  margin: EdgeInsets.only(bottom: 20.sp),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.sp)),
                  child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min,
                          children: addressItems(
                              context, 'Danh sách địa chỉ', _list_address, '', hasTitle: true)
                      )
                  )))
        ],
      ),
    );
  }

  List<Widget> addressItems(BuildContext context, String title,
      List<String> values, String id, {bool hasTitle = true,bool hasAdd = true}) {
    final TextEditingController _ctrAddress = TextEditingController();
    final FocusNode focusAddress = FocusNode();
    final line = Container(color: Colors.grey.shade300, height: 1);
    void _addAddress() {
      if(_ctrAddress.text.length < 8) {
        UtilUI.showCustomDialog(context, 'Nhập địa chỉ rõ ràng hơn (Trên 8 ký tự)');
        return;
      }
      _list_address.add(_ctrAddress.text);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList('list_address', _list_address);
      });
      setState(() {
      });
    }
    List<Widget> list = [];
    if (hasTitle) {list.add(SizedBox(height: 120.sp, child: Center(
        child: LabelCustom(title, color: Colors.black87))));}
    list.add(line);
    if(hasAdd) {
      list.add(Padding(padding: EdgeInsets.all(40.sp), child: TextFieldCustom(_ctrAddress,focusAddress,null,"Nhập địa chỉ",
          suffix: ButtonImageWidget(0, _addAddress, Icon(Icons.add,size: 64.sp,color: Colors.black26)))));
    }
    for (var i = 0; i < values.length; i++) {
      list.add(line);
      list.add(OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.transparent),
              padding: EdgeInsets.zero),
          onPressed: () => Navigator.of(context).pop(values[i]),
          child: Container(color: Colors.white, padding: EdgeInsets.all(20.sp),
              width: 1.sw, alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: LabelCustom(values[i], color: StyleCustom.primaryColor),
                  ),
                  GestureDetector(
                    onTap: (){
                      _list_address.removeAt(i);
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setStringList('list_address', _list_address);
                      });
                      setState(() {
                      });
                    },
                    child: Padding(
                      padding:  EdgeInsets.only(right: 20.sp),
                      child: Icon(Icons.close,size: 64.sp,color: Colors.black26,),
                    ),
                  ),
                ],
              ))));
    }
    return list;
  }
}


