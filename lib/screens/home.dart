import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quaidtech/components/dailyAttendancedetails.dart';
import 'package:quaidtech/components/dailyNullAttend.dart';
import 'package:quaidtech/components/monthlyattendance.dart';
import 'package:quaidtech/screens/Checkin.dart';
import 'package:quaidtech/screens/notification.dart';
import 'package:quaidtech/screens/profile.dart';
import 'package:quaidtech/screens/stastics.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

typedef CloseCallback = Function();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _imageUrl;
  int _selectedIndex = 0;

  Map<String, dynamic>? data;
  List<Map<String, dynamic>> weeklyData = [];
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final Map<DateTime, List<Color>> _events = {
    DateTime.utc(2024, 10, 1): [const Color(0xff8E71DF)],
    DateTime.utc(2024, 10, 2): [const Color(0xffF6C15B)],
  };

  List<Color> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Future<Map<String, dynamic>?> _getAttendanceDetails(
      String uid, DateTime day) async {
    String formattedDate = DateFormat('yMMMd').format(day);

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('AttendanceDetails')
            .doc(userId)
            .collection('dailyattendance')
            .doc(formattedDate)
            .get();

    if (snapshot.exists) {
      return snapshot.data();
    }
    return null;
  }

  void _showAttendanceDetails(Map<String, dynamic> data) {
    log(' data1 $data', name: 'Logg');
    DateTime? checkInTime = (data['checkIn'] != null)
        ? (data['checkIn'] as Timestamp).toDate()
        : null;
    DateTime? checkOutTime = (data['checkOut'] != null)
        ? (data['checkOut'] as Timestamp).toDate()
        : null;

    if (checkOutTime != null && checkInTime != null) {
      checkOutTime.difference(checkInTime);
    } else {}
  }

  void _showNoDataMessage() {
    log('No attendance data available for the selected day');
  }

  @override
  void initState() {
    super.initState();
    _onItemTapped(0);
    _loadUserProfile();
    _onDaySelected(_selectedDay, _focusedDay);
    _getAttendanceDetails(userId, DateTime.now());
    _fetchEventsForMonth(userId);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _isLoading = true;
    });
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      data = await _getAttendanceDetails(userId, selectedDay);
      setState(() {
        _isLoading = false;
        if (data != null) {
          _showAttendanceDetails(data!);
        } else {
          _showNoDataMessage();
        }
      });
    } catch (e) {
      log('Error fetching attendance details: $e');
      setState(() {
        _isLoading = false;
        _showNoDataMessage();
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchEventsForMonth(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final attendanceCollection = FirebaseFirestore.instance
        .collection('AttendanceDetails')
        .doc(userId)
        .collection('dailyattendance');

    try {
      // Find the user's first check-in for the current month
      final firstCheckInSnapshot = await attendanceCollection
          .where('checkIn', isGreaterThanOrEqualTo: startOfMonth)
          .orderBy('checkIn')
          .limit(1)
          .get();

      DateTime effectiveStartDate = startOfMonth;
      if (firstCheckInSnapshot.docs.isNotEmpty) {
        final firstCheckInData = firstCheckInSnapshot.docs.first.data();
        final firstCheckInDate =
            (firstCheckInData['checkIn'] as Timestamp?)?.toDate();
        if (firstCheckInDate != null) {
          effectiveStartDate = firstCheckInDate;
        }
      }

      // Fetch all check-ins from the effective start date to today
      final querySnapshot = await attendanceCollection
          .where('checkIn', isGreaterThanOrEqualTo: effectiveStartDate)
          .where('checkIn', isLessThanOrEqualTo: now)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _events.clear();

          for (var doc in querySnapshot.docs) {
            final data = doc.data();
            final checkIn = (data['checkIn'] as Timestamp?)?.toDate();

            if (checkIn != null) {
              final lateThreshold =
                  DateTime(checkIn.year, checkIn.month, checkIn.day, 8, 00);

              // Determine color based on attendance status
              Color eventColor;
              if (checkIn.isAfter(lateThreshold)) {
                eventColor = const Color(0xffF6C15B);
              } else if (checkIn.isBefore(lateThreshold)) {
                eventColor = const Color(0xff22AF41);
              } else {
                eventColor = const Color(0xff22AF41);
              }

              _events[DateTime.utc(checkIn.year, checkIn.month, checkIn.day)] =
                  [eventColor];
            }
          }
        });
      }
    } catch (e) {
      log('Error fetching events: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      int retries = 3;
      int delay = 1000;

      for (int i = 0; i < retries; i++) {
        try {
          final docSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data()!;
            setState(() {
              _imageUrl = data['profileImageUrl'];
            });
          }
          return;
        } on FirebaseException catch (e) {
          if (e.code == 'unavailable' && i < retries - 1) {
            await Future.delayed(Duration(milliseconds: delay));
            delay *= 2;
          } else {
            rethrow;
          }
        }
      }
    }
  }

  Future<Map<String, int>> fetchMonthlyAttendance(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final attendanceCollection = FirebaseFirestore.instance
        .collection('AttendanceDetails')
        .doc(userId)
        .collection('dailyattendance');

    try {
      // Fetch attendance records for the current month
      final querySnapshot = await attendanceCollection
          .where('checkIn', isGreaterThanOrEqualTo: startOfMonth)
          .where('checkIn', isLessThanOrEqualTo: now)
          .get();

      final currentDayOfMonth = now.day;

      Map<String, int> counts = {
        'present': 0,
        'late': 0,
        'absent': 0,
      };

      if (querySnapshot.docs.isEmpty) {
        // No records, so no absences counted for new users
        return {'present': 0, 'late': 0, 'absent': 0};
      }

      Set<int> daysWithRecords = {};
      DateTime? firstCheckInDate;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final checkIn = (data['checkIn'] as Timestamp?)?.toDate();

        if (checkIn == null) continue;

        // Update the firstCheckInDate to the earliest check-in date within the month
        if (firstCheckInDate == null || checkIn.isBefore(firstCheckInDate)) {
          firstCheckInDate = checkIn;
        }

        final checkInDay = checkIn.day;

        final lateThreshold =
            DateTime(checkIn.year, checkIn.month, checkIn.day, 8, 15);

        daysWithRecords.add(checkInDay);

        counts['present'] = (counts['present'] ?? 0) + 1;

        if (checkIn.isAfter(lateThreshold)) {
          counts['late'] = (counts['late'] ?? 0) + 1;
        }
      }

      // If no check-in date was found, assume no absences
      if (firstCheckInDate == null) {
        return {'present': 0, 'late': 0, 'absent': 0};
      }

      // Only calculate absences starting from the first check-in date
      for (int day = firstCheckInDate.day; day <= currentDayOfMonth; day++) {
        final DateTime date = DateTime(now.year, now.month, day);

        // Skip weekends
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          continue;
        }

        // Count as absent if no attendance record exists for this day
        if (!daysWithRecords.contains(day)) {
          counts['absent'] = (counts['absent'] ?? 0) + 1;
        }
      }

      return counts;
    } catch (e) {
      return {
        'present': 0,
        'late': 0,
        'absent': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool exitApp = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff4D3D79),
                          Color(0xff8E71DF),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/warning.png",
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Are you sure ?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Do you want to exit app ?',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            height: 0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 110,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xffECECEC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                exit(0);
                              },
                              child: Container(
                                width: 110,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xff7647EB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
        return exitApp;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _selectedIndex == 1
              ? const StatsticsScreen()
              : _selectedIndex == 2
                  ? const ProfileScreen()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 16.0),
                      child: Column(
                        children: [
                          FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user?.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return Row(children: [
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationScreen()),
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/notification_icon.png',
                                        height: 30,
                                        width: 30,
                                      ),
                                    )
                                  ]);
                                }

                                var userData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                String displayName = userData['name'] ?? ".";
                                String email = userData['email'] ?? ".";

                                return Row(children: [
                                  if (_imageUrl != null &&
                                      _imageUrl!.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(900),
                                        child: Image.network(
                                          _imageUrl!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffE6E8FD),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/notification_icon.png',
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]);
                              }),
                          const SizedBox(height: 30),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffEFF1FF),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const Padding(
                                  padding: EdgeInsets.only(left: 25.0),
                                  child: Text(
                                    'Monthly Attendance',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FutureBuilder<Map<String, int>>(
                                  future: fetchMonthlyAttendance(user!.uid),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (snapshot.hasData) {
                                      final data = snapshot.data!;

                                      if (data['present'] == 0 &&
                                          data['late'] == 0 &&
                                          data['absent'] == 0) {
                                        return const Center(
                                          child: Text(
                                              'No attendance records available for this month.'),
                                        );
                                      }

                                      return Monthlyattendance(
                                        presentCount: data['present']!,
                                        lateCount: data['late']!,
                                        absentCount: data['absent']!,
                                      );
                                    }

                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xffEFF1FF),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: TableCalendar(
                                      firstDay: DateTime.utc(2020, 10, 16),
                                      lastDay: DateTime.utc(2030, 3, 14),
                                      focusedDay: _focusedDay,
                                      calendarFormat: _calendarFormat,
                                      availableCalendarFormats: const {
                                        CalendarFormat.month: 'Month',
                                      },
                                      availableGestures:
                                          AvailableGestures.horizontalSwipe,
                                      headerVisible: true,
                                      selectedDayPredicate: (day) =>
                                          isSameDay(_selectedDay, day),
                                      onDaySelected: _onDaySelected,
                                      onFormatChanged: (format) {
                                        if (_calendarFormat != format) {
                                          setState(() {
                                            _calendarFormat = format;
                                          });
                                        }
                                      },
                                      onPageChanged: (focusedDay) {
                                        _focusedDay = focusedDay;
                                      },
                                      eventLoader: _getEventsForDay,
                                      calendarBuilders: CalendarBuilders(
                                        markerBuilder: (context, day, events) {
                                          if (events.isEmpty) {
                                            return const SizedBox.shrink();
                                          }
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(
                                                events.length, (index) {
                                              final color =
                                                  events[index] as Color;
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 1.5),
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: color,
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Attendance Details Container
                                  _isLoading
                                      ? const CircularProgressIndicator()
                                      : Container(
                                          height: 142,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: const Color(0xffEFF1FF),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                offset: Offset(4, 4),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Attendance Details',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Builder(
                                                      builder: (context) {
                                                        if (data == null) {
                                                          return DailyEmptyAttendance(
                                                            selectedDay:
                                                                _selectedDay,
                                                          );
                                                        }

                                                        return DailyAttendance(
                                                          data: data!,
                                                          selectedDay:
                                                              _selectedDay,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
        floatingActionButton: _selectedIndex == 0
            ? FutureBuilder<Map<String, dynamic>?>(
                future: _getAttendanceDetails(userId, DateTime.now()),
                builder: (context, snapshot) {
                  DateTime? checkIn;
                  DateTime? checkOut;

                  if (snapshot.hasData && snapshot.data != null) {
                    final data = snapshot.data!;
                    checkIn = (data['checkIn'] as Timestamp?)?.toDate();
                    checkOut = (data['checkOut'] as Timestamp?)?.toDate();
                  }

                  if (checkIn != null && checkOut == null) {
                    return DraggableFab(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Material(
                              elevation: 4.0,
                              shape: const CircleBorder(),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xffFB3F4A),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xffFB3F4A),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CheckinScreen(),
                                  ),
                                );
                              },
                              backgroundColor: const Color(0xffffd7d9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/mingcute.png',
                                    height: 20,
                                    width: 20,
                                    color: const Color(0xffFB3F4A),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Check Out',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 8,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (checkIn == null && checkOut == null) {
                    return DraggableFab(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Material(
                              elevation: 4.0,
                              shape: const CircleBorder(),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xff8E71DF),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xff8E71DF),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CheckinScreen(),
                                  ),
                                );
                              },
                              backgroundColor: const Color(0xffEFF1FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/mingcute.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Check In',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 8,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Container(
            height: 65,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              color: const Color(0xffEFF1FF),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSegmentNavigator(
                    'Home',
                    0,
                    Image.asset('assets/home_selected.png'),
                    'assets/home.png',
                  ),
                  _buildSegmentNavigator(
                      'Stats',
                      1,
                      Image.asset('assets/stats_selected.png'),
                      'assets/stats.png'),
                  _buildSegmentNavigator(
                      'Profile',
                      2,
                      Image.asset('assets/profile_selected.png'),
                      'assets/profile.png'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentNavigator(
      String text, int index, Image image, String asset) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    double baseFontSize = 16;
    double responsiveFontSize = baseFontSize * (screenWidth / 375);
    bool isSelected = _selectedIndex == index;
    if (index == 1) const StatsticsScreen();
    if (index == 2) const ProfileScreen();
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(48.0),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            SizedBox(
              child: isSelected
                  ? Image(
                      image: image.image,
                      color: const Color(0xff7647EB),
                      width: 30,
                      height: 30,
                    )
                  : Image.asset(
                      width: 30,
                      height: 30,
                      asset,
                      color: const Color(0xffA4A4A4),
                    ),
            ),
            SizedBox(width: isSelected ? 5 : 0),
            isSelected
                ? Text(
                    text,
                    style: TextStyle(
                        color: isSelected
                            ? const Color(0xff7647EB)
                            : const Color(0xffA4A4A4),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: responsiveFontSize),
                  )
                : Container(),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
