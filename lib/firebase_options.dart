import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class FacultyInfoScreen extends StatefulWidget {
  @override
  _FacultyInfoScreenState createState() => _FacultyInfoScreenState();
}

class _FacultyInfoScreenState extends State<FacultyInfoScreen> {
  String facultyName = "Dr. John Doe";
  String lectureRoom = "Room 101";
  String className = "10th Grade";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Faculty Info")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Faculty's Name: $facultyName",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("Current Lecture Room: $lectureRoom",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text("Class: $className", style: TextStyle(fontSize: 18)),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Handle sending the link
              },
              child: Text('Send Link'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle showing feedback
              },
              child: Text('Show Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
