import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<String> notifications;

  NotificationPage({Key? key, required this.notifications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.redAccent,
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          "No Notifications",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notification_important, color: Colors.redAccent),
            title: Text(notifications[index]),
          );
        },
      ),
    );
  }
}