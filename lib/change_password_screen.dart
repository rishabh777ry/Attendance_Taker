import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV to Firestore Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UploadStudents(),
    );
  }
}

class UploadStudents extends StatefulWidget {
  @override
  _UploadStudentsState createState() => _UploadStudentsState();
}

class _UploadStudentsState extends State<UploadStudents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    uploadStudentsFromCSV();
  }

  Future<void> uploadStudentsFromCSV() async {
    try {
      // Load the CSV data
      final ByteData data = await rootBundle.load('assets/data.csv');
      final List<List<dynamic>> csvTable = CsvToListConverter()
          .convert(String.fromCharCodes(data.buffer.asUint8List()));

      List<Map<String, dynamic>> studentsList = [];

      for (int i = 1; i < csvTable.length; i++) {
        studentsList.add({
          'Name': csvTable[i][0],
          'Enrollment number': csvTable[i][1],
          'Email': csvTable[i][2].toString(),
        });
      }

      DocumentReference docRef =
          _firestore.collection('students').doc('DS_3rd_YR');

      await docRef.set({'students': FieldValue.arrayUnion(studentsList)},
          SetOptions(merge: true));

      print("Student data uploaded successfully!");
    } catch (error) {
      print("Error uploading student data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSV to Firestore Example'),
      ),
      body: Center(
        child: Text('Check your console for upload status!'),
      ),
    );
  }
}
