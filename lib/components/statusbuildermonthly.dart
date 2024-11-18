import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StatusBuilderMonthly extends StatefulWidget {
  const StatusBuilderMonthly({super.key});
  @override
  State<StatusBuilderMonthly> createState() => _StatusBuilerState();
}

class _StatusBuilerState extends State<StatusBuilderMonthly> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> _getMonthlyAttendanceDetails(
      String uid) async {
    List<Map<String, dynamic>> monthlyAttendanceList = [];
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final today = now.day;

    final List<Future<DocumentSnapshot<Map<String, dynamic>>>> snapshotFutures =
        List.generate(today, (i) {
      final date = firstDayOfMonth.add(Duration(days: i));
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
      final date = firstDayOfMonth.add(Duration(days: i));
      final formattedDate = DateFormat('yMMMd').format(date);
      final snapshot = snapshots[i];
      final data = snapshot.data();
      final checkIn = (data?['checkIn'] as Timestamp?)?.toDate();

      if (snapshot.exists && checkIn != null) {
        monthlyAttendanceList.add(data!);
      } else {
        monthlyAttendanceList.add({
          'date': formattedDate,
          'status': 'Absent',
        });
      }
    }

    return monthlyAttendanceList;
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

  int _calculateMonthlyTotal(List<Map<String, dynamic>?> monthlyData) {
    int totalMinutes = 0;
    for (var data in monthlyData) {
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

  double _calculateMonthlyHours(List<Map<String, dynamic>?> monthlyData) {
    int totalMinutes = 0;
    for (var data in monthlyData) {
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
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime date = firstDayOfMonth.add(Duration(days: index));
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

  Widget _buildHNullAttendanceContainer(int index) {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime date = firstDayOfMonth.add(Duration(days: index));
    final String day = DateFormat('EE').format(date);
    final String formattedDate = DateFormat('dd').format(date);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
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
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 30),
          const Text(
            'Data Not Available',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 0,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeekendContainer(int index) {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime date = firstDayOfMonth.add(Duration(days: index));
    final String day = DateFormat('EE').format(date);
    final String formattedDate = DateFormat('dd').format(date);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 55,
            decoration: BoxDecoration(
                color: Colors.blueGrey, borderRadius: BorderRadius.circular(6)),
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
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 30),
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              'Weekend Days',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 0,
              ),
            ),
          )
        ],
      ),
    );
  }

  String getCurrentMonthDateRange() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final formattedFirstDay = DateFormat('dd MMM').format(firstDayOfMonth);
    final formattedLastDay = DateFormat('dd MMM').format(lastDayOfMonth);
    return '$formattedFirstDay - $formattedLastDay';
  }

  Widget _buildAttendance(
      {required Color color, required List<Map<String, dynamic>?> data}) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No attendance data found.',
          style: TextStyle(fontSize: 20),
        ),
      );
    }
    return ListView.builder(
      itemCount: data.length,
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final attendanceRecord = data[index];
        final DateTime now = DateTime.now();
        final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
        final DateTime date = firstDayOfMonth.add(Duration(days: index));
        final String day = DateFormat('EE').format(date);
        final String formattedDate = DateFormat('dd').format(date);
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          return _buildWeekendContainer(index);
        }
        if (date.isAfter(now) || attendanceRecord == null) {
          return _buildHNullAttendanceContainer(index);
        }
        final checkIn = (attendanceRecord['checkIn'] as Timestamp?)?.toDate();
        final checkOut = (attendanceRecord['checkOut'] as Timestamp?)?.toDate();
        if (checkIn == null && checkOut == null) {
          return _buildEmptyAttendanceContainer(index);
        }
        final totalHours = _calculateTotalHours(checkIn, checkOut);
        final Color containerColor =
            _determineContainerColor(checkIn, checkOut);
        return _buildAttendanceRow(
          formattedDate: formattedDate,
          day: day,
          checkIn: checkIn,
          checkOut: checkOut,
          totalHours: totalHours,
          containerColor: containerColor,
        );
      },
    );
  }

  Color _determineContainerColor(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn != null) {
      final TimeOfDay checkInTime = TimeOfDay.fromDateTime(checkIn);
      const TimeOfDay earlyOnTime = TimeOfDay(hour: 7, minute: 50);
      const TimeOfDay lateOnTime = TimeOfDay(hour: 8, minute: 10);
      const TimeOfDay exactCheckIn = TimeOfDay(hour: 8, minute: 0);
      const TimeOfDay lateArrival = TimeOfDay(hour: 8, minute: 10);
      if ((checkInTime.hour == earlyOnTime.hour &&
              checkInTime.minute >= earlyOnTime.minute) ||
          (checkInTime.hour == lateOnTime.hour &&
              checkInTime.minute <= lateOnTime.minute) ||
          (checkInTime.hour > earlyOnTime.hour &&
              checkInTime.hour < lateOnTime.hour)) {
        return const Color(0xff22AF41);
      } else if (checkInTime.hour > lateArrival.hour ||
          (checkInTime.hour == lateArrival.hour &&
              checkInTime.minute > lateArrival.minute)) {
        return const Color(0xffF6C15B);
      } else if (checkInTime.hour == exactCheckIn.hour &&
          checkInTime.minute == exactCheckIn.minute) {
        return const Color(0xff8E71DF);
      }
    }
    if (checkOut != null) {
      final TimeOfDay checkOutTime = TimeOfDay.fromDateTime(checkOut);
      const TimeOfDay earlyCheckout = TimeOfDay(hour: 17, minute: 0);
      if (checkOutTime.hour < earlyCheckout.hour ||
          (checkOutTime.hour == earlyCheckout.hour &&
              checkOutTime.minute < earlyCheckout.minute)) {
        return const Color.fromARGB(255, 223, 103, 11);
      }
    }
    return const Color(0xff8E71DF);
  }

  Widget _buildAttendanceRow({
    required String formattedDate,
    required String day,
    required DateTime? checkIn,
    required DateTime? checkOut,
    required String? totalHours,
    required Color containerColor,
  }) {
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
          _buildDateContainer(formattedDate, day, containerColor),
          _buildCheckTimeColumn(checkIn, 'Check In'),
          _buildDivider(),
          _buildCheckTimeColumn(checkOut, 'Check Out'),
          _buildDivider(),
          _buildCheckTimeColumn(totalHours ?? 'N/A', 'Total Hrs'),
        ],
      ),
    );
  }

  Widget _buildDateContainer(
      String formattedDate, String day, Color containerColor) {
    return Container(
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
                fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          Text(
            day,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckTimeColumn(dynamic timeOrHours, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          timeOrHours is DateTime
              ? _formatTime(timeOrHours)
              : timeOrHours.toString(),
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.black,
    );
  }

  String _convertMinutesToTimeFormat(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> _getMonthlyData(String userId) async {
    final attendanceData = await _getMonthlyAttendanceDetails(userId);
    final totalHoursData =
        attendanceData.isNotEmpty ? _calculateMonthlyTotal(attendanceData) : 0;
    return {
      'attendanceData': attendanceData,
      'totalHours': totalHoursData,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    DateFormat('dd MMM').format(startOfWeek);
    DateFormat('dd MMM').format(endOfWeek);
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _getMonthlyData(userId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Padding(
                  padding: EdgeInsets.only(top: 150.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final attendanceData = snapshot.data!['attendanceData']
                  as List<Map<String, dynamic>?>;

              final monthlyData = snapshot.data!['attendanceData']
                      as List<Map<String, dynamic>?>? ??
                  [];

              final totalTime = _calculateMonthlyTotal(monthlyData);
              log('total time: $totalTime');
              final totalHoursFormatted =
                  _convertMinutesToTimeFormat(totalTime);
              (totalTime / 60).toStringAsFixed(2);

              const int maxMinutes = 10392;
              const double maxHours = 173.2;

              final totalMinutes = _calculateMonthlyTotal(monthlyData);
              final totalHourss = _calculateMonthlyHours(monthlyData);

              double progressValue =
                  maxHours != 0 ? totalHourss / maxHours : 0.0;
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
                            'Monthly Times Log',
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
                                        'Time in Minutes',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        '$totalTime Minutes',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20),
                                      ),
                                      LinearProgressIndicator(
                                        value: totalMinutes / maxMinutes,
                                        backgroundColor: Colors.grey[300],
                                        color: const Color(0xff9478F7),
                                      ),
                                      Text(
                                        getCurrentMonthDateRange(),
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
                                        '$totalHoursFormatted Hours',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20),
                                      ),
                                      LinearProgressIndicator(
                                        value: progressValue,
                                        backgroundColor: Colors.grey[300],
                                        color: const Color(0xff9478F7),
                                      ),
                                      Text(
                                        getCurrentMonthDateRange(),
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
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xffEFF1FF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Attendance: ${getCurrentMonthDateRange()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        _buildAttendance(
                            color: const Color(0xff9478F7),
                            data: attendanceData),
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
