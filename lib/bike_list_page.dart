import 'package:flutter/material.dart';

import 'bike.dart';

class BikeListPage extends StatelessWidget {
  final String userId;
  final List<Map<String, dynamic>> bikes;

  const BikeListPage({required this.userId, required this.bikes, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Bikes"),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: bikes.length,
        itemBuilder: (context, index) {
          final bike = bikes[index];
          return ListTile(
            leading: Image.asset(bike['image'], width: 50, height: 50, fit: BoxFit.cover),
            title: Text(bike['title']),
            subtitle: Text(bike['subtitle']),
            onTap: () {
            },
          );
        },
      ),
    );
  }
}
