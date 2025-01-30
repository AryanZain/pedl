import 'package:pedl/services/auth.dart';
import 'package:pedl/termsandcondition.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'checkout.dart';
import 'package:intl/intl.dart';



class Calendar_Page extends StatelessWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  final String userEmail;
  const Calendar_Page({required this.userId,required this.userName,required this.bikeData,required this.userEmail,  Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarApp(userId: userId, userName: userName,bikeData: bikeData,userEmail: userEmail,),
    );
  }
}

class CalendarApp extends StatelessWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  final String userEmail;
  const CalendarApp({required this.userId,required this.userName,required this.bikeData,required this.userEmail,  Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarPage(userId: userId, userName: userName,bikeData: bikeData,userEmail: userEmail,),
    );
  }
}

class CalendarPage extends StatefulWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  final String userEmail;
  const CalendarPage({required this.userId,required this.userName,required this.bikeData,required this.userEmail,  Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 7));
  DateTime? _selectedPickupDay;
  DateTime? _selectedDropOffDay;
  TimeOfDay? _pickupTime;
  TimeOfDay? _dropOffTime;

  // Extract bike name with a fallback value
  String get bikeName => widget.bikeData['title']?.toString() ?? 'Unknown Bike';

  // Show a popup with the name of the selected bike
  /*void  _showBikePopup(String bikeName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Selected Bike"),
          content: Text("You have selected the bike: $bikeName"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }*/

  // Show error popup for validation failures
  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

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
                builder: (context) => termsandcondition(userId: widget.userId, userName: widget.userName,bikeData: widget.bikeData,userEmail: widget.userEmail,),
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
            firstDay: DateTime.now().add(const Duration(days: 1)),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedPickupDay, day) ||
                  isSameDay(_selectedDropOffDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_selectedPickupDay == selectedDay) {
                  // Deselect the pickup day
                  _selectedPickupDay = null;
                } else if (_selectedDropOffDay == selectedDay) {
                  // Deselect the drop-off day
                  _selectedDropOffDay = null;
                } else if (_selectedPickupDay == null) {
                  if (selectedDay.isAfter(DateTime.now().add(const Duration(days: 1)))) {
                    _selectedPickupDay = selectedDay;
                  } else {
                    _showErrorPopup("Pickup date must be at least 24 hours from the booking date.");
                  }
                } else if (_selectedDropOffDay == null) {
                  if (selectedDay.isAfter(_selectedPickupDay!)) {
                    final duration = selectedDay.difference(_selectedPickupDay!).inDays;
                    if (duration >= 7) {
                      _selectedDropOffDay = selectedDay;
                    } else {
                      _showErrorPopup("Drop-off date must be at least 7 days after the pickup date.");
                    }
                  } else {
                    _showErrorPopup("Drop-off date must be after the pickup date.");
                  }
                } else {
                  _selectedPickupDay = selectedDay;
                  _selectedDropOffDay = null;
                }
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 20),

          // ADD THIS SECTION FOR DISPLAYING SELECTED DATES
          if (_selectedPickupDay != null || _selectedDropOffDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedPickupDay != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Pickup Date:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('d MMM yyyy').format(_selectedPickupDay!),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  if (_selectedDropOffDay != null)
                    const SizedBox(height: 10), // Spacing between the two rows
                  if (_selectedDropOffDay != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Drop-Off Date:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('d MMM yyyy').format(_selectedDropOffDay!),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
                ],
              ),

            ),

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
                        setState(() {
                          _pickupTime = picked;
                        });
                      }
                    },
                    child: Text(_pickupTime != null
                        ? _pickupTime!.format(context)
                        : 'Select Time'),
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
                        setState(() {
                          _dropOffTime = picked;
                        });
                      }
                    },
                    child: Text(_dropOffTime != null
                        ? _dropOffTime!.format(context)
                        : 'Select Time'),
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
                if (_selectedPickupDay != null && _pickupTime != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: const Text(
                        'Confirm Booking',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'Thank you for booking $bikeName! Your pickup is scheduled for ${DateFormat('d MMM yyyy').format(_selectedPickupDay!)} at ${_pickupTime!.format(context)}.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (_selectedPickupDay != null && _pickupTime != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    bikeData: widget.bikeData,
                                    pickupDate: _selectedPickupDay!,
                                    dropoffDate: _selectedDropOffDay!,
                                    pickupTime: _pickupTime!,
                                    dropoffTime: _dropOffTime!,
                                    userId: widget.userId,
                                    userName: widget.userName,
                                    userEmail: widget.userEmail,
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text(
                'BOOK NOW',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          /*const Text(
            'No Upcoming Rentals',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),*/
          //const SizedBox(height: 5),
          /*const Text(
            'Lorem ipsum dolor sit amet, consectetur',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),*/
          const SizedBox(height: 40),
        ],

      ),
    );
  }
}
