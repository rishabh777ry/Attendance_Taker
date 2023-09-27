import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'change_password_screen.dart';

class FacultyInfoScreen extends StatefulWidget {
  final String email;

  const FacultyInfoScreen(
      {Key? key, required this.email, LocationData? location})
      : super(key: key);

  @override
  _FacultyInfoScreenState createState() => _FacultyInfoScreenState();
}

class _FacultyInfoScreenState extends State<FacultyInfoScreen>
    with WidgetsBindingObserver {
  String? facultyName;
  bool _isLoading = false;
  LocationData? currentLocation;

  final TextEditingController _controller = TextEditingController();
  String? _selectedValue;

  Future<bool> addSubjectToAllStudents(String subjectText) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference docRef =
          firestore.collection('students').doc('DS_3rd_YR');

      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        Map<String, dynamic>? dataMap =
            snapshot.data() as Map<String, dynamic>?;
        var rawData = dataMap?['students'];
        List<dynamic> students = (rawData is List<dynamic>) ? rawData : [];

        for (var i = 0; i < students.length; i++) {
          if (students[i] is Map<String, dynamic>) {
            (students[i] as Map<String, dynamic>)['subject'] = subjectText;
          }
        }

        await docRef.update({'students': students});
        return true;
      }
    } catch (e) {
      print("Error while adding subject: $e");
    }
    return false;
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

    try {
      LocationData _locationData = await location.getLocation();
      setState(() {
        currentLocation = _locationData;
      });
      await storeLocationInFirestore(widget.email, _locationData);
      print(" Faculty location is : $_locationData");
      return _locationData;
    } catch (e) {
      print("Error fetching location: $e");
      return null;
    }
  }

  Future<void> storeLocationInFirestore(
      String email, LocationData location) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef =
        firestore.collection('students').doc('DS_3rd_YR');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('DS_3rd_YR document not found.');
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> studentsList = List.from(data['students'] ?? []);

      for (int i = 0; i < studentsList.length; i++) {
        if (studentsList[i] is Map<String, dynamic>) {
          (studentsList[i] as Map<String, dynamic>)['flatitude'] =
              location.latitude;
          (studentsList[i] as Map<String, dynamic>)['flongitude'] =
              location.longitude;
        }
      }

      transaction.update(docRef, {'students': studentsList});
    });
    print('Faculty location stored successfully for all students.');
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
    getCurrentLocation();
    getFacultyNameByEmail(widget.email).then((name) {
      setState(() {
        facultyName = name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(56, 53, 128, 1),
        title: Center(
          child: Text(
            "Faculty Info.",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
      ),
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
                SizedBox(height: 30),
                Text(
                  "Faculty Name : $facultyName",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "Class: ",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
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
                        'CSE-DS 2nd YR',
                        'CSE-DS 3rd YR',
                        'CSE-IoT 3rd YR',
                        'IT1 2nd YR',
                        'IT2 2nd YR',
                        'IT1 3rd YR',
                        'IT2 3rd YR',
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
                    Text(
                      "Subject : ",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Enter subject',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true; // Set to loading state
                            });
                            getCurrentLocation();
                            bool success =
                                await addSubjectToAllStudents(_controller.text);
                            setState(() {
                              _isLoading =
                                  false; // Reset to idle state after operation
                            });
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'The link has been sent to the students present in the class.'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to send link. Please try again.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => UploadStudents()));

                        if (result != null && result is String) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );
                        }
                      },
                      child: Text(
                        'Change Password',
                        style: TextStyle(fontSize: 22, color: Colors.blue),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
