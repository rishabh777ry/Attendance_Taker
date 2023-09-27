import 'dart:async';
import 'package:attendance_taker/home_screen_student.dart';
import 'package:attendance_taker/login_page.dart';
import 'package:attendance_taker/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attendance_taker/home_screen_faculty.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final email = await getUserEmail();
  print("Retrieved email from SharedPreferences: $email");
  runApp(Attend(
    initialEmail: email,
  ));
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class Attend extends StatelessWidget {
  final String? initialEmail;
  Attend({this.initialEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'Splash',
      routes: {
        'Splash': (context) => SplashScreen(initialEmail: initialEmail),
        'HomeScreenStudent': (context) => HomeScreenStudent(
              email: '',
            ),
        'FacultyInfoScreen': (context) => FacultyInfoScreen(
              email: '',
            ),
      },
    );
  }
}

Future<String?> getUserEmail() async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    print("Retrieved email from SharedPreferences: $email");
  } catch (e) {
    print("Error retrieving email from SharedPreferences: $e");
  }

  return prefs.getString('userEmail');
}

// Splash Screen Code //
class SplashScreen extends StatefulWidget {
  final String? initialEmail;
  const SplashScreen({Key? key, this.initialEmail}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      _navigateUser();
    });
  }

  _navigateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print("isLoggedIn: $isLoggedIn");

    if (isLoggedIn) {
      String userType = prefs.getString('userType') ?? '';
      print("userType: $userType");
      if (userType == 'student') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreenStudent(
                email: widget.initialEmail ?? '',
              ),
            ));
      } else if (userType == 'faculty') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FacultyInfoScreen(
                email: widget.initialEmail ?? '',
              ),
            ));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } else {
      Timer(Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      });
    }
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
