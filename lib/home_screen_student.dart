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

double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371e3; // Earth radius in meters
  var phi1 = lat1 * (3.141592653589793 / 180.0); // Convert degrees to radians
  var phi2 = lat2 * (3.141592653589793 / 180.0);
  var deltaPhi = (lat2 - lat1) * (3.141592653589793 / 180.0);
  var deltaLambda = (lon2 - lon1) * (3.141592653589793 / 180.0);

  var a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
      cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
  var c = 2 * atan2(sqrt(a), sqrt(1 - a));
  var distance = R * c; // in meters

  return distance;
}

class HomeScreenStudent extends StatefulWidget {
  final String email;

  const HomeScreenStudent({Key? key, required this.email}) : super(key: key);

  @override
  State<HomeScreenStudent> createState() => _HomeScreenStudentState();
}

class _HomeScreenStudentState extends State<HomeScreenStudent> {
  Location location = Location();
  Timer? _locationTimer;
  final _feedbackController = TextEditingController();

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

  List<String> questions = [
    "Were you satisfied with the learning and content?",
    "Was it engaging, relevant, useful, and interesting?",
    "Did you find the medium of instruction to be best?",
    "Was the trainer knowledgeable on the topic?",
    "Was the trainer enthusiastic and friendly?",
    "Was the trainer engaging and supportive?",
    "Was the trainer easy to understand?",
    "Was the trainer prepared and organized well?",
    "Overall, how would you rate the trainer?"
  ];

  Map<String, int> questionRatings = {
    'Were you satisfied with the learning and content?': 0,
    'Was it engaging, relevant, useful, and interesting?': 0,
    'Did you find the medium of instruction to be best?': 0,
    'Was the trainer knowledgeable on the topic?': 0,
    'Was the trainer enthusiastic and friendly?': 0,
    'Was the trainer engaging and supportive?': 0,
    'Was the trainer easy to understand?': 0,
    'Was the trainer prepared and organized well?': 0,
    'Overall, how would you rate the trainer?': 0
  };

  @override
  void initState() {
    super.initState();

    fetchLocation();
  }

  Stream<Map<String, dynamic>> getStudentDataStream(String email) {
    DocumentReference ds3rdYrDocRef =
        FirebaseFirestore.instance.collection('students').doc('DS_3rd_YR');
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
      setState(() {
        latitude = currentLocation.latitude;
        longitude = currentLocation.longitude;
        storeLocation();
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
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

  Future<void> resetLocationToZero() async {
    final ds3rdYrDocRef =
        FirebaseFirestore.instance.collection('students').doc('DS_3rd_YR');

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(ds3rdYrDocRef);

        if (!snapshot.exists) {
          print('Error: DS_3rd_YR document not found.');
          throw Exception('DS_3rd_YR document not found.');
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> studentsList = List.from(data['students'] ?? []);
        print("Trying to store location for email: ${widget.email}");
        for (int i = 0; i < studentsList.length; i++) {
          print("Checking against stored email: ${studentsList[i]['Email']}");
          if (studentsList[i]['Email'] == widget.email) {
            print('Matched student with Email: ${widget.email}');
            studentsList[i]['flatitude'] = 0;
            studentsList[i]['flongitude'] = 0;
            transaction.update(ds3rdYrDocRef, {'students': studentsList});
            print(
                'Location reset successfully for student with Email: ${widget.email}');
            return;
          }
        }
        print('Student with Email ${widget.email} not found.');
      });
    } catch (error) {
      print('Error resetting location: $error');
    }
  }

  Future<void> storeLocation() async {
    try {
      final ds3rdYrDocRef =
          FirebaseFirestore.instance.collection('students').doc('DS_3rd_YR');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(ds3rdYrDocRef);

        if (!snapshot.exists) {
          throw Exception('DS_3rd_YR document not found.');
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> studentsList = List.from(data['students'] ?? []);

        for (int i = 0; i < studentsList.length; i++) {
          if (studentsList[i]['Email'] == widget.email) {
            studentsList[i]['latitude'] = latitude;
            studentsList[i]['longitude'] = longitude;
            transaction.update(ds3rdYrDocRef, {'students': studentsList});
            return;
          }
        }
        throw Exception('Student not found in the DS_3rd_YR document.');
      });
      print('Location stored successfully.');
    } catch (error) {
      print('Error while storing location: $error');
    }
  }

  Future<void> storeRatingsInFirestore() async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      await _firestore.collection('ratings').add(questionRatings);
      print('Ratings stored successfully in Firestore');
    } catch (e) {
      print('Error storing ratings: $e');
    }
  }

  Future<void> storeAttendance(String studentName, String enrollment) async {
    if (studentSubject != null && studentSubject!.isNotEmpty) {
      try {
        // Reference to the DS_3rd_YR document inside the Attendance collection
        final classDocRef = FirebaseFirestore.instance
            .collection('Attendance')
            .doc('DS_3rd_YR');

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
            'Attendance stored successfully for class DS_3rd_YR and subject $studentSubject');
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
                    groupValue: questionRatings[question],
                    onChanged: (int? value) {
                      setState(() {
                        questionRatings[question] = value!;
                      });
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
        final classDocRef =
            FirebaseFirestore.instance.collection('FeedBack').doc('DS_3rd_YR');

        DocumentSnapshot snapshot = await classDocRef.get();

        Map<String, dynamic> currentData =
            snapshot.data() as Map<String, dynamic> ?? {};
        List<dynamic> feedbacks = List.from(currentData[studentSubject!] ?? []);
        feedbacks.add(feedbackText);

        await classDocRef
            .set({studentSubject!: feedbacks}, SetOptions(merge: true));

        print(
            'Feedback stored successfully in the FeedBack collection for class DS_3rd_YR and subject $studentSubject');

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
              String localEnrollment =
                  snapshot.data?['Enrollment number'] ?? '';
              String localStudentSubject = snapshot.data?['subject'] ?? '';

              studentSubject = localStudentSubject;

              print("subject $localStudentSubject");

              bool isWithinRange = false;
              if (latitude != null &&
                  longitude != null &&
                  snapshot.data?['flatitude'] != null &&
                  snapshot.data?['flongitude'] != null) {
                double distance = haversineDistance(
                    latitude!,
                    longitude!,
                    double.tryParse(snapshot.data!['flatitude'].toString()) ??
                        0.0,
                    double.tryParse(snapshot.data!['flongitude'].toString()) ??
                        0.0);
                print("Faculty Latitude: ${snapshot.data!['flatitude']}");
                print("Faculty Longitude: ${snapshot.data!['flongitude']}");
                print("Current Latitude: $latitude");
                print("Current Longitude: $longitude");
                print("Calculated Distance: $distance");

                // Radius Code is Here!!
                isWithinRange = distance <= 7;
              }

              // Combine both conditions
              bool canSubmitFeedback = isWithinRange;

              return SingleChildScrollView(
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
                      ...questions.map((q) => questionWithRatings(q)).toList(),
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
                          onPressed: canSubmitFeedback
                              ? () async {
                                  String feedbackText =
                                      _feedbackController.text;
                                  storeFeedback(feedbackText).then((_) {
                                    print('Feedback saved.');
                                    storeAttendance(
                                        localStudentName, localEnrollment);
                                    accessSheet(localEnrollment);
                                    resetLocationToZero();
                                    storeRatingsInFirestore();
                                  });
                                }
                              : null, // The button will be disabled if the student is not within the 7-meter range
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
              );
            }
          },
        ));
  }
}
