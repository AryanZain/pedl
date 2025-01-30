import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedl/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'dart:convert';
import 'package:pedl/services/email_service.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> bikeData;
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final TimeOfDay pickupTime;
  final TimeOfDay dropoffTime;
  final String userId;
  final String userName;
  final String userEmail; // Added userEmail parameter

  const CheckoutPage({
    required this.bikeData,
    required this.pickupDate,
    required this.dropoffDate,
    required this.pickupTime,
    required this.dropoffTime,
    required this.userId,
    required this.userName,
    required this.userEmail, // Added userEmail
    Key? key,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final InputDecoration _inputDecoration = InputDecoration(
    labelStyle: TextStyle(color: Colors.grey[600]),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.0),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[400]!),
    ),
  );
  double totalAmount = 0.0;
  bool _isProcessing = false;
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSquare();
    _calculateTotal();
  }

  void _initializeSquare() async {
    await InAppPayments.setSquareApplicationId('sandbox-sq0idb--bP1LBAMJVwpwNku4XG-2g');
  }

  void _calculateTotal() {
    final pricePart = widget.bikeData['subtitle'].split(' ')[1];
    final priceString = pricePart.replaceAll('\$', '').replaceAll(',', '');
    final weeklyPrice = double.parse(priceString);

    final days = widget.dropoffDate.difference(widget.pickupDate).inDays;
    final weeks = (days / 7).ceil();

    setState(() {
      totalAmount = weeklyPrice * weeks;
    });
  }

  // Add notification to SharedPreferences
  void _addNotification(Map<String, dynamic> booking) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications_${widget.userId}') ?? [];

    final message = 'Booking confirmed for ${booking['bike']['title']} - '
        '\$${booking['totalAmount'].toStringAsFixed(2)}';

    notifications.add(message);
    await prefs.setStringList('notifications_${widget.userId}', notifications);
  }

  Future<void> _processPayment() async {
    if (_isProcessing || !_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      await InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: (cardDetails) async {
          try {
            await InAppPayments.completeCardEntry(
              onCardEntryComplete: () async {
                final prefs = await SharedPreferences.getInstance();

                // Create booking data with user email
                final booking = {
                  'bike': widget.bikeData,
                  'userEmail': widget.userEmail, // Use actual user email
                  'pickupDate': widget.pickupDate.toString(),
                  'dropoffDate': widget.dropoffDate.toString(),
                  'pickupTime': '${widget.pickupTime.hour}:${widget.pickupTime.minute}',
                  'dropoffTime': '${widget.dropoffTime.hour}:${widget.dropoffTime.minute}',
                  'totalAmount': totalAmount,
                  'paymentDate': DateTime.now().toString(),
                };

                // Save booking
                final bookings = prefs.getStringList('bookings_${widget.userId}') ?? [];
                bookings.add(json.encode(booking));
                await prefs.setStringList('bookings_${widget.userId}', bookings);

                // Send emails
                await EmailService.sendBookingEmails(
                  userEmail: widget.userEmail,
                  userName: widget.userName,
                  booking: booking,
                  companyEmail: 'pedlaus123@gmail.com',
                );

                // Add notification
                _addNotification(booking);

                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentSuccessPage(
                      bookingDetails: booking,
                      userId: widget.userId,
                      userName: widget.userName,
                    ),
                  ),
                );
              },
            );
          } catch (e) {
            await InAppPayments.showCardNonceProcessingError('Payment failed');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
        onCardEntryCancel: () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card entry canceled')),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9, // Adjust this ratio as needed (try 4/3 or 3/2)
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            widget.bikeData['image'],
                            fit: BoxFit.contain, // Changed from 'cover' to 'contain'
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(widget.bikeData['title'],
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text('Pickup: ${DateFormat('MMM d, y').format(widget.pickupDate)} ${widget.pickupTime.format(context)}'),
                    Text('Dropoff: ${DateFormat('MMM d, y').format(widget.dropoffDate)} ${widget.dropoffTime.format(context)}'),
                    const SizedBox(height: 10),
                    Text('Total: \$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: TextFormField(
                        controller: _cardNumberController,
                        decoration: _inputDecoration.copyWith(labelText: 'Card Number'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.length != 16 ? 'Invalid card number' : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: _inputDecoration.copyWith(labelText: 'Expiry (MM/YY)'),
                        validator: (value) => value!.length != 5 ? 'Invalid expiry' : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: _inputDecoration.copyWith(labelText: 'CVV'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.length != 3 ? 'Invalid CVV' : null,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isProcessing ? null : _processPayment,
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Pay Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;
  final String userId;
  final String userName;

  const PaymentSuccessPage({
    required this.bookingDetails,
    required this.userId,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Successful')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bookingDetails['bike']['title'],
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text('Amount Paid: \$${bookingDetails['totalAmount'].toStringAsFixed(2)}'),
                    Text('Payment Date: ${DateFormat('MMM d, y - hh:mm a').format(DateTime.parse(bookingDetails['paymentDate']))}'),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      userName: userName,
                      userId: userId,
                      userEmail: bookingDetails['userEmail'], // Use actual email from booking
                    ),
                  ),
                );
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}