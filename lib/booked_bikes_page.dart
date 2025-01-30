import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class BookedBikesPage extends StatefulWidget {
  final String userId;

  const BookedBikesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _BookedBikesPageState createState() => _BookedBikesPageState();
}

class _BookedBikesPageState extends State<BookedBikesPage> {
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingStrings = prefs.getStringList('bookings_${widget.userId}') ?? [];

    setState(() {
      _bookings = bookingStrings.map((bookingJson) {
        return Map<String, dynamic>.from(json.decode(bookingJson));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Bookings"),
        backgroundColor: Colors.redAccent,
      ),
      body: _bookings.isEmpty
          ? const Center(
        child: Text(
          "No bookings found",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return _BookingCard(booking: booking);
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingCard({required this.booking, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bikeData = Map<String, dynamic>.from(booking['bike']);
    final pickupDate = DateTime.parse(booking['pickupDate']);
    final dropoffDate = DateTime.parse(booking['dropoffDate']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  bikeData['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bikeData['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bikeData['subtitle'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Dates',
              '${DateFormat('MMM d').format(pickupDate)} - ${DateFormat('MMM d').format(dropoffDate)}',
            ),
            _buildDetailRow(
              'Pickup Time',
              booking['pickupTime'],
            ),
            _buildDetailRow(
              'Dropoff Time',
              booking['dropoffTime'],
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Total Amount',
              '\$${booking['totalAmount'].toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}