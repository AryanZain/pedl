import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedl/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'dart:convert';
import 'package:pedl/services/email_service.dart';
import 'package:http/http.dart' as http;

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> bikeData;
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final TimeOfDay pickupTime;
  final TimeOfDay dropoffTime;
  final String userId;
  final String userName;
  final String userEmail;

  const CheckoutPage({
    required this.bikeData,
    required this.pickupDate,
    required this.dropoffDate,
    required this.pickupTime,
    required this.dropoffTime,
    required this.userId,
    required this.userName,
    required this.userEmail,
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
  bool _saveCard = false;

  // Square Credentials - REPLACE WITH YOUR OWN
  static const String _squareApplicationId = 'sandbox-sq0idb--bP1LBAMJVwpwNku4XG-2g';
  static const String _squareLocationId = 'L5TNAS0THM7MP';
  static const String _squareAccessToken = 'EAAAl2npW7wryPNrtc83D0RATagawLTw_8Scjz20NbNLt6fqBpon4x2SA1Ibwz0y';

  @override
  void initState() {
    super.initState();
    _initializeSquare();
    _calculateTotal();
  }

  void _initializeSquare() async {
    try {
      await InAppPayments.setSquareApplicationId(_squareApplicationId);
    } catch (e) {
      print('Square initialization error: $e');
    }
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

  void _addNotification(Map<String, dynamic> booking) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications_${widget.userId}') ?? [];
    final message = 'Booking confirmed for ${booking['bike']['title']} - '
        '\$${booking['totalAmount'].toStringAsFixed(2)}';

    notifications.add(message);
    final unreadCount = (prefs.getInt('unread_${widget.userId}') ?? 0) + 1;

    await prefs.setStringList('notifications_${widget.userId}', notifications);
    await prefs.setInt('unread_${widget.userId}', unreadCount);
  }

  Future<void> _processPayment() async {
    if (_isProcessing || !_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      await InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: (cardDetails) async {
          try {
            final paymentSuccess = await _chargeCard(cardDetails.nonce);

            await InAppPayments.completeCardEntry(
              onCardEntryComplete: () async {
                if (paymentSuccess) {
                  await _handleSuccessfulPayment();
                } else {
                  _showPaymentError('Payment failed. Please try again.');
                }
              },
            );
          } catch (e) {
            await InAppPayments.completeCardEntry(
              onCardEntryComplete: () => _showPaymentError('Error: $e'),
            );
          }
        },
        onCardEntryCancel: () => _showPaymentError('Card entry canceled'),
      );
    } catch (e) {
      _showPaymentError('Payment failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<bool> _chargeCard(String cardNonce) async {
    try {
      final response = await http.post(
        Uri.parse('https://connect.squareupsandbox.com/v2/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_squareAccessToken',
        },
        body: json.encode({
          'source_id': cardNonce,
          'amount_money': {
            'amount': (totalAmount * 100).toInt(),
            'currency': 'AUD',
          },
          'idempotency_key': DateTime.now().millisecondsSinceEpoch.toString(),
          'location_id': _squareLocationId,
        }),
      );

      print('Payment Response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Payment Error: $e');
      return false;
    }
  }

  Future<void> _handleSuccessfulPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final booking = {
      'bike': widget.bikeData,
      'userEmail': widget.userEmail,
      'pickupDate': widget.pickupDate.toString(),
      'dropoffDate': widget.dropoffDate.toString(),
      'pickupTime': '${widget.pickupTime.hour}:${widget.pickupTime.minute}',
      'dropoffTime': '${widget.dropoffTime.hour}:${widget.dropoffTime.minute}',
      'totalAmount': totalAmount,
      'paymentDate': DateTime.now().toString(),
    };

    final bookings = prefs.getStringList('bookings_${widget.userId}') ?? [];
    bookings.add(json.encode(booking));
    await prefs.setStringList('bookings_${widget.userId}', bookings);

    await EmailService.sendBookingEmails(
      userEmail: widget.userEmail,
      userName: widget.userName,
      booking: booking,
      companyEmail: 'pedlaus123@gmail.com',
    );

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
  }

  void _showPaymentError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBikeDetailsCard(),
            const SizedBox(height: 20),
            _buildPaymentForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.bikeData['image'],
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(widget.bikeData['title'], style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text('Pickup: ${DateFormat('MMM d, y').format(widget.pickupDate)} ${widget.pickupTime.format(context)}'),
            Text('Dropoff: ${DateFormat('MMM d, y').format(widget.dropoffDate)} ${widget.dropoffTime.format(context)}'),
            const SizedBox(height: 10),
            Text('Total: \$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Expanded(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCardNumberField(),
              _buildExpiryField(),
              _buildCVVField(),
              _buildSaveCardOption(),
              const SizedBox(height: 30),
              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: _cardNumberController,
        decoration: _inputDecoration.copyWith(labelText: 'Card Number'),
        keyboardType: TextInputType.number,
        validator: (value) => value!.length != 16 ? 'Invalid card number' : null,
      ),
    );
  }

  Widget _buildExpiryField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: _expiryController,
        decoration: _inputDecoration.copyWith(labelText: 'Expiry (MM/YY)'),
        validator: (value) => value!.length != 5 ? 'Invalid expiry' : null,
      ),
    );
  }

  Widget _buildCVVField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: _cvvController,
        decoration: _inputDecoration.copyWith(labelText: 'CVV'),
        keyboardType: TextInputType.number,
        validator: (value) => value!.length != 3 ? 'Invalid CVV' : null,
      ),
    );
  }

  Widget _buildSaveCardOption() {
    return CheckboxListTile(
      title: const Text('Save card for future payments'),
      value: _saveCard,
      onChanged: (value) => setState(() => _saveCard = value ?? false),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _isProcessing ? null : _processPayment,
      child: _isProcessing
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
        'Pay Now',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
            _buildBookingDetailsCard(context),
            const SizedBox(height: 30),
            _buildContinueButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  bookingDetails['bike']['image'],
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(bookingDetails['bike']['title'], style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text('Amount Paid: \$${bookingDetails['totalAmount'].toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16)),
            Text('Payment Date: ${DateFormat('MMM d, y - hh:mm a').format(DateTime.parse(bookingDetails['paymentDate']))}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: userName,
            userId: userId,
            userEmail: bookingDetails['userEmail'],
          ),
        ),
      ),
      child: const Text(
        'Continue Shopping',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}