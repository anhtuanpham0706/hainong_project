import 'dart:async';
import 'dart:convert';
import 'dart:io';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hainong/splash_page.dart';
import 'package:hainong_chat_call_module/chat_call_core.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'common/api_client.dart';
import 'common/database_helper.dart';
import 'common/ui/import_lib_base_ui.dart';
import 'common/multi_language.dart';
import 'common/style_custom.dart';
import 'common/util/util_ui.dart';
import 'features/main/bloc/main_bloc.dart';
import 'features/main2/ui/main2_page.dart';
import 'package:chat_call_core/shared/helper/call_helper.dart';
import 'package:chat_call_core/presentation/chat/models/stream_response_model.dart';

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) => super.createHttpClient(context)
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
}

void main() async {
  HttpOverrides.global = PostHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  MultiLanguage.setLanguage(setEnv: true, setLogin: true);
  DBHelper.initDB();
  await ChatCallCore.initGetIt();
  //MobileAds.instance.initialize();
  final _myApp = MyApp();
  Firebase.initializeApp().then((value) {
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      Timer(const Duration(milliseconds: 2000), () => _myApp.onMessageOpen(message));
      if (message.data.containsKey('callId') && message.data['callId'].toString().isNotEmpty) {
        await fcmCallMessageCallBack(message: message, error: (message) {},
            callBack: (response) => _myApp.onCallSuggest(response, true));
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (Platform.isAndroid) {
        final _localNotify = FlutterLocalNotificationsPlugin();
        _localNotify.show(
            message.notification.hashCode,
            message.notification?.title,
            message.notification?.body,
            const NotificationDetails(
                android: AndroidNotificationDetails('high_importance_channel',
                    'High Importance Notifications',
                    channelDescription:
                    'This channel is used for important notifications.',
                    color: StyleCustom.primaryColor,
                    importance: Importance.high,
                    priority: Priority.high,
                    icon: 'ic_notification')),
            payload: jsonEncode(message.data));
      }
      _myApp.onMessage(message);
      if (message.data.containsKey('callId') && message.data['callId'].toString().isNotEmpty) {
        await fcmCallMessageCallBack(
            where: "onMessage",
            message: message,
            error: (message) {},
            callBack: (response) => _myApp.onCallSuggest(response, true));
      }
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  });
  final env = (await SharedPreferences.getInstance()).getString('env')??'';
  if (env.isEmpty) {
    SentryFlutter.init((options) async {
      options.dsn = 'https://88763a0addf3449f9840366061162b61@bug.advn.vn/7';
      options.environment = 'live_' + (await PackageInfo.fromPlatform()).version;
      options.sampleRate = 0.2;
      Sentry.configureScope((scope) => scope.level = SentryLevel.error);
    }, appRunner: () => runApp(_myApp));
  } else {
    SentryFlutter.init((options) async {
      options.dsn = 'https://12345a0addf3449f9840366061162b61@bug.advn.vn/7';
      options.environment = env + '_' + (await PackageInfo.fromPlatform()).version;
      options.sampleRate = 0.2;
    }, appRunner: () => runApp(_myApp));
  }
}

class MyApp extends StatefulWidget {
  final _myAppState = _MyAppState();
  MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _myAppState;

  void onMessageOpen(RemoteMessage message) => _myAppState.onMessageOpen(message);

  void onMessage(RemoteMessage message) => _myAppState.onMessage(message);

  void onCallSuggest(StreamResponseModel response, bool isSuggestCall) => _myAppState.onCallSuggest(response, isSuggestCall);
}

class _MyAppState extends State<MyApp> {
  final _bloc = MainBloc(ChangeIndexState());
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      ApiClient().checkVersion().then((url) {
        if (url.isNotEmpty) _showDialog(url);
      });
    }
    _bloc.stream.listen((state) {
      if (state is ClosePopupState) UtilUI.goBack(_navigatorKey.currentContext, false);
    });
  }

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
      designSize: const Size(1080, 1920),
      minTextAdapt: true, splitScreenMode: true,
      builder: () => MultiBlocProvider(
          providers: [BlocProvider<MainBloc>(create: (context) => _bloc)],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData().copyWith(
              colorScheme: ThemeData().colorScheme.copyWith(
                primary: StyleCustom.primaryColor)),
          home: Platform.isAndroid ? const SplashPage() : Main2Page(),
          navigatorKey: _navigatorKey,
      ))
  );

  void onMessageOpen(RemoteMessage message) => _bloc.add(MessageOpenEvent(message));

  void onMessage(RemoteMessage message) => _bloc.add(MessageEvent(message));

  void onCallSuggest(StreamResponseModel response, bool isSuggestCall) => _bloc.add(CallSuggestEvent(response, isSuggestCall: isSuggestCall));

  void _showDialog(String url) => UtilUI.showCustomDialog(_navigatorKey.currentContext, MultiLanguage.get('msg_new_version'),
      isActionCancel: true,title: MultiLanguage.get('ttl_notify')).then((value) {
    if (value != null && value) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  });
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
  if (message == null) return;
  if (message.data.containsKey('callId') && message.data['callId'].toString().isNotEmpty) {
    await fcmCallMessageCallBack(
      where: "onBackground",
      message: message,
    );
  }
}
