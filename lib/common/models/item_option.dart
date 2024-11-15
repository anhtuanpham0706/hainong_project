import 'package:flutter/material.dart';

class ItemOption {
  String assetPath, title;
  bool isLock;
  Function function;
  IconData? icon;
  ItemOption(this.assetPath, this.title, this.function, this.isLock, {this.icon});
}