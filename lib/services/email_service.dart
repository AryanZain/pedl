import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';

class EmailService {
  static final smtpServer = gmail('waqarpns655@gmail.com', 'irxtclznouuwwyaw');

  static Future<void> sendBookingEmails({
    required String userEmail,
    required String userName,
    required Map<String, dynamic> booking,
    required String companyEmail,
  }) async {
    final userMessage = _buildUserEmail(booking, userName);
    final companyMessage = _buildCompanyEmail(booking, userName);

    try {
      await send(userMessage, smtpServer);
      await send(companyMessage, smtpServer);
    } catch (e) {
      print('Error sending emails: $e');
    }
  }

  static Message _buildUserEmail(Map<String, dynamic> booking, String userName) {
    final dateFormat = DateFormat('MMM d, y - hh:mm a');
    final pickupDate = dateFormat.format(DateTime.parse(booking['pickupDate']));

    return Message()
      ..from = const Address('noreply@pedl.com', 'PedL Team')
      ..recipients.add(booking['userEmail'])
      ..subject = 'Booking Confirmation #${DateTime.now().millisecondsSinceEpoch}'
      ..html = '''
        <h1>Thanks for booking with PedL, $userName!</h1>
        <h2>Booking Details:</h2>
        <p>Bike: ${booking['bike']['title']}</p>
        <p>Total Amount: \$${booking['totalAmount'].toStringAsFixed(2)}</p>
        <p>Pickup Date: $pickupDate</p>
        <p>Need help? Contact us at support@pedl.com</p>
      ''';
  }

  static Message _buildCompanyEmail(Map<String, dynamic> booking, String userName) {
    return Message()
      ..from = const Address('noreply@pedl.com', 'PedL System')
      ..recipients.add('company@pedl.com') // Hardcoded company email
      ..subject = 'New Booking Notification'
      ..html = '''
        <h1>New Booking Received</h1>
        <p>User: $userName (${booking['userEmail']})</p>
        <p>Bike: ${booking['bike']['title']}</p>
        <p>Total Amount: \$${booking['totalAmount'].toStringAsFixed(2)}</p>
      ''';
  }
}