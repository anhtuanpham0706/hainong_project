import 'package:hainong/features/signup/ui/variant.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class SignUpVariant extends Variant {
  final TextEditingController ctrFullName = TextEditingController();
  final TextEditingController ctrBirthday = TextEditingController();
  final TextEditingController ctrGender = TextEditingController();
  final TextEditingController ctrReferrarCode = TextEditingController();
  final TextEditingController ctrEmail = TextEditingController();
  final TextEditingController ctrPhoneNumber = TextEditingController();
  final TextEditingController ctrPassword = TextEditingController();
  final TextEditingController ctrRepeatPassword = TextEditingController();
  final FocusNode focusFullName = FocusNode();
  final FocusNode focusBirthday = FocusNode();
  final FocusNode focusGender = FocusNode();
  final FocusNode focusReferrarCode = FocusNode();
  final FocusNode focusEmail = FocusNode();
  final FocusNode focusPhoneNumber = FocusNode();
  final FocusNode focusPassword = FocusNode();
  final FocusNode focusRepeatPassword = FocusNode();
  bool isFirst = true;

  @override
  dispose() {
    super.dispose();
    ctrFullName.dispose();
    ctrBirthday.dispose();
    ctrGender.dispose();
    ctrReferrarCode.dispose();
    ctrPhoneNumber.dispose();
    ctrPassword.dispose();
    ctrRepeatPassword.dispose();
    ctrEmail.dispose();
    focusFullName.dispose();
    focusBirthday.dispose();
    focusGender.dispose();
    focusReferrarCode.dispose();
    focusPhoneNumber.dispose();
    focusPassword.dispose();
    focusRepeatPassword.dispose();
    focusEmail.dispose();
  }
}
