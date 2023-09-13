import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class HomeScreenStudent extends StatefulWidget {
  final String email;
  const HomeScreenStudent({super.key, required this.email});

  @override
  State<HomeScreenStudent> createState() => _HomeScreenStudentState();
}

class _HomeScreenStudentState extends State<HomeScreenStudent> {
  Location location = new Location();

  double? latitude;
  double? longitude;

  String? studentName;
  String? Enrollment;
  Future<String?> getStudentNameByEmail(String email) async {
    DocumentReference ds3rdYrDocRef =
        FirebaseFirestore.instance.collection('students').doc('DS_3rd_YR');

    DocumentSnapshot ds3rdYrDoc = await ds3rdYrDocRef.get();

    if (ds3rdYrDoc.exists) {
      var data = ds3rdYrDoc.data() as Map<String, dynamic>;
      List<dynamic> studentsList = data['students'] ?? [];

      for (var student in studentsList) {
        if (student['Email'] == email) {
          Enrollment = student['Enrollment number'];
          return student['Name'];
        }
      }
    }

    return null;
  }

  String email = '';
  @override
  void initState() {
    super.initState();
    fetchLocation();
    email = widget.email;
    getStudentNameByEmail(email).then((name) {
      setState(() {
        studentName = name;
      });
    });
  }

  Future<void> updateLocationInFirestore(
      String email, double? lat, double? lng) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('students').doc('DS_3rd_YR');

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic> studentsList = data['students'] ?? [];

      for (int i = 0; i < studentsList.length; i++) {
        var student = studentsList[i];
        if (student['Email'] == email) {
          student['latitude'] = lat;
          student['longitude'] = lng;
          break;
        }
      }

      await docRef.update({'students': studentsList});
    }
  }

  Future<void> fetchLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      latitude = _locationData.latitude;
      longitude = _locationData.longitude;
    });
    updateLocationInFirestore(widget.email, latitude, longitude);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(56, 53, 128, 1),
          title: Center(
            child: Text(
              'Student & Lecture Info...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          )),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/images/people.png',
                    height: 150,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text('Name: $studentName',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                Text('Enroll No. : $Enrollment',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                Text('Current Lecture: ',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 50),
                Center(
                  child: Text('Feedback:',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 15),
                TextFormField(
                  maxLines: 5,
                  onChanged: (value) {},
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  decoration: InputDecoration(
                    hintText: 'Enter your feedback...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle feedback submission logic here
                      var success = print('Feedback Submitted: ');
                    },
                    child: Text(
                      'Submit Feedback',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// Location Access Code

