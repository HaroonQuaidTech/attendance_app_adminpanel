import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart' hide PieChart;

class GraphicalbuilerMonthly extends StatefulWidget {
  const GraphicalbuilerMonthly({super.key});

  @override
  State<GraphicalbuilerMonthly> createState() => _GraphicalbuilerState();
}

class _GraphicalbuilerState extends State<GraphicalbuilerMonthly> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>?> fetchMonthlyAttendance(
      String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      List<Future<DocumentSnapshot>> futures = [];

      for (int i = 1; i <= lastDayOfMonth.day; i++) {
        DateTime date = DateTime(now.year, now.month, i);

        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday ||
            date.isAfter(now)) {
          continue;
        }

        String formattedDate = DateFormat('yMMMd').format(date);
        futures.add(FirebaseFirestore.instance
            .collection('AttendanceDetails')
            .doc(userId)
            .collection('dailyattendance')
            .doc(formattedDate)
            .get());
      }

      List<DocumentSnapshot> snapshots = await Future.wait(futures);

      List<Map<String, dynamic>> monthlyData = snapshots.map((doc) {
        return doc.exists
            ? Map<String, dynamic>.from(doc.data() as Map)
            : Map<String, dynamic>.from({});
      }).toList();

      return monthlyData;
    } catch (e) {
      return null;
    }
  }

  Map<String, double> calculateMonthlyHours(List<Map<String, dynamic>> data) {
    Map<String, double> monthlyHours = {
      "Week 1": 0,
      "Week 2": 0,
      "Week 3": 0,
      "Week 4": 0,
      "Week 5": 0,
    };

    for (var entry in data) {
      final checkIn = (entry['checkIn'] as Timestamp?)?.toDate();
      final checkOut = (entry['checkOut'] as Timestamp?)?.toDate();

      if (checkIn != null && checkOut != null) {
        final duration = checkOut.difference(checkIn);
        int weekNumber = ((checkIn.day - 1) / 7).floor() + 1;

        switch (weekNumber) {
          case 1:
            monthlyHours["Week 1"] =
                (monthlyHours["Week 1"] ?? 0) + duration.inHours.toDouble();
            break;
          case 2:
            monthlyHours["Week 2"] =
                (monthlyHours["Week 2"] ?? 0) + duration.inHours.toDouble();
            break;
          case 3:
            monthlyHours["Week 3"] =
                (monthlyHours["Week 3"] ?? 0) + duration.inHours.toDouble();
            break;
          case 4:
            monthlyHours["Week 4"] =
                (monthlyHours["Week 4"] ?? 0) + duration.inHours.toDouble();
            break;
          case 5:
            monthlyHours["Week 5"] =
                (monthlyHours["Week 5"] ?? 0) + duration.inHours.toDouble();
            break;
        }
      }
    }

    return monthlyHours;
  }

  Map<String, double> calculateAttendanceStats(
      List<Map<String, dynamic>> data) {
    Map<String, double> attendanceStats = {
      "Present": 0,
      "Absent": 0,
      "Early Out": 0,
      "On Time": 0,
      "Late Arrival": 0,
    };

    for (var entry in data) {
      final checkIn = (entry['checkIn'] as Timestamp?)?.toDate();
      final checkOut = (entry['checkOut'] as Timestamp?)?.toDate();

      if (checkIn != null && checkOut != null) {
        final checkInTime = TimeOfDay.fromDateTime(checkIn);
        final checkOutTime = TimeOfDay.fromDateTime(checkOut);
        if ((checkInTime.hour == 7 && checkInTime.minute >= 50) ||
            (checkInTime.hour == 8 && checkInTime.minute <= 10)) {
          attendanceStats["On Time"] = (attendanceStats["On Time"] ?? 0) + 1;
        }

        if (checkInTime.hour > 8 ||
            (checkInTime.hour == 8 && checkInTime.minute > 15)) {
          attendanceStats["Late Arrival"] =
              (attendanceStats["Late Arrival"] ?? 0) + 1;
        }

        if (checkOutTime.hour < 17) {
          attendanceStats["Early Out"] =
              (attendanceStats["Early Out"] ?? 0) + 1;
        }
      } else {
        attendanceStats["Absent"] = (attendanceStats["Absent"] ?? 0) + 1;
      }
    }

    return attendanceStats;
  }

  int getLateArrivalCount(List<Map<String, dynamic>> attendanceData) {
    int lateCount = 0;
    DateTime now = DateTime.now();

    for (var entry in attendanceData) {
      if (entry['checkIn'] != null) {
        DateTime checkInTime = (entry['checkIn'] as Timestamp).toDate();
        DateTime checkInDate =
            DateTime(checkInTime.year, checkInTime.month, checkInTime.day);

        if (checkInDate.isBefore(now) || checkInDate.isAtSameMomentAs(now)) {
          if (checkInTime.isAfter(DateTime(
              checkInTime.year, checkInTime.month, checkInTime.day, 8, 15))) {
            lateCount++;
          }
        }
      }
    }
    return lateCount;
  }

  int getEarlyOutCount(List<Map<String, dynamic>> attendanceData) {
    int earlyCount = 0;

    for (var entry in attendanceData) {
      if (entry['checkOut'] != null) {
        DateTime checkOutTime = (entry['checkOut'] as Timestamp).toDate();

        if (checkOutTime.isBefore(DateTime(
            checkOutTime.year, checkOutTime.month, checkOutTime.day, 17, 0))) {
          earlyCount++;
        }
      }
    }

    return earlyCount;
  }

  int getOnTimeCount(List<Map<String, dynamic>> data) {
    int onTimeCount = 0;

    for (var entry in data) {
      final checkIn = (entry['checkIn'] as Timestamp?)?.toDate();

      if (checkIn != null) {
        final checkInTime = TimeOfDay.fromDateTime(checkIn);

        if ((checkInTime.hour == 7 && checkInTime.minute >= 50) ||
            (checkInTime.hour == 8 && checkInTime.minute <= 10)) {
          onTimeCount++;
        }
      }
    }

    return onTimeCount;
  }

  int getAbsentCount(List<dynamic> attendanceData) {
    int absentCount = 0;

    for (var record in attendanceData) {
      if (record['checkIn'] == null ||
          (record['status'] != null &&
              record['status'].toString().toLowerCase() == 'absent')) {
        absentCount++;
      }
    }

    return absentCount;
  }

  int getPresentCount(List<dynamic> attendanceData) {
    int presentCount = 0;

    for (var record in attendanceData) {
      if (record['checkIn'] != null) {
        presentCount++;
      }
    }

    return presentCount;
  }

  Map<String, double> weeklyHours = {
    'Present': 0,
    'Absent': 0,
    'Late Arrival': 0,
    'Early Out': 0,
    'On Time': 0,
  };
  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Map<String, double> monthlyHours = {};
  Map<String, double> monthlyAttendanceStats = {};

  Future<void> _loadMonthlyData() async {
    List<Map<String, dynamic>>? data = await fetchMonthlyAttendance(userId);
    if (data != null) {
      setState(() {
        monthlyHours = calculateMonthlyHours(data);
        monthlyAttendanceStats = calculateAttendanceStats(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: fetchMonthlyAttendance(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 240.0),
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Text('Error loading data');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 80.0),
            child: Text('No attendance data available'),
          );
        }

        Map<String, double> monthlyHours =
            calculateMonthlyHours(snapshot.data!);
        calculateAttendanceStats(snapshot.data!);

        Map<String, double> pieChartData = {
          'Present': getPresentCount(snapshot.data!).toDouble(),
          'Absent': getAbsentCount(snapshot.data!).toDouble(),
          'Late Arrival': getLateArrivalCount(snapshot.data!).toDouble(),
          'Early Out': getEarlyOutCount(snapshot.data!).toDouble(),
          'On Time': getOnTimeCount(snapshot.data!).toDouble(),
        };

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            const SizedBox(height: 20),
            // Monthly Bar Chart
            Container(
              height: 430,
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
                      'Monthly',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    Row(
                      children: [
                        Container(
                          height: 18,
                          width: 16,
                          decoration:
                              const BoxDecoration(color: Color(0xff9478F7)),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'TAT (Turn Around Time)',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 45,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}H',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold));
                                },
                                reservedSize: 28,
                                interval: 5,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('Week 1',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400));
                                    case 1:
                                      return const Text('Week 2',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400));
                                    case 2:
                                      return const Text('Week 3',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400));
                                    case 3:
                                      return const Text('Week 4',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400));
                                    case 4:
                                      return const Text('Week 5',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400));
                                    default:
                                      return const Text('');
                                  }
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(
                                toY: monthlyHours["Week 1"]!,
                                color: const Color(0xff9478F7),
                                width: 22,
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 45,
                                  color: Colors.white,
                                ),
                              ),
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(
                                toY: monthlyHours["Week 2"]!,
                                color: const Color(0xff9478F7),
                                width: 22,
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 45,
                                  color: Colors.white,
                                ),
                              ),
                            ]),
                            BarChartGroupData(x: 2, barRods: [
                              BarChartRodData(
                                toY: monthlyHours["Week 3"]!,
                                color: const Color(0xff9478F7),
                                width: 22,
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 45,
                                  color: Colors.white,
                                ),
                              ),
                            ]),
                            BarChartGroupData(x: 3, barRods: [
                              BarChartRodData(
                                toY: monthlyHours["Week 4"]!,
                                color: const Color(0xff9478F7),
                                width: 22,
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 45,
                                  color: Colors.white,
                                ),
                              ),
                            ]),
                            BarChartGroupData(x: 4, barRods: [
                              BarChartRodData(
                                toY: monthlyHours["Week 5"]!,
                                color: const Color(0xff9478F7),
                                width: 22,
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 45,
                                  color: Colors.white,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Monthly Pie Chart
            Container(
              padding: const EdgeInsets.all(12),
              height: 430,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  pieChartData.isEmpty
                      ? const Center(child: Text('No data available'))
                      : PieChart(
                          dataMap: pieChartData,
                          colorList: const [
                            Color(0xff9478F7), // Present
                            Color(0xffEC5851), // Absent
                            Color(0xffF6C15B), // Late Arrival
                            Color(0xffF07E25), // Early Out
                            Color(0xff22AF41), //oN TIME
                          ],
                          chartRadius: MediaQuery.of(context).size.width / 1.7,
                          legendOptions: const LegendOptions(
                            legendPosition: LegendPosition.top,
                            showLegendsInRow: true,
                            showLegends: true,
                            legendShape: BoxShape.circle,
                            legendTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValues: false,
                          ),
                          totalValue: pieChartData.values.isNotEmpty
                              ? pieChartData.values.reduce((a, b) => a + b)
                              : 1,
                        ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}
