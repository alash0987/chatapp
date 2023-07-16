import 'package:chatapp/api/api.dart';
import 'package:chatapp/cores/snackbars/snackbar.dart';
import 'package:chatapp/features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  isLoadingGoogleSignProvider() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount? get user => _user;
  googleLogin(BuildContext context) async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await Apis.auth.signInWithCredential(credential);
      // ignore: use_build_context_synchronously
      notifyListeners();
    } catch (error) {
      // print(error.toString());
      SnackbarDialog.showSnackbar(context, error.toString());

      debugPrint(error.toString());
    }
    notifyListeners();
  }

  Future googleLogout(context) async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect().then((value) {
      Navigator.pop(context);
      Navigator.pop(context);

      Apis.auth = FirebaseAuth.instance;

      // Navigator.pushNamed(context, '/login_screen');
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    });
  }
}
