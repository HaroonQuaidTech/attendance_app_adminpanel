// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                          color: Colors.grey[200], // light background color
                          borderRadius:
                              BorderRadius.circular(12), // rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        'Notification',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
              ),
              //OUTER CONTAINER--------------------------------------------------------------------
              Container(
                height: 500,
                padding: EdgeInsets.symmetric(vertical: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color(0xffEFF1FF),
                    borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    // --------------------------------------- INSIDE container--------------------------------------------
                    Container(
                        width: 330,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors
                                      .grey[200], // light background color
                                  borderRadius: BorderRadius.circular(
                                      40), // rounded corners
                                ),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit dolor ',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '1m ago.',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff6C6C6C)),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 10),
                    Container(
                        width: 330,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors
                                      .grey[200], // light background color
                                  borderRadius: BorderRadius.circular(
                                      40), // rounded corners
                                ),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit dolor ',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '1d ago.',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff6C6C6C)),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 10),
                    Container(
                        width: 330,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors
                                      .grey[200], // light background color
                                  borderRadius: BorderRadius.circular(
                                      40), // rounded corners
                                ),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit dolor ',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '2d ago.',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff6C6C6C)),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 10),
                    Container(
                        width: 330,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors
                                      .grey[200], // light background color
                                  borderRadius: BorderRadius.circular(
                                      40), // rounded corners
                                ),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit dolor ',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '3d ago.',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff6C6C6C)),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 10),
                    Container(
                        width: 330,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors
                                      .grey[200], // light background color
                                  borderRadius: BorderRadius.circular(
                                      40), // rounded corners
                                ),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit dolor ',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '1M ago.',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff6C6C6C)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
