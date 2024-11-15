import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'button_custom.dart';
import 'label_custom.dart';
import '../count_down_bloc.dart';
import '../language_key.dart';
import '../multi_language.dart';
import '../style_custom.dart';
import '../ui/textfield_custom.dart';
import '../util/util_ui.dart';

class ConfirmDialogCustom extends StatefulWidget {
  final String? title, lblOK, compareValue;
  final String message, hintText, alertMsg, initContent;
  final Alignment alignMessage;
  final TextAlign alignMessageText;
  final Color colorMessage;
  final TextInputType inputType;
  final TextInputAction action;
  final int? maxLength, line;
  final int countDown;
  final Function? funSetCountDown;
  final bool hasSubOK, isCheckEmpty, showMsg;
  final EdgeInsets? padding;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;

  const ConfirmDialogCustom(this.alertMsg,
      {this.hintText = '', this.message = '', this.initContent = '',
      this.title, this.countDown = 45, this.lblOK, this.padding,
      this.alignMessage = Alignment.centerLeft,
      this.alignMessageText = TextAlign.left,
      this.colorMessage = const Color(0xFF1F1F1F),
      this.inputType = TextInputType.text,
      this.action = TextInputAction.done,
      this.maxLength, this.line, this.funSetCountDown,
      this.hasSubOK = false, this.showMsg = true,
      this.inputFormatters, this.suffix,
      this.isCheckEmpty = true, this.compareValue, Key? key}):super(key:key);

  @override
  _ConfirmDialogCustomState createState() => _ConfirmDialogCustomState();
}

class _ConfirmDialogCustomState extends State<ConfirmDialogCustom> {
  final TextEditingController ctr = TextEditingController();
  final FocusNode fc = FocusNode();
  final CountDownBloc bloc = CountDownBloc(init: const CountDownState(value: 45));
  late Timer countDownTimer;

  @override
  void dispose() {
    if (countDownTimer.isActive) {
      if (widget.funSetCountDown != null) widget.funSetCountDown!((bloc.state as CountDownState).value);
      countDownTimer.cancel();
    }
    bloc.close();
    ctr.dispose();
    fc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc.add(CountDownEvent(value: widget.countDown));
    super.initState();
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (Timer value) {
      int count = (bloc.state as CountDownState).value - 1;
      bloc.add(CountDownEvent(value: count));
      if (count < 1) value.cancel();
    });
    ctr.text = widget.initContent;
    Timer(const Duration(milliseconds: 1000), () => fc.requestFocus());
  }

  @override
  Widget build(context) {
    final LanguageKey languageKey = LanguageKey();
    String title = widget.title??MultiLanguage.get(languageKey.ttlWarning);
    String lblOK = widget.lblOK??MultiLanguage.get(languageKey.btnOK);
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.sp))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.sp),
                    topRight: Radius.circular(30.sp))),
            width: 1.sw,
            child: Padding(
              padding: EdgeInsets.all(40.sp),
              child: Stack(
                children: [
                  Center(child: LabelCustom(title, color: StyleCustom.textColor19, size: 60.sp)),
                  Align(child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: const Icon(Icons.close, color: StyleCustom.textColor6E)),
                      alignment: Alignment.topRight)
                ],
              ),
            ),
          ),
          if (widget.showMsg) Padding(
              padding: EdgeInsets.fromLTRB(40.sp, 80.sp, 40.sp, 0),
              child: Align(
                alignment: widget.alignMessage,
                child: LabelCustom(widget.message,
                    align: widget.alignMessageText,
                    color: widget.colorMessage,
                    size: 45.sp,
                    weight: FontWeight.normal),
              )),
          Container(padding: EdgeInsets.all(40.sp), constraints: BoxConstraints(maxHeight: 0.36.sh),
              child: TextFieldCustom(ctr, fc, null, widget.hintText, onChanged: widget.compareValue == null ? null : _onChanged,
                  inputAction: widget.action, padding: widget.padding,
                  type: widget.inputType, maxLine: widget.line??1, suffix: widget.suffix,
                  maxLength: widget.maxLength, inputFormatters: widget.inputFormatters)),
          Container(width: 1.sw,
              padding: EdgeInsets.all(40.sp),
              child: ButtonCustom(() {
                FocusScope.of(context).unfocus();
                if (widget.isCheckEmpty) {
                  if (ctr.text.isNotEmpty)
                    Navigator.of(context).pop(ctr.text);
                  else
                    UtilUI.showCustomDialog(context, widget.alertMsg).whenComplete(() => fc.requestFocus());
                } else
                  Navigator.of(context).pop(ctr.text);
              }, lblOK)),
          widget.hasSubOK
              ? Padding(
                  padding:
                      EdgeInsets.fromLTRB(40.sp, 0, 40.sp, 40.sp),
                  child: BlocBuilder(
                    bloc: bloc,
                      builder: (context, state) => (state as CountDownState).value < 1
                          ? OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.transparent,
                                ),
                                backgroundColor: Colors.grey.shade500,
                                textStyle: const TextStyle(color: StyleCustom.primaryColor)
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: LabelCustom(
                                  MultiLanguage.get('btn_resend_another_code'),
                                  color: StyleCustom.primaryColor,
                                  size: 45.sp,
                                  decoration: TextDecoration.underline))
                          : LabelCustom(state.value.toString() + MultiLanguage.get(
                          'lbl_second'), color: Colors.red, size: 45.sp)))
              : const SizedBox()
        ]
      )
    );
  }

  void _onChanged(ctr, value) {
    if (value == widget.compareValue) Navigator.of(context).pop(value);
  }
}
