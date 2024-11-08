import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

Future<Map<String, int>> fetchMonthlyAttendance(String userId) async {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);

  final attendanceCollection = FirebaseFirestore.instance
      .collection('AttendanceDetails')
      .doc(userId)
      .collection('dailyattendance');

  try {
    final querySnapshot = await attendanceCollection
        .where('checkIn', isGreaterThanOrEqualTo: startOfMonth)
        .where('checkIn', isLessThanOrEqualTo: now)
        .get();

    final currentDayOfMonth = now.day;

    if (querySnapshot.docs.isEmpty) {
      return {'present': 0, 'late': 0, 'absent': currentDayOfMonth};
    }

    final lateThreshold = DateTime(now.year, now.month, now.day, 8, 15);

    Map<String, int> counts = {
      'present': 0,
      'late': 0,
      'absent': 0,
    };

    Set<int> daysWithRecords = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final checkIn = (data['checkIn'] as Timestamp?)?.toDate();
      final checkOut = (data['checkOut'] as Timestamp?)?.toDate();

      if (checkIn == null && checkOut == null) {
        continue;
      }

      if (checkIn != null) {
        daysWithRecords.add(checkIn.day);
      }

      if (checkIn != null && checkIn.isAfter(lateThreshold)) {
        counts['late'] = (counts['late'] ?? 0) + 1;
      } else if (checkIn != null) {
        counts['present'] = (counts['present'] ?? 0) + 1;
      }
    }

    for (int day = 1; day <= currentDayOfMonth; day++) {
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

class Monthlyattendance extends StatelessWidget {
  final int presentCount;
  final int lateCount;
  final int absentCount;

  const Monthlyattendance({
    super.key,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    double baseFontSize = 20;
    double responsiveFontSize = baseFontSize * (screenWidth / 375);
    double baseFontSize1 = 14;
    double responsiveFontSize1 = baseFontSize1 * (screenWidth / 375);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 90,
            width: 90,
            child: PieChart(
              PieChartData(sections: [
                PieChartSectionData(
                  color: const Color(0xff8E71DF),
                  value: presentCount.toDouble(),
                  title: '',
                  radius: 12,
                ),
                PieChartSectionData(
                  color: const Color(0xffF6C15B),
                  value: lateCount.toDouble(),
                  title: '',
                  radius: 12,
                ),
                PieChartSectionData(
                  color: const Color(0xffEC5851),
                  value: absentCount.toDouble(),
                  title: '',
                  radius: 12,
                ),
              ], sectionsSpace: 0, centerSpaceRadius: 26),
            ),
          ),
          Column(
            children: [
              Text(
                presentCount.toString(),
                style: TextStyle(
                    fontSize: responsiveFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff8E71DF)),
              ),
              Text(
                'Present',
                style: TextStyle(
                    fontSize: responsiveFontSize1,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff9E9E9E)),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                lateCount.toString(),
                style: TextStyle(
                    fontSize: responsiveFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffF6C15B)),
              ),
              Text(
                'Late',
                style: TextStyle(
                    fontSize: responsiveFontSize1,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff9E9E9E)),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                absentCount.toString(),
                style: TextStyle(
                    fontSize: responsiveFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffEC5851)),
              ),
              Text(
                'Absent',
                style: TextStyle(
                    fontSize: responsiveFontSize1,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff9E9E9E)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
