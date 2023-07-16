// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/cores/providercommon/animated_icon_provider.dart';

import 'package:chatapp/features/auth/presentation/provider/google_sign_in_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Chat App'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Consumer<AnimatedIconProvider>(builder: (context, value, index) {
          context.read<AnimatedIconProvider>().isAnimateFunction();
          return Stack(
            children: [
              AnimatedPositioned(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 2000),
                top: size.height * 0.15,
                left: value.isAnimate ? -size.height * 0.35 : size.width * 0.45,
                width: size.width * 0.5,
                child: Image.asset('assets/images/chaticons.png'),
              ),
              Consumer<GoogleSignInProvider>(builder: (context, value, index) {
                return Positioned(
                    bottom: size.height * 0.15,
                    left: size.width * 0.05,
                    width: size.width * 0.9,
                    height: size.height * 0.08,
                    child: value.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton.icon(
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Image.asset(
                                'assets/images/googleicon.png',
                                height: size.height * .03,
                              ),
                            ),
                            label: RichText(
                              text: const TextSpan(
                                  text: 'Sign in with ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Google',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ]),
                            ),
                            onPressed: () async {
                              value.isLoadingGoogleSignProvider();
                              await value.googleLogin(context);
                              value.isLoadingGoogleSignProvider();
                              debugPrint('google.............................');
                              Navigator.pushNamed(context, '/home_screen');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.lightGreenAccent.withOpacity(0.7),
                              shape: const StadiumBorder(),
                              elevation: 1,
                            ),
                          ));
              })
            ],
          );
        }),
      ),
    );
  }
}
