import 'package:flutter/material.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/features/signup/ui/variant.dart';

class ProfileVariant extends Variant {
  final TextEditingController ctrFullName = TextEditingController();
  final TextEditingController ctrPhone = TextEditingController();
  final TextEditingController ctrBirthday = TextEditingController();
  final TextEditingController ctrGender = TextEditingController();
  final TextEditingController ctrEmail = TextEditingController();
  final TextEditingController ctrWebsite = TextEditingController();
  final TextEditingController ctrAddress = TextEditingController();
  final TextEditingController ctrProvince = TextEditingController();
  final TextEditingController ctrDistrict = TextEditingController();
  final TextEditingController ctrAcreage = TextEditingController();
  final FocusNode focusFullName = FocusNode();
  final FocusNode focusPhone = FocusNode();
  final FocusNode focusBirthday = FocusNode();
  final FocusNode focusGender = FocusNode();
  final FocusNode focusEmail = FocusNode();
  final FocusNode focusWebsite = FocusNode();
  final FocusNode focusAddress = FocusNode();
  final FocusNode focusProvince = FocusNode();
  final FocusNode focusDistrict = FocusNode();
  final FocusNode focusAcreage = FocusNode();
  final List<ItemModel> provinces = [], districts = [], catalogueUserType = [], catalogueHashTag = [];

  @override
  void dispose() {
    ctrFullName.dispose();
    ctrPhone.dispose();
    ctrBirthday.dispose();
    ctrGender.dispose();
    ctrEmail.dispose();
    ctrWebsite.dispose();
    ctrAddress.dispose();
    ctrProvince.dispose();
    ctrDistrict.dispose();
    ctrAcreage.dispose();
    focusFullName.dispose();
    focusPhone.dispose();
    focusBirthday.dispose();
    focusGender.dispose();
    focusEmail.dispose();
    focusWebsite.dispose();
    focusAddress.dispose();
    focusProvince.dispose();
    focusDistrict.dispose();
    focusAcreage.dispose();
    provinces.clear();
    districts.clear();
    catalogueUserType.clear();
    catalogueHashTag.clear();
    super.dispose();
  }
}