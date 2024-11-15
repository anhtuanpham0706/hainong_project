import 'package:flutter/services.dart';
import 'package:hainong/common/style_custom.dart';
import '../util/util.dart';
import 'import_lib_base_ui.dart';

class TextFieldCustom extends StatefulWidget {
  final TextEditingController control;
  final FocusNode? focus, nextFocus;
  final String hintText;
  final bool isPassword, readOnly;
  final bool? isOdd;
  final Widget? suffix;
  final Function? onPressIcon, onSubmit, onChanged;
  final TextInputType type;
  final int? maxLength;
  final int maxLine, odd;
  final EdgeInsets? padding, paddingIcon;
  final double? size, iconSize;
  final double sizeBorder;
  final Color textColor, color;
  final Color? borderColor;
  final BoxConstraints? constraint;
  final TextAlign align;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction inputAction;
  final dynamic border;
  final bool isEnable;

  const TextFieldCustom(this.control, this.focus, this.nextFocus, this.hintText,
      {this.isPassword = false, this.readOnly = false, this.inputAction = TextInputAction.next, this.iconSize,
        this.suffix, this.onPressIcon, this.type = TextInputType.text, this.border, this.borderColor, this.constraint,
        this.maxLength, this.maxLine = 1, this.padding, this.size, this.textColor = Colors.black, this.paddingIcon,
        this.onSubmit, this.onChanged, this.inputFormatters, this.sizeBorder = 5.0, this.color = Colors.white,
        this.align = TextAlign.left, this.isOdd, this.odd = 3, this.isEnable = true, Key? key}) :super(key: key);

  @override
  _TextFieldCustomState createState() => _TextFieldCustomState();

  static String stringToDouble(String value, {bool isOdd = false}) {
    if (!isOdd) return value.replaceAll('.', '');
    if (value.contains(',')) return value.replaceAll('.', '').replaceFirst(',', '.');
    return value;
  }
}

class _TextFieldCustomState extends State<TextFieldCustom> {

  @override
  void dispose() {
    if (widget.isOdd != null) widget.focus?.removeListener(_listener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isOdd != null) widget.focus?.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    final fcBorder = widget.border??_getBorder(widget.sizeBorder, widget.borderColor??StyleCustom.borderTextColor);
    final dsBorder = widget.border??_getBorder(widget.sizeBorder, widget.borderColor??StyleCustom.borderTextColor.withOpacity(0.6));
    final enBorder = _getBorder(widget.sizeBorder, StyleCustom.primaryColor);
    InputDecoration decoration = InputDecoration(
        filled: true,
        fillColor: widget.isEnable ? widget.color : StyleCustom.borderTextColor.withOpacity(0.6),
        contentPadding: widget.padding??EdgeInsets.fromLTRB(30.sp, 0, 30.sp, 0),
        suffixIcon: widget.suffix,
        suffixIconConstraints: widget.constraint,
        hintText: widget.hintText,
        enabledBorder: fcBorder,
        focusedBorder: enBorder,
        disabledBorder: dsBorder,
        counterText: widget.maxLength != null ? '' : null
      );

    return TextField(
        style: TextStyle(color: widget.textColor, fontSize: widget.size??40.sp),
        maxLines: widget.maxLine == 0 ? null : widget.maxLine,
        focusNode: widget.focus,
        enabled: widget.isEnable,
        onSubmitted: (term) {
          widget.focus?.unfocus();
          if (widget.nextFocus != null) FocusScope.of(context).requestFocus(widget.nextFocus);
          if (widget.inputAction == TextInputAction.done && widget.onSubmit != null) widget.onSubmit!();
        },
        onChanged: (value) {
          if (widget.onChanged != null) widget.onChanged!(widget.control, value);
        },
        onTap: () {
          if (widget.onPressIcon != null) widget.onPressIcon!();
        },
        textAlign: widget.align,
        maxLength: widget.maxLength,
        controller: widget.control,
        textInputAction: widget.inputAction,
        obscureText: widget.isPassword,
        decoration: decoration,
        readOnly: widget.readOnly,
        keyboardType: widget.type,
        inputFormatters: widget.inputFormatters??[
          LengthLimitingTextInputFormatter(widget.maxLength??1000000000)
        ]);
  }

  OutlineInputBorder _getBorder(double size, Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(size), borderSide: BorderSide(color: color, width: 0.5));

  bool _hasFocus = false;
  void _listener() {
    if (widget.focus!.hasFocus) {
      if (widget.control.text.isNotEmpty && !_hasFocus) {
        _hasFocus = true;

        widget.control.text = widget.control.text.replaceAll('.', '');

        if (widget.control.text.contains(',') && (widget.isOdd??false)) widget.control.text = widget.control.text.replaceFirst(',', '.');

        double temp = .0;
        try {
          temp = double.parse(widget.control.text);
        } catch (_) {}
        if ((widget.isOdd??false)) {
          widget.control.text = temp - temp.toInt() > 0 ? temp.toString() : temp.toInt().toString();
        } else widget.control.text = temp.toInt().toString();
      }
    } else {
      _hasFocus = false;
      if (widget.control.text.isNotEmpty) {
        double temp = .0;
        try {
          temp = double.parse(widget.control.text);
        } catch (_) {}
        widget.control.text = Util.doubleToString(temp, digit: (widget.isOdd??false) ? widget.odd : 0);
      }
    }
  }
}