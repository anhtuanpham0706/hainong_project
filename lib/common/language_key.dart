class LanguageKey {
  static LanguageKey? _instance;
  LanguageKey._();
  factory LanguageKey() {
    _instance??=LanguageKey._();
    return _instance!;
  }

  final String ttlAlert = 'ttl_alert';
  final String ttlWarning = 'ttl_warning';
  final String ttlOtp = 'ttl_otp';
  final String ttlDetails = 'ttl_details';

  final String lblPassword = 'lbl_password';
  final String lblFullName = 'lbl_full_name';
  final String lblBirthday = 'lbl_birthday';
  final String lblGender = 'lbl_gender';
  final String lblEmail = 'lbl_email';
  final String lblPhoneNumber = 'lbl_phone_number';
  final String lblAddress = 'lbl_address';
  final String lblProvince = 'lbl_province';
  final String lblDistrict = 'lbl_district';
  final String lblRepeatPassword = 'lbl_repeat_password';
  final String lblOtpCode = 'lbl_otp_code';
  final String lblAboutUs = 'lbl_about_us';
  final String lblRetailPrice = 'lbl_retail_price';
  final String lblWholesalePrice = 'lbl_wholesale_price';
  final String lblCatalogue = 'lbl_catalogue';
  final String lblUnit = 'lbl_unit';
  final String lblCamera = 'lbl_camera';
  final String lblGallery = 'lbl_gallery';
  final String lblWebsite = 'lbl_website';
  final String lblYouAre = 'lbl_you_are';
  final String lblHashtagsYouCare = 'lbl_hashtags_you_care';

  final String btnLogin = 'btn_login';
  final String btnOK = 'btn_ok';
  final String btnCancel = 'btn_cancel';
  final String btnSignUp = 'btn_sign_up';
  final String btnPost = 'btn_post';
  final String btnSave = 'btn_save';

  final String msgInputPassword = 'msg_input_password';
  final String msgInputFullName = 'msg_input_full_name';
  final String msgInputPhoneNumber = 'msg_input_phone_number';
  final String msgInputRepeatPassword = 'msg_input_repeat_password';
  final String msgRepeatPasswordNotMatch = 'msg_repeat_password_not_match';
  final String msgErrorGetDeviceId = 'msg_error_get_device_id';
  final String msgCallOtp = 'msg_call_otp';
  final String msgInvalidPassword = 'msg_invalid_password';
  final String msgAnotherLogin = 'msg_another_login';
  final String msgWarningPostSuccess = 'msg_warning_post_success';
  final String msgInputShareDescription = 'msg_input_share_description';
  final String msgLoginOrCreate = 'msg_login_create_account';
}