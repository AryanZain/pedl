import 'package:pedl/services/auth.dart';
import 'package:pedl/termsandcondition.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'bike.dart';
import 'checkout.dart';
import 'home.dart';
class Calendar_Page extends StatelessWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  const Calendar_Page({required this.userId,required this.userName,required this.bikeData,  Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarApp(userId: userId, userName: userName,bikeData: bikeData,),
    );
  }
}

class CalendarApp extends StatelessWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  const CalendarApp({required this.userId,required this.userName,required this.bikeData,  Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarPage(userId: userId, userName: userName,bikeData: bikeData,),
    );
  }
}

class CalendarPage extends StatefulWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  const CalendarPage({required this.userId,required this.userName,required this.bikeData,  Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            await AuthServices().signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => termsandcondition(userId: widget.userId, userName: widget.userName,bikeData: widget.bikeData,),
              ),
            );
          },
        ),
        title: const Text('Calendar', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    'Pick-Up Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        // Handle pick-up time
                      }
                    },
                    child: const Text('10:00 AM'),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Drop-Off Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        // Handle drop-off time
                      }
                    },
                    child: const Text('4:00 PM'),
                  ),
                ],
              ),

            ],
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: const Text(
                      'Booking Confirmed',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Thank you for booking E-MONO 26! Your pickup is scheduled for 2 Oct 2024 at 10AM.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await AuthServices().signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => checkout(userId: widget.userId,userName: widget.userName,bikeData: widget.bikeData,),
                            ),
                          );
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'BOOK NOW',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const Text(
            'No Upcoming Rentals',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Lorem ipsum dolor sit amet, consectetur',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
        ],

      ),
    );
  }
}
