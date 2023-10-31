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
import 'function.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final userDetails = await getUserDetails();
  runApp(MyApp(
    initialEmail: userDetails['email'],
    initialDocumentName: userDetails['documentName'],
  ));
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class MyApp extends StatelessWidget {
  final String? initialEmail;
  final String? initialDocumentName;
  const MyApp({this.initialEmail, this.initialDocumentName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'Splash',
      routes: {
        'Splash': (context) => SplashScreen(
              initialEmail: initialEmail,
              initialDocumentName: initialDocumentName,
            ),
        'HomeScreenStudent': (context) => HomeScreenStudent(
              email: '',
              collectionName: '',
              documentName: '',
            ),
        'FacultyInfoScreen': (context) => FacultyInfoScreen(
              email: '',
            ),
      },
    );
  }
}

Future<Map<String, String?>> getUserDetails() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('userEmail');
  final docName = prefs.getString('documentName');
  print("Retrieved email from SharedPreferences: $email");
  print("Retrieved documentName from SharedPreferences: $docName");
  return {
    'email': email,
    'documentName': docName,
  };
}

// Splash Screen Code //
class SplashScreen extends StatefulWidget {
  final String? initialEmail;
  final String? initialDocumentName;
  const SplashScreen({Key? key, this.initialEmail, this.initialDocumentName})
      : super(key: key);

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
                collectionName: '',
                documentName: widget.initialDocumentName ?? '',
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
