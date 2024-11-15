import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopupMapInfoDialog {
  static void show(BuildContext context, HashMap<dynamic, dynamic> itemMap) => showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
          color: Colors.transparent,
          height: 0.4.sh,
          child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Thông tin",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Khu vực: ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["district_name"]}",
                        style: const TextStyle(fontSize: 15),
                        maxLines: 1,
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
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
                        "${itemMap["properties"]["plant_name"]}",
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
                        "Dinh dưỡng: ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["nutrition"] ?? "Không có"}",
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
                        "N (Nitơ): ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["nutrition_n"]}",
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
                        "P (P205): ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["nutrition_p"]}",
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
                        "K (K20): ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["nutrition_k"]}",
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
                        "Hữu cơ: ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["nutrition_organic"]}",
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
                        "Độ mặn: ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["salinity"] ?? "Không có"}",
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
                        "Độ PH: ",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${itemMap["properties"]["pH"]}",
                        style: const TextStyle(fontSize: 15),
                        maxLines: 1,
                      )
                    ],
                  )
                ],
              ))));
}
