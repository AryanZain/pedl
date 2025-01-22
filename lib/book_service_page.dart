import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

class BookServicePage extends StatefulWidget {
  final String userEmail;

  const BookServicePage({required this.userEmail, Key? key}) : super(key: key);

  @override
  State<BookServicePage> createState() => _BookServicePageState();
}

class _BookServicePageState extends State<BookServicePage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Hardcoded sender email
  final String senderEmail = 'waqarpns655@gmail.com';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInitSettings);
    _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showNotification(String message) async {
    const androidDetails = AndroidNotificationDetails('service_channel', 'Service Notifications',
        channelDescription: 'Notifications for service bookings', importance: Importance.high, priority: Priority.high);
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, 'Service Reminder', message, notificationDetails);
  }

 /* Future<void> _sendEmail() async {
    final Email email = Email(
      body: 'Your bike service is confirmed for ${_selectedDate!.toLocal()} at ${_selectedTime!.format(context)}.',
      subject: 'Bike Service Confirmation',
      recipients: [widget.userEmail],
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }*/
  /*Future<void> _sendEmail() async {
    // Ensure the date and time are selected
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both a date and time before booking.')),
      );
      return;
    }
    // Prepare the email details
    final Email email = Email(
      body:
      'Hello,\n\nYour bike service is confirmed for ${_selectedDate!.toLocal()} at ${_selectedTime!.format(context)}.\n\nThank you for choosing us!',
      subject: 'Bike Service Confirmation',
      recipients: [widget.userEmail],
      cc: [],
      bcc: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Confirmation email sent to ${widget.userEmail}')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send email.')));
    }
  }*/



  Future<void> _sendEmail() async {
    // Define SMTP server details
    final smtpServer = SmtpServer(
      'smtp.gmail.com', // SMTP server for Gmail
      port: 587,
      username: 'waqarpns655@gmail.com', // Sender email
      password: 'irxtclznouuwwyaw', // App-specific password or SMTP password
    );

    // Create the email message
    final emailMessage = mailer.Message()
      ..from = mailer.Address('waqarpns655@gmail.com', 'Bike Service Team') // Hardcoded sender email
      ..recipients.add(widget.userEmail) // Recipient email
      ..subject = 'Bike Service Confirmation'
      ..text = '''
Hello,

Your bike service is confirmed for ${_selectedDate!.toLocal()} at ${_selectedTime!.format(context)}.

Thank you for choosing us!
''';

    try {
      // Send the email
      final sendReport = await mailer.send(emailMessage, smtpServer);
      print('Email sent: ${sendReport.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Confirmation email sent to ${widget.userEmail}')));
    } on mailer.MailerException catch (e) {
      // Handle email sending errors
      print('Email sending failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send email.')));
    }
  }







  /*void _confirmBooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both a date and time for your service.')),
      );
      return;
    }

    final formattedDate = '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}';
    final formattedTime = _selectedTime!.format(context);

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Booking Confirmed'),
        content: Text('Your service is booked for $formattedDate at $formattedTime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK'),
          ),
        ],
      ),
    );

    // Send email and in-app notification
    await _sendEmail();
    await _showNotification('Your bike service is on $formattedDate at $formattedTime.');
  }*/

  Future<void> _confirmBooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both a date and time for your service.')),
      );
      return;
    }

    final formattedDate = '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}';
    final formattedTime = _selectedTime!.format(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Booking Confirmed'),
        content: Text('Your service is booked for $formattedDate at $formattedTime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK'),
          ),
        ],
      ),
    );

    // Send email and notification
    await _sendEmail();
    await _showNotification('Your bike service is on $formattedDate at $formattedTime.');
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Service',
            style: TextStyle( color: Colors.white)),
        backgroundColor: Colors.redAccent,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Service Date', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                setState(() => _selectedDate = date);
              },
              child: Text(_selectedDate == null
                  ? 'Choose Date'
                  : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}'),
            ),
            SizedBox(height: 20),
            Text('Select Service Time', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                setState(() => _selectedTime = time);
              },
              child: Text(_selectedTime == null ? 'Choose Time' : _selectedTime!.format(context)),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                child: Text('Book Service'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
