import 'package:hainong/common/ui/chatbot_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showChatbotBottomSheet(BuildContext context, Function? funDynamicLink) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final userName = prefs.getString('name') ?? "";
  final userToken = prefs.getString('token2_user') ?? "";
  final chatUrl = "https://chatbot.hainong.vn?embedded=true&user_name=$userName&user_token=$userToken";
  return showModalBottomSheet(
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => ChatbotBodyWidget(funDynamicLink, chatUrl: chatUrl),
  );
}
