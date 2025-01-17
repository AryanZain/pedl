import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

class BookmarkPage extends StatefulWidget {
  final String userId; // Add userId

  const BookmarkPage({required this.userId, Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late SharedPreferences _prefs;
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  // Load bookmarks for the current user
  Future<void> _loadBookmarks() async {
    _prefs = await SharedPreferences.getInstance();
    String? bookmarksString = _prefs.getString('bookmarks_${widget.userId}');
    if (bookmarksString != null) {
      setState(() {
        _bookmarks = List<Map<String, dynamic>>.from(
          json.decode(bookmarksString),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _bookmarks.isEmpty
          ? const Center(child: Text('No bookmarks yet!'))
          : ListView.builder(
        itemCount: _bookmarks.length,
        itemBuilder: (context, index) {
          final bike = _bookmarks[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.asset(bike['image'], fit: BoxFit.cover),
              title: Text(bike['title']),
              subtitle: Text(bike['subtitle']),
            ),
          );
        },
      ),
    );
  }
}
