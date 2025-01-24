import 'package:flutter/material.dart';

class BookedBikesPage extends StatelessWidget {
  final List<Map<String, dynamic>> bookedBikes;

  const BookedBikesPage({Key? key, required this.bookedBikes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Bikes"),
        backgroundColor: Colors.redAccent,
      ),
      body: bookedBikes.isEmpty
          ? const Center(
        child: Text(
          "No bikes booked",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: bookedBikes.length,
        itemBuilder: (context, index) {
          final bike = bookedBikes[index];
          return ListTile(
            leading: Image.asset(bike['image'], width: 50, height: 50, fit: BoxFit.cover),
            title: Text(bike['title']),
            subtitle: Text(bike['subtitle']),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle bike details navigation
            },
          );
        },
      ),
    );
  }
}