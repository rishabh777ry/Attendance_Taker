import 'package:attendance_taker/home_screen_faculty.dart';
import 'package:attendance_taker/home_screen_student.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserChoice { student, faculty }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserChoice? _selectedChoice;
  late String email;
  late String password;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  Future<bool> isFacultyEmailExists(String email) async {
    DocumentReference facultyDocRef =
        FirebaseFirestore.instance.collection('faculties').doc(email);

    DocumentSnapshot facultyDoc = await facultyDocRef.get();

    return facultyDoc.exists;
  }

  Future<bool> isEmailInStudentsList(String email) async {
    DocumentReference ds3rdYrDocRef =
        FirebaseFirestore.instance.collection('students').doc('DS_3rd_YR');

    DocumentSnapshot ds3rdYrDoc = await ds3rdYrDocRef.get();

    if (ds3rdYrDoc.exists) {
      var data = ds3rdYrDoc.data() as Map<String, dynamic>;
      List<dynamic> studentsList = data['students'] ?? [];

      for (var student in studentsList) {
        if (student['Email'] == email) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> saveUserSession(String email, UserChoice choice) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      prefs.setString(
          'userType', choice == UserChoice.student ? 'student' : 'faculty');
    } catch (e) {
      print("Error saving to SharedPreferences: $e");
    }
  }

  Future<String?> logIn(String email, String password) async {
    try {
      setState(() {
        isLoading = true;
      });

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      setState(() {
        isLoading = false;
      });

      return null;
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(56, 53, 128, 1),
          title: Center(
            child: Text(
              "Attendance Taker",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          )),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(right: 35, left: 35),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/attendance.png',
                        width: 150,
                        height: 200,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    TextField(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          fillColor: Colors.grey,
                          hintText: 'UserName ',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    TextField(
                      obscureText: true,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          hintText: 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Select Your Choice :",
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: const Text(
                            'Student',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                          leading: Radio(
                            value: UserChoice.student,
                            groupValue: _selectedChoice,
                            onChanged: (UserChoice? value) {
                              setState(() {
                                _selectedChoice = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text(
                            'Faculty',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                          leading: Radio(
                            value: UserChoice.faculty,
                            groupValue: _selectedChoice,
                            onChanged: (UserChoice? value) {
                              setState(() {
                                _selectedChoice = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                              fontSize: 30,
                              color: Color.fromRGBO(56, 53, 128, 1),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Color.fromRGBO(56, 53, 128, 1),
                          child: IconButton(
                            onPressed: () async {
                              if (email != null &&
                                  password != null &&
                                  _selectedChoice != null) {
                                String? result = await logIn(email, password);

                                if (result == null) {
                                  if (_selectedChoice == UserChoice.student) {
                                    bool isEmailValid =
                                        await isEmailInStudentsList(email);
                                    if (isEmailValid) {
                                      await saveUserSession(
                                          email, UserChoice.student);
                                      print(
                                          "Saving email to SharedPreferences: $email");
                                      final prefsTest =
                                          await SharedPreferences.getInstance();
                                      print(
                                          "Saved email: ${prefsTest.getString('userEmail')}");
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreenStudent(
                                                      email: email)));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Email not found in the list of students'),
                                        ),
                                      );
                                    }
                                  } else if (_selectedChoice ==
                                      UserChoice.faculty) {
                                    bool isFacultyEmailValid =
                                        await isFacultyEmailExists(email);
                                    if (isFacultyEmailValid) {
                                      await saveUserSession(
                                          email, UserChoice.faculty);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FacultyInfoScreen(
                                                      email: email)));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Email not found in the list of faculties'),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Login failed: Incorrect email/Password!')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please fill in all fields and select a user type')),
                                );
                              }
                            },
                            icon: Icon(Icons.arrow_forward),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            if (isLoading)
              // This creates a layer on top of your current UI
              Container(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
