// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:quaidtech/components/employeeAttendance.dart';
import 'package:quaidtech/components/graphicalbuildermonthly.dart';
import 'package:quaidtech/components/graphicalweekly.dart';
import 'package:quaidtech/components/statusbuilderweekly.dart';

import 'package:quaidtech/components/statusbuildermonthly.dart';
import 'package:quaidtech/screens/home.dart';
import 'package:quaidtech/screens/notification.dart';

class AdminStatsticsScreen extends StatefulWidget {
  const AdminStatsticsScreen({super.key});

  @override
  State<AdminStatsticsScreen> createState() => _StatsticsScreenState();
}

class _StatsticsScreenState extends State<AdminStatsticsScreen> {
  String dropdownValue1 = 'Select';
  String dropdownValue2 = 'Select';
  String dropdownValue3 = 'Select';

  int _selectedIndex = 0;

//----------------------------------------------------------------------------

  // Widget _buildWeeklyAttendance(String text, Color color) {
  //   return Container(
  //       padding: EdgeInsets.all(12),
  //       height: 710,
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(20),
  //         color: Color(0xffEFF1FF),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.2),
  //             spreadRadius: 2,
  //             blurRadius: 4,
  //             offset: Offset(0, 2), // changes position of shadow
  //           ),
  //         ],
  //       ),
  //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //         Text(
  //           text,
  //           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         WeeklyAttendance(text: '01', text1: 'MON', color: color),
  //         SizedBox(height: 10),
  //         WeeklyAttendance(text: '01', text1: 'MON', color: color),
  //         SizedBox(height: 10),
  //         WeeklyAttendance(text: '01', text1: 'MON', color: color),
  //         SizedBox(height: 10),
  //         WeeklyAttendance(text: '01', text1: 'MON', color: color),
  //         SizedBox(height: 10),
  //         WeeklyAttendance(text: '01', text1: 'MON', color: color),
  //         SizedBox(height: 10),
  //         WeeklyAttendance(text: '01', text1: 'MON', color: color),
  //         SizedBox(height: 10),
  //         WeeklyAttendance(text: '01', text1: 'MON', color: color),
  //         SizedBox(height: 10),
  //       ]));
  // }

  Widget _buildWeeklyAttendanceEmployee(String text, Color color) {
    return Container(
        padding: EdgeInsets.all(12),
        height: 710,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xffEFF1FF),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          SizedBox(
            height: 10,
          ),
          Employeeattendance(
              text: 'Muhammad Abbas', text1: 'Laravel developer'),
          SizedBox(height: 10),
          Employeeattendance(
              text: 'Muhammad Abbas', text1: 'Laravel developer'),
          SizedBox(height: 10),
          Employeeattendance(
              text: 'Muhammad Abbas', text1: 'Laravel developer'),
          SizedBox(height: 10),
          Employeeattendance(
              text: 'Muhammad Abbas', text1: 'Laravel developer'),
          SizedBox(height: 10),
          Employeeattendance(
              text: 'Muhammad Abbas', text1: 'Laravel developer'),
          SizedBox(height: 10),
          Employeeattendance(
              text: 'Muhammad Abbas', text1: 'Laravel developer'),
          SizedBox(height: 10),
          Employeeattendance(
              text: 'Muhammad Abbas', text1: 'Laravel developer'),
          SizedBox(height: 10),
        ]));
  }

  Widget _buildWeeklyAttendanceEmployeeAbsent() {
    return Container(
        padding: EdgeInsets.all(12),
        height: 430,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xffEFF1FF),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
          Align(
              alignment: Alignment.topLeft,
            child: Text(
              'Absent Employee',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
       
         SizedBox(height: 30),
       
          Container(
            width: 127,
            height: 137,
            decoration: BoxDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(900),
              child: Image.asset(
                'assets/img2.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
                 SizedBox(height: 10),
             Text(
                         'Perfect Attendance',
                         style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                       ),
                 
                              Text(
                         'No Employees are Absent Today!',
                         style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                         textAlign: TextAlign.center,
                       ),
                       
         
          SizedBox(
            height: 10,
          ),
        ]));
  }

  Widget _buildSegment(String text, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(48.0),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  color: isSelected ? Colors.black : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  //-------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.transparent,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                            );
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      Text(
                        'Statistics',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationScreen()),
                            );
                          },
                          child: Icon(
                            Icons.notifications_none,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                //-----------------------------Filter container-----------------------------------------------------------------------------
                if (_selectedIndex != 1)
                  Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xffEFF1FF),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // First Dropdown
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButton<String>(
                                      value: dropdownValue1,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      isExpanded: true,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      underline: SizedBox(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValue1 = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        'Select',
                                        'Usama',
                                        'Uzair',
                                        'Ali',
                                        'Moeen'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Second Dropdown
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButton<String>(
                                      value: dropdownValue2,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      isExpanded: true,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      underline: SizedBox(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValue2 = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        'Select',
                                        'Weekly',
                                        'Monthly',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Second Dropdown
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButton<String>(
                                      value: dropdownValue3,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      isExpanded: true,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      underline: SizedBox(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValue3 = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        'Select',
                                        'Late Arrival',
                                        'Absent',
                                        'On Time',
                                        'Early Out',
                                        'Present'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                // if (dropdownValue1 == 'Weekly')
                // StatusBuilderWeekly(),

                SizedBox(
                  height: 20,
                ),

                if (dropdownValue3 == 'Late Arrival' && _selectedIndex != 1)
                  _buildWeeklyAttendanceEmployee(
                      'Late Arrival Details', Color(0xffF6C15B)),

                if (dropdownValue3 == 'Absent' && _selectedIndex != 1)
                  _buildWeeklyAttendanceEmployeeAbsent(),

                if (dropdownValue3 == 'On Time' && _selectedIndex != 1)
                  _buildWeeklyAttendanceEmployee(
                      'On Time Details', Color(0xff22AF41)),

                if (dropdownValue3 == 'Early Out' && _selectedIndex != 1)
                  _buildWeeklyAttendanceEmployee(
                      'Early Out Details', Color(0xffF07E25)),
                if (dropdownValue3 == 'Present' && _selectedIndex != 1)
                  _buildWeeklyAttendanceEmployee(
                    'Present Details',
                    Color(0xff8E71DF),
                  ),

                //------------------------------------ygrt----------------------------------------------------
                if (dropdownValue3 != 'Present' &&
                    dropdownValue3 != 'On Time' &&
                    dropdownValue3 != 'Absent' &&
                    dropdownValue3 != 'Early Out' &&
                    dropdownValue3 != 'Late Arrival')
                  Container(
                    height: 65,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: Color(0xffEFF1FF),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildSegment('Details Stats', 0),
                        _buildSegment('Graphical View', 1),
                      ],
                    ),
                  ),

                if (dropdownValue3 != 'Present' &&
                    dropdownValue3 != 'On Time' &&
                    dropdownValue3 != 'Absent' &&
                    dropdownValue3 != 'Early Out' &&
                    dropdownValue3 != 'Late Arrival')
                  if (dropdownValue3 == 'Weekly' && _selectedIndex == 0)
                    StatusBuilderWeekly(),
                if (dropdownValue3 != 'Present' &&
                    dropdownValue3 != 'On Time' &&
                    dropdownValue3 != 'Absent' &&
                    dropdownValue3 != 'Early Out' &&
                    dropdownValue3 != 'Late Arrival')
                  if (dropdownValue2 == 'Monthly' && _selectedIndex == 0)
                    StatusBuiler(),

                if (dropdownValue2 == 'Weekly' && _selectedIndex == 1)
                  GraphicalbuilerWeekly(),
                if (dropdownValue2 == 'Monthly' && _selectedIndex == 1)
GraphicalbuilerMonthly()

                //-------------------------Weekly Log Times------------------------------------------
              ],
            ),
          ),
        ),
      ),
    );
  }
}
