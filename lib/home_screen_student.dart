import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'excel.dart';
import 'change_password_screen.dart';
import 'function.dart';
import 'package:flutter/rendering.dart';

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

class QuestionRating extends StatefulWidget {
  final String question;
  final ValueNotifier<int> value;
  final ValueChanged<int> onChanged;
  final Map<String, int> finalizedRatings;
  final List<Map<String, dynamic>> ratings;

  const QuestionRating({
    required this.question,
    required this.value,
    required this.onChanged,
    required this.ratings,
    required this.finalizedRatings,
  });

  @override
  _QuestionRatingState createState() => _QuestionRatingState();
}

class _QuestionRatingState extends State<QuestionRating> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Row(
          children: widget.ratings.map((ratingData) {
            return Expanded(
              child: Column(
                children: [
                  Radio<int>(
                    value: ratingData['rating'],
                    groupValue: widget.value.value,
                    onChanged: (int? newValue) {
                      widget.value.value = newValue!;
                      widget.onChanged(newValue);
                      widget.finalizedRatings[widget.question] = newValue;
                    },
                  ),
                  Text(ratingData['description']),
                ],
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class HomeScreenStudent extends StatefulWidget {
  final String email;
  final String collectionName;
  final String documentName;

  const HomeScreenStudent(
      {Key? key,
      required this.email,
      this.documentName = '',
      required this.collectionName // Add this line
      })
      : super(key: key);

  @override
  State<HomeScreenStudent> createState() => _HomeScreenStudentState();
}

class _HomeScreenStudentState extends State<HomeScreenStudent> {
  Location location = Location();
  Timer? _locationTimer;
  String? _localDocumentName;
  final _feedbackController = TextEditingController();

  ValueNotifier<LocationData?> locationNotifier = ValueNotifier(null);
  ValueNotifier<int?> attendanceNotifier = ValueNotifier<int?>(null);

  double? latitude;
  double? longitude;
  String? studentSubject;
  int? _selectedRating;
  String? _selectedDescription;
  List<Map<String, dynamic>> ratings = [
    {'rating': 1, 'description': 'Strongly Disagree'},
    {'rating': 2, 'description': 'Disagree'},
    {'rating': 3, 'description': 'Fair'},
    {'rating': 4, 'description': 'Agree'},
    {'rating': 5, 'description': 'Strongly Agree'},
  ];

  Map<String, ValueNotifier<int>> questionRatings = {
    'Were you satisfied with the learning and content?': ValueNotifier<int>(0),
    'Was it engaging, relevant, useful, and interesting?':
        ValueNotifier<int>(0),
    'Did you find the medium of instruction to be best?': ValueNotifier<int>(0),
    'Was the trainer knowledgeable on the topic?': ValueNotifier<int>(0),
    'Was the trainer enthusiastic and friendly?': ValueNotifier<int>(0),
    'Was the trainer engaging and supportive?': ValueNotifier<int>(0),
    'Was the trainer easy to understand?': ValueNotifier<int>(0),
    'Was the trainer prepared and organized well?': ValueNotifier<int>(0),
    'Overall, how would you rate the trainer?': ValueNotifier<int>(0),
  };

  Map<String, int> finalizedRatings = {};

  List<LatLng> buildingPolygon = [
    LatLng(22.817937, 75.940425),
    LatLng(22.817904, 75.944569),
    LatLng(22.820794, 75.944523),
    LatLng(22.822810, 75.944678),
    LatLng(22.823511, 75.942538),
    LatLng(22.821979, 75.942039),
  ];

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool isInside = false;
    int i = 0;
    int j = polygon.length - 1;

    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].longitude < point.longitude &&
              polygon[j].longitude >= point.longitude) ||
          (polygon[j].longitude < point.longitude &&
              polygon[i].longitude >= point.longitude)) {
        if (polygon[i].latitude +
                (point.longitude - polygon[i].longitude) /
                    (polygon[j].longitude - polygon[i].longitude) *
                    (polygon[j].latitude - polygon[i].latitude) <
            point.latitude) {
          isInside = !isInside;
        }
      }
      j = i;
    }

    return isInside;
  }

  bool isUserInsideBuilding() {
    if (locationNotifier.value != null &&
        locationNotifier.value!.latitude != null &&
        locationNotifier.value!.longitude != null) {
      return isPointInPolygon(
        LatLng(locationNotifier.value!.latitude!,
            locationNotifier.value!.longitude!),
        buildingPolygon,
      );
    }
    return false;
  }

  bool allQuestionsAnswered() {
    return questionRatings.values.every((notifier) => notifier.value != 0);
  }

  @override
  void initState() {
    super.initState();
    _initializeDocumentName();
    fetchLocation();
    getAttendanceValue().then((value) {
      attendanceNotifier.value = value;
    });

    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchLocation();
    });
  }

  void _initializeDocumentName() async {
    final prefs = await SharedPreferences.getInstance();
    final docName = prefs.getString('documentName');
    if (docName != null && docName.isNotEmpty) {
      setState(() {
        _localDocumentName = docName;
      });
    }
  }

  Stream<Map<String, dynamic>> getStudentDataStream(String email) {
    DocumentReference ds3rdYrDocRef = FirebaseFirestore.instance
        .collection('students')
        .doc(widget.documentName);
    return ds3rdYrDocRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> studentsList =
            data.containsKey('students') && data['students'] is List
                ? data['students']
                : [];
        for (var student in studentsList) {
          if (student['Email'] == email) {
            return student;
          }
        }
      }
      return {};
    });
  }

  Future<void> fetchLocation() async {
    try {
      LocationData currentLocation = await location.getLocation();
      locationNotifier.value = currentLocation;
      storeLocation();
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<int?> getAttendanceValue() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(widget.documentName)
        .get();
    Map<String, dynamic>? data =
        doc.data() as Map<String, dynamic>?; // Explicit cast
    List<dynamic> studentsList = data?['students'] ?? [];
    for (var student in studentsList) {
      if (student is Map && student['Email'] == widget.email) {
        // Check if student is a Map
        return student['attendance'] as int?;
      }
    }
    return null;
  }

  Future<void> setAttendanceValue(int value) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('students')
        .doc(widget.documentName);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception(' document not found.');
      }
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> studentsList = List.from(data['students'] ?? []);
      for (int i = 0; i < studentsList.length; i++) {
        if (studentsList[i]['Email'] == widget.email) {
          studentsList[i]['attendance'] = value;
          transaction.update(docRef, {'students': studentsList});
          return;
        }
      }
      throw Exception('Student not found in the  document.');
    });
    print('Attendance value updated.');
  }

  Widget buildRatingButtonsWithDescription() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ratings.map((ratingData) {
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<int>(
                value: ratingData['rating'],
                groupValue: _selectedRating,
                onChanged: (int? value) {
                  setState(() {
                    _selectedRating = value;
                    _selectedDescription = ratingData['description'];
                  });
                },
              ),
              Text(ratingData['description'])
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<String?> getDocumentNameFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('documentName');
  }

  Future<void> storeLocation() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('students')
          .doc(widget.documentName);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception(' document not found.');
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> studentsList = List.from(data['students'] ?? []);

        for (int i = 0; i < studentsList.length; i++) {
          if (studentsList[i]['Email'] == widget.email) {
            studentsList[i]['latitude'] = latitude;
            studentsList[i]['longitude'] = longitude;
            transaction.update(docRef, {'students': studentsList});
            return;
          }
        }
        throw Exception('Student not found in the  document.');
      });
      print('Location stored successfully.');
    } catch (error) {
      print('Error while storing location: $error');
    }
  }

  Future<void> storeRatingsInFirestore() async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;

      // Prepare user ratings data
      Map<String, dynamic> userRating = {widget.email: finalizedRatings};

      // Reference to the appropriate document in the Rating collection
      DocumentReference docRef =
          _firestore.collection('ratings').doc(widget.documentName);

      // Atomically add a new user rating to the subject's array
      await docRef.update({
        '$studentSubject': FieldValue.arrayUnion([userRating])
      });

      print('Ratings stored successfully in Firestore');
    } catch (e) {
      print('Error storing ratings: $e');
    }
  }

  Future<void> storeAttendance(String studentName, String enrollment) async {
    if (studentSubject != null && studentSubject!.isNotEmpty) {
      try {
        // Reference to the  document inside the Attendance collection
        final classDocRef = FirebaseFirestore.instance
            .collection('Attendance')
            .doc(widget.documentName);

        DocumentSnapshot snapshot = await classDocRef.get();

        Map<String, dynamic> currentData =
            snapshot.data() as Map<String, dynamic>;

        // Fetch the current attendance map array or initialize a new one if it doesn't exist
        List<dynamic> attendanceList =
            List.from(currentData[studentSubject!] ?? []);

        // Create a map with student details
        Map<String, dynamic> studentDetails = {
          'name': studentName,
          'Enrollment': enrollment
        };

        // Add student details to the list
        attendanceList.add(studentDetails);

        // Update the document with the modified attendance list
        await classDocRef
            .set({studentSubject!: attendanceList}, SetOptions(merge: true));

        print(
            'Attendance stored successfully for class  and subject $studentSubject');
      } catch (error) {
        print('Error while storing attendance: $error');
      }
    } else {
      print('studentSubject is null or empty');
    }
  }

  Widget questionWithRatings(String question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Row(
          children: ratings.map((ratingData) {
            return Expanded(
              child: Column(
                children: [
                  Radio<int>(
                    value: ratingData['rating'],
                    groupValue: questionRatings[question]
                        ?.value, // Read value from the ValueNotifier.
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          questionRatings[question]?.value =
                              value; // Update the value inside the ValueNotifier.
                        });
                      }
                    },
                  ),
                  Text(ratingData['description']),
                ],
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Future<void> storeFeedback(String feedbackText) async {
    if (studentSubject != null && studentSubject!.isNotEmpty) {
      try {
        final classDocRef = FirebaseFirestore.instance
            .collection('FeedBack')
            .doc(widget.documentName);

        DocumentSnapshot snapshot = await classDocRef.get();

        Map<String, dynamic> currentData =
            snapshot.data() as Map<String, dynamic> ?? {};
        List<dynamic> feedbacks = List.from(currentData[studentSubject!] ?? []);
        feedbacks.add(feedbackText);

        await classDocRef
            .set({studentSubject!: feedbacks}, SetOptions(merge: true));

        print(
            'Feedback stored successfully in the FeedBack collection for class  and subject $studentSubject');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your feedback is stored. You cannot submit another feedback.',
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      } catch (error) {
        print('Error while storing feedback: $error');
      }
    } else {
      print('studentSubject is null or empty');
    }
  }

  Widget build(BuildContext context) {
    print("Logged in student email: ${widget.email}");
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(56, 53, 128, 1),
          title: Center(
            child: Text(
              'Student & Lecture Info.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          )),
      body: StreamBuilder<Map<String, dynamic>>(
          stream: getStudentDataStream(widget.email),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              String localStudentName = snapshot.data?['Name'] ?? '';
              String localEnrollment = snapshot.data?['EnrollmentNumber'] ?? '';
              String localStudentSubject = snapshot.data?['subject'] ?? '';
              String sheetId = snapshot.data?['sheetId'] ?? '';

              studentSubject = localStudentSubject;

              print("subject $localStudentSubject");

              return ListView(
                children: [
                  Padding(
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
                        SizedBox(height: 15),
                        Text('Name: $localStudentName',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),
                        Text('Enroll No. : $localEnrollment',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),
                        Text('Subject: $localStudentSubject',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 50),
                        Center(
                          child: Text('Feedback:',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 15),
                        ...questionRatings.entries
                            .map((entry) => QuestionRating(
                                  question: entry.key,
                                  value: entry.value,
                                  onChanged: (int? value) {
                                    if (value != null) {
                                      setState(() {
                                        entry.value.value = value;
                                      });
                                    }
                                  },
                                  ratings: ratings,
                                  finalizedRatings: finalizedRatings,
                                ))
                            .toList(),
                        SizedBox(height: 30),
                        TextFormField(
                          controller: _feedbackController,
                          maxLines: 5,
                          onChanged: (value) {},
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                          decoration: InputDecoration(
                            hintText: 'Enter your feedback...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: (attendanceNotifier.value == 1 &&
                                    isUserInsideBuilding() &&
                                    allQuestionsAnswered())
                                ? () async {
                                    String feedbackText =
                                        _feedbackController.text;
                                    await storeFeedback(feedbackText);
                                    await storeRatingsInFirestore();

                                    print('Feedback saved.');
                                    await storeAttendance(
                                        localStudentName, localEnrollment);
                                    accessSheet(sheetId, localEnrollment);
                                    await setAttendanceValue(0);
                                    attendanceNotifier.value =
                                        0; // Update the notifier's value
                                  }
                                : null,
                            child: Text(
                              'Submit Feedback',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
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
                                        builder: (context) =>
                                            PasswordChangeScreen()));
                                if (result != null && result is String) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result)),
                                  );
                                }
                              },
                              child: Text(
                                'Change Password',
                                style:
                                    TextStyle(fontSize: 22, color: Colors.blue),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
