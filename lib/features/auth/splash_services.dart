// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashServices {
  isLogin(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    Apis.auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // debugPrint('User details ${auth.currentUser}');
        // User is signed in, redirect to home screen
        if ((await Apis.userExists())) {
          await Apis.getMe();
          Apis.updateActiveStatus(true);
          SystemChannels.lifecycle.setMessageHandler((msg) async {
            if (msg == AppLifecycleState.resumed.toString()) {
              await Apis.updateActiveStatus(true);
            } else if (msg == AppLifecycleState.paused.toString()) {
              await Apis.updateActiveStatus(false);
            }
            return null;
          });

          await Apis.getMe();
          Timer(const Duration(seconds: 1), () {
            Navigator.pushNamed(context, '/home_screen');
          });
        } else {
          await Apis.createUser().then((value) async {
            await Apis.getMe();

            Timer(const Duration(seconds: 1), () {
              Navigator.pushNamed(context, '/home_screen');
            });
          });
        }
      } else {
        Timer(const Duration(seconds: 1), () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        });
      }
    });
  }
}
