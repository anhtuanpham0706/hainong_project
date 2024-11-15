import 'package:flutter/material.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/features/signup/ui/variant.dart';

class SignUpNextVariant extends Variant {
  final TextEditingController ctrWebsite = TextEditingController();
  final TextEditingController ctrAddress = TextEditingController();
  final TextEditingController ctrProvince = TextEditingController();
  final TextEditingController ctrDistrict = TextEditingController();
  final FocusNode focusWebsite = FocusNode();
  final FocusNode focusAddress = FocusNode();
  final FocusNode focusProvince = FocusNode();
  final FocusNode focusDistrict = FocusNode();
  final List<ItemModel> provinces = [];
  final List<ItemModel> districts = [];
  final List<ItemModel> catalogueUserType = [];
  final List<ItemModel> catalogueHashTag = [];

  dispose() {
    ctrWebsite.dispose();
    ctrAddress.dispose();
    ctrProvince.dispose();
    ctrDistrict.dispose();
    focusWebsite.dispose();
    focusAddress.dispose();
    focusProvince.dispose();
    focusDistrict.dispose();
    provinces.clear();
    districts.clear();
    catalogueUserType.clear();
    catalogueHashTag.clear();
    super.dispose();
  }
}