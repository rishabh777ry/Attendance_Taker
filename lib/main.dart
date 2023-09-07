import 'dart:async';
import 'package:attendance_taker/home_screen_student.dart';
import 'package:attendance_taker/login_page.dart';
import 'package:attendance_taker/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attendance_taker/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Attend());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class Attend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'Splash',
      routes: {
        'Splash': (context) => SplashScreen(),
        'HomeScreenStudent': (context) => HomeScreenStudent(),
        'FacultyInfoScreen': (context) => FacultyInfoScreen(),
      },
      theme: ThemeData(fontFamily: 'Gorgeous'),
    );
  }
}

// Splash Screen Code //
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Attendance Taker",
            style: TextStyle(
                fontFamily: 'Gorgeous',
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Color.fromRGBO(56, 53, 128, 1),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Center(
          child: Image.asset(
            'assets/images/acro_logo.png',
          ),
        ),
      ),
    );
  }
}
