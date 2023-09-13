import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_taker/feedback.dart';
import 'package:location/location.dart';
import 'package:path/path.dart';

class FacultyInfoScreen extends StatefulWidget {
  @override
  final String email;

  const FacultyInfoScreen({super.key, required this.email});

  _FacultyInfoScreenState createState() => _FacultyInfoScreenState();
}

class _FacultyInfoScreenState extends State<FacultyInfoScreen> {
  String? facultyName;

  Future<void> storeLocationInFirestore(
      String email, LocationData location) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference ref = firestore.collection('faculties').doc(email);

    await ref.update(
        {'latitude': location.latitude, 'longitude': location.longitude});
  }

  Future<LocationData?> getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  Future<void> storeSubjectInFirestore(
      String subject, String? selectedClass) async {
    if (selectedClass == null) return; // Ensure a class is selected.

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference ref =
        firestore.collection('Attendance').doc(selectedClass);

    await ref.set({'subject': subject});
  }

  Future<String?> getFacultyNameByEmail(String email) async {
    DocumentReference facultyDocRef =
        FirebaseFirestore.instance.collection('faculties').doc(email);

    DocumentSnapshot facultyDoc = await facultyDocRef.get();

    if (facultyDoc.exists) {
      var data = facultyDoc.data() as Map<String, dynamic>;
      return data['name'] ?? null;
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    getCurrentLocation().then((location) {
      if (location != null) {
        storeLocationInFirestore(widget.email, location);
      }
    });

    getFacultyNameByEmail(widget.email).then((name) {
      setState(() {
        facultyName = name;
      });
    });
  }

  final TextEditingController _controller = TextEditingController();
  String? _selectedValue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(56, 53, 128, 1),
          title: Center(
            child: Text(
              "Faculty Info...",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          )),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/people.png',
                    height: 150,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text("Faculty Name : $facultyName",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text("Class: ",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 35,
                    ),
                    DropdownButton<String>(
                      value: _selectedValue,
                      hint: Text(
                        'Select an option',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      items: <String>[
                        'CSE-DS 2nd Yr',
                        'CSE-DS 3rd Yr',
                        'CSE-IoT 3rd Yr',
                        'IT1 2nd Yr',
                        'IT2 2nd Yr',
                        'IT1 3rd Yr',
                        'IT2 3rd Yr',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedValue = newValue;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text("Subject : ",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            hintText: 'Enter text',
                            hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      String subject = _controller.text;
                      await storeSubjectInFirestore(subject, _selectedValue);
                      // Optional: You can show a snackbar or any feedback to the user here.
                    },
                    child: Text(
                      'Send Link',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Show Feedback',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
