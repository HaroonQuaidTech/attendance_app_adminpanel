import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AttendanceType { weekly }

class WeeklyAttendance extends StatefulWidget {
  final Color color;
  final String? dropdownValue2;
  final AttendanceType attendanceType;

  const WeeklyAttendance({
    super.key,
    required this.color,
    required this.dropdownValue2,
    this.attendanceType = AttendanceType.weekly,
  });

  @override
  State<WeeklyAttendance> createState() => _WeeklyAttendanceState();
}

class _WeeklyAttendanceState extends State<WeeklyAttendance> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = true;
  List<Map<String, dynamic>> weeklyData = [];

  List<Map<String, dynamic>> lateArrivals = [];
  List<Map<String, dynamic>> absents = [];
  List<Map<String, dynamic>> onTime = [];
  List<Map<String, dynamic>> earlyOuts = [];
  List<Map<String, dynamic>> presents = [];
  Future<void> _getWeeklyAttendance(String uid) async {
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    for (int i = 0; i < 5; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      String formattedDate = DateFormat('yMMMd').format(day);
      String formattedDay = DateFormat('EEE').format(day);

      if (day.isBefore(today) || day.isAtSameMomentAs(today)) {
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('AttendanceDetails')
                .doc(uid)
                .collection('dailyattendance')
                .doc(formattedDate)
                .get();

        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data();

          if (data != null) {
            DateTime? checkInTime = (data['checkIn'] as Timestamp?)?.toDate();
            DateTime? checkOutTime = (data['checkOut'] as Timestamp?)?.toDate();

            List<String> statuses = [];

            if (checkInTime == null) {
              statuses.add("Absent");
            } else {
              statuses.add("Present");

              if (checkInTime
                  .isAfter(DateTime(day.year, day.month, day.day, 8, 10))) {
                statuses.add("Late Arrival");
              }

              if (checkOutTime != null &&
                  checkOutTime.isBefore(
                      DateTime(day.year, day.month, day.day, 17, 0))) {
                statuses.add("Early Out");
              }

              if (checkInTime
                      .isAfter(DateTime(day.year, day.month, day.day, 7, 50)) &&
                  checkInTime.isBefore(
                      DateTime(day.year, day.month, day.day, 8, 11))) {
                statuses.add("On Time");
              }
            }

            data['formattedDate'] = formattedDate;
            data['formattedDay'] = formattedDay;
            data['statuses'] = statuses;

            weeklyData.add(data);
          }
        } else {
          weeklyData.add({
            "checkIn": null,
            "checkOut": null,
            "statuses": ["Absent"],
            "formattedDate": formattedDate,
            "formattedDay": formattedDay,
          });
        }
      } else {}
    }

    setState(() {
      isLoading = false;
    });
  }

  String _calculateTotalHours(Timestamp? checkIn, Timestamp? checkOut) {
    if (checkIn == null || checkOut == null) return '0:00';

    DateTime checkInTime = checkIn.toDate();
    DateTime checkOutTime = checkOut.toDate();
    Duration duration = checkOutTime.difference(checkInTime);

    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "--:--";
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _getWeeklyAttendance(userId);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredData = widget.dropdownValue2 == 'Select'
        ? weeklyData
        : widget.dropdownValue2 == 'On Time'
            ? weeklyData
                .where((element) =>
                    (element['statuses'] as List).contains('On Time'))
                .toList()
            : widget.dropdownValue2 == 'Absent'
                ? weeklyData
                    .where((element) =>
                        (element['statuses'] as List).contains('Absent'))
                    .toList()
                : widget.dropdownValue2 == 'Early Out'
                    ? weeklyData
                        .where((element) =>
                            (element['statuses'] as List).contains('Early Out'))
                        .toList()
                    : widget.dropdownValue2 == 'Late Arrival'
                        ? weeklyData
                            .where((element) => (element['statuses'] as List)
                                .contains('Late Arrival'))
                            .toList()
                        : weeklyData;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 100.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (filteredData.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 100.0),
            child: Center(
              child: Text(
                "No Data Available",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = filteredData[index];
                  final DateTime date = DateFormat('MMM dd, yyyy')
                      .parse(filteredData[index]['formattedDate']);

                  String day = DateFormat('EE').format(date);
                  String formattedDate = DateFormat('dd').format(date);

                  String checkInTime =
                      _formatTime(data['checkIn'] as Timestamp?);
                  String checkOutTime =
                      _formatTime(data['checkOut'] as Timestamp?);
                  String totalHours = _calculateTotalHours(
                      data['checkIn'] as Timestamp?,
                      data['checkOut'] as Timestamp?);
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 53,
                              height: 55,
                              decoration: BoxDecoration(
                                color: widget.color,
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
                                      color: Colors.white,
                                    ),
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
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              checkInTime,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 0,
                              ),
                            ),
                            const Text(
                              'Check In',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          decoration: const BoxDecoration(color: Colors.black),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              checkOutTime,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Text(
                              'Check Out',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          decoration: const BoxDecoration(color: Colors.black),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              totalHours,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Text(
                              'Total Hrs',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
          ),
      ],
    );
  }
}
