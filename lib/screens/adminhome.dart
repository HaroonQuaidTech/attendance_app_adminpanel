// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_new, avoid_print, sort_child_properties_last
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:quaidtech/screens/adminprofile.dart';
import 'package:quaidtech/screens/adminstastics.dart';
import 'package:quaidtech/screens/notification.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AdminHomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String dropdownValue1 = 'Admin';

  int _selectedIndex = 0;
  File? selectedFile;
  double? uploadProgress;

  Future<void> pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
      });
    } else {
      print("No file selected");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSegmentNavigator(String text, int index, Icon icon) {
    bool isSelected = _selectedIndex == index;
    if (index == 1) AdminStatsticsScreen();
    if (index == 2) AdminProfileScreen();
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(48.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Icon(
                  icon.icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondary
                      : Color(0xffA4A4A4),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  text,
                  style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Color(0xffA4A4A4),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _selectedIndex == 1
            ? AdminStatsticsScreen()
            : _selectedIndex == 2
                ? AdminProfileScreen()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        children: [
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child: Image.asset(
                                    'assets/pp.jpg',
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Admintesting',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Admin@gmail.com',
                                  style: TextStyle(
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
                          ]),
                          SizedBox(
                            height: 30,
                          ),
                          Column(
                            children: [
                              Center(
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Color(0xffEFF1FF),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Header Row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Upload File',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Icon(Icons.calendar_today,
                                              color: Colors.black54),
                                        ],
                                      ),
                                      SizedBox(height: 16),

                                      // File Upload Container
                                      GestureDetector(
                                        onTap: pickFile,
                                        child: Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            color: Color(0xffF0F4FF),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.insert_drive_file,
                                                  size: 40,
                                                  color: Colors.black54,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'choose file to upload',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 14,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Select zip, image, pdf or ms.word',
                                                  style: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      // Display selected file name if available
                                      if (selectedFile != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: Text(
                                            "Selected File: ${selectedFile!.path.split('/').last}",
                                            style: TextStyle(
                                                color: Colors.black87),
                                          ),
                                        ),

                                      // Progress bar
                                      if (uploadProgress != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: LinearProgressIndicator(
                                            value: uploadProgress,
                                            backgroundColor: Colors.grey[300],
                                            color: Colors.blue,
                                          ),
                                        ),

                                      // Action Buttons Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedFile =
                                                      null; // Clear selected file
                                                  uploadProgress =
                                                      null; // Reset upload progress
                                                });
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey[200],
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: selectedFile != null
                                                  ? () async {
                                                      // Start uploading and update progress
                                                      for (double i = 0;
                                                          i <= 1;
                                                          i += 0.1) {
                                                        await Future.delayed(
                                                            Duration(
                                                                milliseconds:
                                                                    200));
                                                        setState(() {
                                                          uploadProgress = i;
                                                        });
                                                      }
                                                      // Reset after upload
                                                      setState(() {
                                                        selectedFile = null;
                                                        uploadProgress = null;
                                                      });
                                                    }
                                                  : null, // Disable button if no file is selected
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    selectedFile != null
                                                        ? Colors.blue
                                                        : Colors.grey[400],
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text('Upload'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                height: 119,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xffEFF1FF),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(
                                          0, 2), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 10.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Select Employee',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: DropdownButton<String>(
                                            value: dropdownValue1,
                                            icon: Icon(Icons.arrow_drop_down),
                                            iconSize: 24,
                                            elevation: 16,
                                            isExpanded: true,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16),
                                            underline: SizedBox(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                dropdownValue1 = newValue!;
                                              });
                                            },
                                            items: <String>[
                                              'Admin',
                                              'Admin 1',
                                              'Admin 2',
                                              'Admin 3',
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),

                          //mothly attendance
                          Container(
                            padding: EdgeInsets.all(12),
                            height: 140,
                            decoration: BoxDecoration(
                              color: Color(0xffEFF1FF),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monthly Attendance',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: 330,
                                      height: 90,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: PieChart(
                                              PieChartData(
                                                  sections: [
                                                    PieChartSectionData(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      value: 4,
                                                      title: '',
                                                      radius: 12,
                                                    ),
                                                    PieChartSectionData(
                                                      color: Colors.orange,
                                                      value: 1,
                                                      title: '',
                                                      radius: 12,
                                                    ),
                                                    PieChartSectionData(
                                                      color: Colors.red,
                                                      value: 1,
                                                      title: '',
                                                      radius: 12,
                                                    ),
                                                  ],
                                                  sectionsSpace: 0,
                                                  centerSpaceRadius: 26),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 200,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '8',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Present',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                              0xff9E9E9E)),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '1',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                              0xffF6C15B)),
                                                    ),
                                                    Text(
                                                      'Late',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                              0xff9E9E9E)),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '0',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                              0xffEC5851)),
                                                    ),
                                                    Text(
                                                      'Absent',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                              0xff9E9E9E)),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffEFF1FF),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
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
                                CalendarFormat.month: 'Month'
                              },
                              headerVisible: true,
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
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
                            ),
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 142,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xffEFF1FF),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attendance Details',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        height: 82,
                                        width: 342,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 53,
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surface,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '06',
                                                        style: TextStyle(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'Tue',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '09.00 am',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Check In',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: 1,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.black),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '00.00 am',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Check In',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: 1,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.black),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '00.00 am',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Total Hrs',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Container(
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
              _buildSegmentNavigator('Home', 0, Icon(Icons.home)),
              _buildSegmentNavigator(
                  'Stats', 1, Icon(Icons.graphic_eq_outlined)),
              _buildSegmentNavigator('Profile', 2, Icon(Icons.person)),
            ],
          ),
        ),
      ),
    );
  }
}
