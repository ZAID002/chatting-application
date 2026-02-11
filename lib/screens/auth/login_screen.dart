import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled2/screens/home_screen.dart';
import '../../Api/apies.dart';
import '../../helper/dialogs.dart';
import 'package:untitled2/main.dart';
import 'package:untitled2/helper/progress_bar_fix.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;

      });

    });
  }

  _HandleGoggleBtnClick() {
    Fix.showprogress(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user != null){ log('\nUser:${user.user}');
      log('\nUserAdditionalInfo:${user.additionalUserInfo}');
      if((await APIs.userExists())){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );}
      else{
          await APIs.createUser().then((value){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          });
      }
      }


    });
  }
  Future<UserCredential?> _signInWithGoogle() async {
    try{
await InternetAddress.lookup('google.com');
      // 1. GoogleSignIn ka instance banaya Client ID ke sath
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // SERVER CLIENT ID FORM FIREBASE
        serverClientId: "686472546707-3gg07sh80rrn11ib2dklii69jfjrb88h.apps.googleusercontent.com",
      );

      // 2. SHOW TGE GOOGLE LOGIN SCREEN TO USER
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // IF USER CANCEL THE LOGIN
      if (googleUser == null) {
        throw Exception('Google Sign-In aborted by user');
      }

      // 3. Auth details nikalna
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 4. Credential banana
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Firebase mein login karna
      return await FirebaseAuth.instance.signInWithCredential(credential);

    }catch(e){
    log('\n_signInWithGoogle():$e');
    // internet connectin check will show snack bar from dialogs.dart
    Dialogs.showsnackbar(context,'Check your Internet Connection');
    return null;
  }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Zee Chat')),
      body: Stack(
        children: [
          //logo set
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,

            child: Image.asset('assets/images/img.png'),
          ),
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .06,
            child: ElevatedButton.icon(
              onPressed: () {
                _HandleGoggleBtnClick();
              },
              icon: Image.asset(
                'assets/images/google.png',
                height: mq.height * .03,
              ),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),

                  children: [
                    TextSpan(text: 'Login with'),
                    TextSpan(text: ' '),
                    TextSpan(
                      text: 'Google',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 1,
                backgroundColor: Color.fromARGB(255, 223, 255, 187),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
