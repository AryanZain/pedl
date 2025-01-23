// lib/contact_us_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            SectionTitle(icon: Icons.place, title: "Visit Us"),
            SizedBox(height: 10),
            ContactDetail(
              label: "Showroom:",
              value: "11 Gibbons St, Redfern NSW 2016, Australia",
            ),
            ContactDetail(
              label: "Service and Maintenance:",
              value: "138 Regent St, Redfern NSW 2016, Australia",
            ),
            SizedBox(height: 50),
            SectionTitle(icon: Icons.phone, title: "Call"),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Phone: 0291717860",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 50),
            SectionTitle(icon: Icons.email, title: "Email"),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "contact@pedl.com.au",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 50),
            SectionTitle(icon: Icons.access_time, title: "In-Store Open Hours"),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Mon – Fri: 9:30am – 6:00pm\n\nSaturday: 10:00am – 4:00pm",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionTitle({required this.icon, required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent,size: 30),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
      ],
    );
  }
}

class ContactDetail extends StatelessWidget {
  final String label;
  final String value;

  const ContactDetail({required this.label, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
