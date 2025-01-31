import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart';
class NotificationPage extends StatefulWidget {
  final String userId;

  const NotificationPage({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> notifications = [];
  List<bool> isRead = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications =
          prefs.getStringList('notifications_${widget.userId}') ?? [];
      isRead = List<bool>.filled(notifications.length, false);
    });
  }

  void _markNotificationsAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_${widget.userId}', 0); // Reset unread count
    setState(() {
      isRead = List<bool>.filled(notifications.length, true); // Mark all as read
    });
  }

  void _deleteNotification(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications.removeAt(index);
      prefs.setStringList('notifications_${widget.userId}', notifications);
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markNotificationsAsRead();
    });

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
                return Dismissible(
                  key: Key(notifications[index]),
                  background: Container(color: Colors.red),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deleteNotification(index),
                  child: ListTile(
                    leading: const Icon(Icons.directions_bike,
                        color: Colors.redAccent),
                    title: Text(notifications[index]),
                    subtitle:
                        Text('${DateTime.now().toString().split(' ')[0]}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteNotification(index),
                    ),
                    tileColor: isRead[index] ? Colors.grey[100] : Colors.white,
                  ),
                );
              },
            ),
    );
  }
}
