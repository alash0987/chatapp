import 'package:chatapp/features/auth/splash_services.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final BuildContext context;

  const SplashScreen({Key? key, required this.context}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SplashServices().isLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Center(
          child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2.0,
      )),
    ));
  }
}
