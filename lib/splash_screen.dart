// import 'package:untitled2/Api/apies.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:untitled2/screens/auth/login_screen.dart';
// import 'package:untitled2/screens/home_screen.dart';
// import '../../main.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//
//     // 2 sec delay, phir HomeScreen
//     Future.delayed(const Duration(milliseconds: 2000), () {
//       // Status bar transparent + edge to edge
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//       SystemChrome.setSystemUIOverlayStyle(
//         const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
//       );
// if(APIs.auth.currentUser != null){
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (_) => const HomeScreen()),
//   );
// }
// else{
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (_) => const LoginScreen()),
//   );
// }
//       // Navigate to HomeScreen
//
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // mq ko build me initialize karo
//     mq = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // Logo
//           Positioned(
//             top: mq.height * 0.15,
//             right: mq.width * 0.25,
//             width: mq.width * 0.5,
//             child: Image.asset('assets/images/img.png'),
//           ),
//           // Footer text
//           Positioned(
//             bottom: mq.height * 0.15,
//             width: mq.width,
//             child: const Text(
//               'Just Made for u ❤️',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 19, color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
import 'package:untitled2/Api/apies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled2/screens/auth/login_screen.dart';
import 'package:untitled2/screens/home_screen.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  @override
  void initState() {

    // 1 sec delay, phir Home / Login
    Future.delayed(const Duration(milliseconds: 1000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.white,systemNavigationBarColor: Colors.white),
      );

      if (APIs.auth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          /// 🔥 LEFT → CENTER SLIDE LOGO
          Positioned(

            left:  mq.width * 0.25 ,
            top: mq.height * 0.15,
            width: mq.width * 0.5,
            child: Image.asset('assets/images/img.png'),
          ),

          /// Footer text
          Positioned(
            bottom: mq.height * 0.15,
            width: mq.width,
            child: const Text(
              'Hi 🤝️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
