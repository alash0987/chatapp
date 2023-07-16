import 'package:chatapp/api/api.dart';
import 'package:chatapp/cores/providercommon/animated_icon_provider.dart';
import 'package:chatapp/cores/providercommon/searching_provider.dart';
import 'package:chatapp/features/app_provider/app_provider.dart';
import 'package:chatapp/features/auth/presentation/provider/google_sign_in_provider.dart';
import 'package:chatapp/features/auth/presentation/provider/show_emoji_provider.dart';
import 'package:chatapp/features/auth/presentation/screens/login_screen.dart';
import 'package:chatapp/features/pages/splash_screen.dart';
import 'package:chatapp/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:provider/provider.dart';

DateTime currentTime = DateTime.now().toLocal();
int hour = currentTime.hour;
int minute = currentTime.minute;
String time = '$hour:$minute';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarColor: Colors.blue, statusBarIconBrightness: Brightness.dark),
  );

  await _initialization();
  await Apis.getMe();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<SearchingProvider>(
        create: (_) => SearchingProvider()),
    ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
    ChangeNotifierProvider<ShowEmojiProvider>(
        create: (_) => ShowEmojiProvider()),
    ChangeNotifierProvider<AnimatedIconProvider>(
        create: (_) => AnimatedIconProvider()),
    ChangeNotifierProvider<GoogleSignInProvider>(
        create: (_) => GoogleSignInProvider())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/home_screen': (context) => const HomeScreen(),
        '/login_screen': (context) => const LoginScreen(),
      },
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(
        context: context,
      ),
    );
  }
}

_initialization() async {
  await Firebase.initializeApp();
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    id: 'yourchannelid',
    name: 'Chat App',
    description: 'Chat App Notification',
    importance: NotificationImportance.IMPORTANCE_HIGH,
  );
  debugPrint('-------------------result: $result ------------');
}
