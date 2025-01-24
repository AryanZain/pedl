
import 'package:flutter/material.dart';
import 'package:pedl/services/auth.dart';

import 'bike.dart';
import 'calender.dart';


class termsandcondition extends StatelessWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  const termsandcondition({required this.userId,required this.userName,required this.bikeData,  Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TermsAndConditionsPage(userId: userId, userName: userName,bikeData: bikeData,), // Pass userId
    );
  }
}

class TermsAndConditionsPage extends StatefulWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  const TermsAndConditionsPage({required this.userId, required this.userName,required this.bikeData, Key? key}) : super(key: key);

  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            // Handle back navigation
            await AuthServices().signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BikeDetailsApp(userId: widget.userId, userName: widget.userName,
                  bikeData: widget.bikeData,
                ),
              ),
            );
          },
        ),
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms and Conditions Pedl',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '''
These Terms are entered into between PedL Pty Ltd ABN 66 638 872 205 and ACN 638 872 205 5 (“PedL”, “we”, “us”, “our”) and the party named in the application for renting the PedL bike.

1) Security Deposit
A security deposit of \$250 is payable after agreeing to rental terms with PedL. It covers equipment (helmet, lights, phone holder, lock, and bike parts). Costs for damages or replacements will be deducted. Deposits are non-refundable for rent-to-buy plans.

2) Fees and Payment Terms
Fees are paid in 2-week increments upfront via direct debit. Rent-to-buy requires 4 weeks paid upfront at \$130 per week. All rental fees are non-refundable.

3) Late and Missed Payments
Missed payments incur a \$10 weekly fee. After 2 missed payments, the bike must be returned.

4) Rental Period
Rentals are agreed upon for a specific period. Late returns after 10 AM incur an additional week’s fee.

5) Termination of Agreement
The agreement may be terminated after 2 missed payments or due to misuse/damage. The bike must be returned immediately.

6) Maintenance
General maintenance is free (brakes, chains, etc.), but breakdowns like punctures are your responsibility.

7) Theft or Damage
In case of theft or loss, report with a police report. A \$1,500 fee applies, excluding the bond.

8) Key Ways to Avoid Theft
Always lock the bike securely and store it safely inside your house.

9) Insurance
Optional insurance is recommended for rentals over 4 weeks at \$10 per week. Theft or irreparable damage incurs a \$500 excess fee.

10) Authorized Use
Only the renter is permitted to use the bike.

11) Australian Consumer Law
This agreement does not exclude any guarantees under Australian Consumer Law.

Appendix A: Part Replacement Costs
                      ''',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Replacement Costs Table',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildReplacementTable(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                  activeColor: Colors.red,
                ),
                const Text(
                  'Agree to the terms and Conditions',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: isChecked
                    ? () async {
                  await AuthServices().signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => Calendar_Page(
                        userId: widget.userId,
                        userName: widget.userName,
                        bikeData: widget.bikeData,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked ? Colors.red : Colors.grey.shade300,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'CONTINUE TO CHECKOUT',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _buildReplacementTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Part', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Cost', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: const [
        DataRow(cells: [DataCell(Text('Lights (Front/Back)')), DataCell(Text('\$30'))]),
        DataRow(cells: [DataCell(Text('Lock')), DataCell(Text('\$80'))]),
        DataRow(cells: [DataCell(Text('Saddle')), DataCell(Text('\$70'))]),
        DataRow(cells: [DataCell(Text('Seatpost')), DataCell(Text('\$40'))]),
        DataRow(cells: [DataCell(Text('Rear Rack')), DataCell(Text('\$130'))]),
        DataRow(cells: [DataCell(Text('Handlebar')), DataCell(Text('\$60'))]),
        DataRow(cells: [DataCell(Text('Phone Holder')), DataCell(Text('\$50'))]),
        DataRow(cells: [DataCell(Text('LCD Display')), DataCell(Text('\$180'))]),
        DataRow(cells: [DataCell(Text('Battery')), DataCell(Text('\$400 - \$700'))]),
        DataRow(cells: [DataCell(Text('Brake Cable')), DataCell(Text('\$30'))]),
        DataRow(cells: [DataCell(Text('Brake Lever')), DataCell(Text('\$70'))]),
        DataRow(cells: [DataCell(Text('Disc Brake')), DataCell(Text('\$30'))]),
        DataRow(cells: [DataCell(Text('Chain')), DataCell(Text('\$40'))]),
        DataRow(cells: [DataCell(Text('Gear Shifters')), DataCell(Text('\$85'))]),
        DataRow(cells: [DataCell(Text('Shifter Cable')), DataCell(Text('\$65'))]),
        DataRow(cells: [DataCell(Text('Tyre')), DataCell(Text('\$40'))]),
        DataRow(cells: [DataCell(Text('Spokes (more than 3)')), DataCell(Text('\$30'))]),
        DataRow(cells: [DataCell(Text('Wheels')), DataCell(Text('\$140'))]),
      ],
    );
  }
}
