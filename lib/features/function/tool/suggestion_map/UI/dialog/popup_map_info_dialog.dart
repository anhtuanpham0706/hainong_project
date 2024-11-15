import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopupMapInfoDialog {
  static void show(BuildContext context, HashMap<dynamic, dynamic> itemMap) => showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
          color: Colors.transparent,
          height: 0.2.sh,
          child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Loại cây: ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["category_name"]}",
                        style: const TextStyle(fontSize: 15),
                        maxLines: 1,
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Tỉ lệ (AI): ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["percent"]}",
                        style: const TextStyle(fontSize: 15),
                        maxLines: 1,
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Chuẩn đoán: ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["suggest"]}",
                        style: const TextStyle(fontSize: 15),
                        maxLines: 1,
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Địa điểm: ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["address"]}",
                        style: const TextStyle(fontSize: 15),
                        maxLines: 1,
                      )
                    ],
                  )
                ],
              ))));
}
