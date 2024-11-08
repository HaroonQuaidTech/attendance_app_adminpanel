import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyAttendance extends StatefulWidget {
  const DailyAttendance({
    super.key,
    required this.data,
    required this.selectedDay,
  });
  final Map<String, dynamic>? data;
  final DateTime? selectedDay;

  @override
  State<DailyAttendance> createState() => _DailyAttendanceState();
}

class _DailyAttendanceState extends State<DailyAttendance> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    final data = widget.data;

    DateTime? checkInTime = (data?['checkIn'] != null)
        ? (data!['checkIn'] as Timestamp).toDate()
        : null;
    DateTime? checkOutTime = (data?['checkOut'] != null)
        ? (data!['checkOut'] as Timestamp).toDate()
        : null;

    String checkInTimeFormatted = checkInTime != null
        ? DateFormat('hh:mm a').format(checkInTime)
        : '--:--';
    String checkOutTimeFormatted = checkOutTime != null
        ? DateFormat('hh:mm a').format(checkOutTime)
        : "--:--";

    final totalHours = _calculateTotalHours(checkInTime, checkOutTime);

    Color boxColor = const Color(0xff8E71DF);
    if (checkInTime != null) {
      final eightAM = DateTime(
        checkInTime.year,
        checkInTime.month,
        checkInTime.day,
        8,
        15,
      );
      if (checkInTime.isBefore(eightAM) ||
          checkInTime.isAtSameMomentAs(eightAM)) {
        boxColor = const Color(0xff22AF41);
      } else {
        boxColor = const Color(0xffF6C15B);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      height: screenHeight * 0.1,
      width: screenWidth * 0.90,
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
                  color: boxColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd').format(widget.selectedDay!),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    Text(
                      DateFormat('EEE').format(widget.selectedDay!),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
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
                checkInTimeFormatted,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              const Text(
                'Check In',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
                checkOutTimeFormatted,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Text(
                'Check Out',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              const Text(
                'Total Hrs',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
            ],
          )
        ],
      ),
    );
  }
}
