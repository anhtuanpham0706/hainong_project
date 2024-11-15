import 'package:flutter_html/flutter_html.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import '../style_custom.dart';

class ShowInfo extends StatefulWidget {
  final BaseBloc? bloc;
  final String fieldName;
  const ShowInfo(this.bloc,this.fieldName,{Key? key}) : super(key: key);
  @override
  State<ShowInfo> createState() => _ShowInfoState();
}

class _ShowInfoState extends State<ShowInfo> {
  @override
  Widget build(BuildContext context) => BlocBuilder(bloc: widget.bloc,
      buildWhen: (oldS, newS) => newS is GetInfoPopupState,
      builder: (context, state) {
        if(widget.bloc == null || widget.bloc!.data == null ||
            (widget.bloc!.data[widget.fieldName]??'').isEmpty) return const SizedBox();
        return Padding(padding: EdgeInsets.only(left: 15.sp),
          child: InkWell(onTap: _showPopup, child: Icon(Icons.info_outline,color: StyleCustom.primaryColor,size: 50.sp)));
      });

  void _showPopup() => showDialog(useSafeArea: true, context: context, builder: (context) =>
        Dialog(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.sp))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 1.sw, decoration: BoxDecoration(color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30.sp), topRight: Radius.circular(30.sp))),
                  child: Padding(padding: EdgeInsets.all(40.sp), child: Stack(children: [
                    Align(alignment: Alignment.topRight, child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: const Icon(Icons.close, color: Color(0xFF626262)))),
                    Center(child: LabelCustom('Giải thích', color: const Color(0xFF191919), size: 60.sp))
                  ]))),
              Flexible(child: SingleChildScrollView(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
                  child: Html(data: widget.bloc!.data[widget.fieldName], style: {
                    'html, body, p': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero, fontSize: FontSize(42.sp), color: Colors.black),
                    'img': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero, width: 1.sw, height: 0.5.sw),
                  }))))
            ])));
}

