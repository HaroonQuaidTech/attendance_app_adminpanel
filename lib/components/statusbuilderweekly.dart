import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatusBuilderWeekly extends StatefulWidget {
  const StatusBuilderWeekly({super.key});
  @override
  State<StatusBuilderWeekly> createState() => _StatusBuilerState();
}

class _StatusBuilerState extends State<StatusBuilderWeekly> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  Future<List<Map<String, dynamic>>> _getWeeklyAttendanceDetails(
    String uid,
  ) async {
    List<Map<String, dynamic>> fiveDayAttendanceList = [];
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final List<Future<DocumentSnapshot<Map<String, dynamic>>>> snapshotFutures =
        List.generate(5, (i) {
      final date = startOfWeek.add(Duration(days: i));
      final formattedDate = DateFormat('yMMMd').format(date);
      return FirebaseFirestore.instance
          .collection('AttendanceDetails')
          .doc(uid)
          .collection('dailyattendance')
          .doc(formattedDate)
          .get();
    });
    final snapshots = await Future.wait(snapshotFutures);
    for (int i = 0; i < snapshots.length; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final formattedDate = DateFormat('yMMMd').format(date);
      final snapshot = snapshots[i];
      final data = snapshot.data();
      final checkIn = (data?['checkIn'] as Timestamp?)?.toDate();
      if (snapshot.exists && checkIn != null) {
        fiveDayAttendanceList.add(data!);
      } else {
        fiveDayAttendanceList.add({
          'date': formattedDate,
          'status': 'Absent',
        });
      }
    }
    return fiveDayAttendanceList;
  }

  Future<Map<String, dynamic>> _getWeeklyData(String userId) async {
    final attendanceData = await _getWeeklyAttendanceDetails(userId);
    final totalHoursData = _calculateWeeklyHours(attendanceData);
    return {
      'attendanceData': attendanceData,
      'totalHours': totalHoursData,
    };
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  String _calculateTotalHours(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) {
      return "00:00";
    }
    Duration duration = checkOut.difference(checkIn);
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    final String formattedHours = hours.toString().padLeft(2, '0');
    final String formattedMinutes = minutes.toString().padLeft(2, '0');
    return '$formattedHours:$formattedMinutes';
  }

  int _calculateWeeklyMins(List<Map<String, dynamic>?> weeklyData) {
    int totalMinutes = 0;
    for (var data in weeklyData) {
      if (data == null) continue;
      final checkIn = (data['checkIn'] as Timestamp?)?.toDate();
      final checkOut = (data['checkOut'] as Timestamp?)?.toDate();

      if (checkIn != null && checkOut != null) {
        final duration = checkOut.difference(checkIn);
        totalMinutes += duration.inMinutes;
      }
    }
    return totalMinutes;
  }

  double _calculateWeeklyHours(List<Map<String, dynamic>?> weeklyData) {
    int totalMinutes = 0;
    for (var data in weeklyData) {
      if (data == null) continue;
      final checkIn = (data['checkIn'] as Timestamp?)?.toDate();
      final checkOut = (data['checkOut'] as Timestamp?)?.toDate();

      if (checkIn != null && checkOut != null) {
        final duration = checkOut.difference(checkIn);
        totalMinutes += duration.inMinutes;
      }
    }
    final double totalHours = totalMinutes / 60;
    return totalHours;
  }

  Widget _buildEmptyAttendanceContainer(int index) {
    final DateTime date = DateTime.now()
        .subtract(Duration(days: DateTime.now().weekday - 1 - index));
    final String day = DateFormat('EE').format(date);
    final String formattedDate = DateFormat('dd').format(date);
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      height: 82,
      width: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 53,
                height: 55,
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    Text(
                      day,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 50.0),
            child: Text(
              'Leave/Day off',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNullAttendanceContainer(int index) {
    final DateTime date = DateTime.now()
        .subtract(Duration(days: DateTime.now().weekday - 1 - index));
    final String day = DateFormat('EE').format(date);
    final String formattedDate = DateFormat('dd').format(date);
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      height: 82,
      width: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 53,
                height: 55,
                decoration: BoxDecoration(
                    color: const Color(0xff8E71DF),
                    borderRadius: BorderRadius.circular(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    Text(
                      day,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Text(
            'Data not Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 0,
            ),
          ),
          const SizedBox(width: 0),
        ],
      ),
    );
  }

  Widget _buildAttendance(
      {required Color color, required List<Map<String, dynamic>?> data}) {
    return ListView.builder(
      itemCount: data.length,
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final attendanceRecord = data[index];
        final DateTime date = DateTime.now().subtract(
          Duration(days: DateTime.now().weekday - 1 - index),
        );
        if (date.isAfter(DateTime.now())) {
          return _buildNullAttendanceContainer(index);
        }
        final String day = DateFormat('EE').format(date);
        final String formattedDate = DateFormat('dd').format(date);
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          return const SizedBox.shrink();
        }
        final checkIn = (attendanceRecord?['checkIn'] as Timestamp?)?.toDate();
        final checkOut =
            (attendanceRecord?['checkOut'] as Timestamp?)?.toDate();
        if (checkIn == null && checkOut == null) {
          return _buildEmptyAttendanceContainer(index);
        }
        final totalHours = _calculateTotalHours(checkIn, checkOut);
        Color containerColor = _determineContainerColor(checkIn, checkOut);
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 10),
          height: 82,
          width: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDateColumn(formattedDate, day, containerColor),
              _buildTimeColumn(checkIn, 'Check In'),
              const VerticalDivider(color: Colors.black, width: 1),
              _buildTimeColumn(checkOut, 'Check Out'),
              const VerticalDivider(color: Colors.black, width: 1),
              _buildHoursColumn(totalHours),
            ],
          ),
        );
      },
    );
  }

  Color _determineContainerColor(DateTime? checkIn, DateTime? checkOut) {
    const TimeOfDay onTime = TimeOfDay(hour: 8, minute: 14);
    const TimeOfDay lateArrival = TimeOfDay(hour: 8, minute: 15);
    const TimeOfDay earlyCheckout = TimeOfDay(hour: 17, minute: 0);
    Color containerColor = const Color(0xffEC5851);
    if (checkIn != null) {
      final TimeOfDay checkInTime = TimeOfDay.fromDateTime(checkIn);
      if (checkInTime.hour < onTime.hour ||
          (checkInTime.hour == onTime.hour &&
              checkInTime.minute <= onTime.minute)) {
        containerColor = const Color(0xff22Af41);
      } else if (checkInTime.hour > lateArrival.hour ||
          (checkInTime.hour == lateArrival.hour &&
              checkInTime.minute >= lateArrival.minute)) {
        containerColor = const Color(0xffF6C15B);
      }
    }
    if (checkOut != null) {
      final TimeOfDay checkOutTime = TimeOfDay.fromDateTime(checkOut);
      if (checkOutTime.hour < earlyCheckout.hour ||
          (checkOutTime.hour == earlyCheckout.hour &&
              checkOutTime.minute < earlyCheckout.minute)) {
        containerColor = const Color(0xffF07E25);
      }
    }
    return containerColor;
  }

  Widget _buildDateColumn(
      String formattedDate, String day, Color containerColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 53,
          height: 55,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Text(
                day,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeColumn(DateTime? time, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          time != null ? _formatTime(time) : '--:--',
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildHoursColumn(String totalHours) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          totalHours,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const Text(
          'Total Hrs',
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ],
    );
  }

  String _convertMinutesToTimeFormat(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 4));
    final String startFormatted = DateFormat('dd MMM').format(startOfWeek);
    final String endFormatted = DateFormat('dd MMM').format(endOfWeek);

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          FutureBuilder(
            future: _getWeeklyData(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 150.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error: Something went wrong. Check Your Internet Connection.',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: Text(
                    'No Data Available',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final attendanceData = snapshot.data!['attendanceData']
                  as List<Map<String, dynamic>?>;
              final weeklyData = snapshot.data!['attendanceData']
                      as List<Map<String, dynamic>?>? ??
                  [];

              final totalTime = _calculateWeeklyMins(weeklyData);
              final totalHoursFormatted =
                  _convertMinutesToTimeFormat(totalTime);
              (totalTime / 60).toStringAsFixed(2);

              const double maxHours = 45;
              final double progress = totalTime / 60 / maxHours;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly Times Log',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: screenHeight * 0.15,
                                width: screenWidth * 0.43,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time in Mints',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        '$totalTime Mints',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20),
                                      ),
                                      LinearProgressIndicator(
                                        value: totalTime /
                                            60 /
                                            maxHours, // Progress based on total minutes
                                        backgroundColor: Colors.grey[300],
                                        color: const Color(0xff9478F7),
                                      ),
                                      Text(
                                        '$startFormatted - $endFormatted',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: screenHeight * 0.15,
                                width: screenWidth * 0.43,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time in Hours',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        '$totalHoursFormatted Hours', // Display formatted hours
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20),
                                      ),
                                      LinearProgressIndicator(
                                        value:
                                            progress, // Correct progress bar calculation based on hours
                                        backgroundColor: Colors.grey[300],
                                        color: const Color(0xff9478F7),
                                      ),
                                      Text(
                                        '$startFormatted - $endFormatted',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xffEFF1FF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Attendance: ${'$startFormatted - $endFormatted'}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        _buildAttendance(
                          color: const Color(0xff9478F7),
                          data: attendanceData,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
