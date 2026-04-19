import 'package:intl/intl.dart';

class FormatUtils {
  // Format currency
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format date
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');
    return formatter.format(dateTime);
  }

  // Format time only
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  // Format month and year
  static String formatMonthYear(DateTime date) {
    final formatter = DateFormat('MMMM yyyy');
    return formatter.format(date);
  }

  // Format phone number
  static String formatPhone(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format as (XXX) XXX-XXXX
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length > 10) {
      return cleaned;
    }
    return phone;
  }

  // Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Validate phone
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10}$|^\+?[0-9]{10,}$');
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return phoneRegex.hasMatch(cleaned);
  }

  // Validate password
  static bool isValidPassword(String password) {
    // At least 6 characters, 1 uppercase, 1 lowercase, 1 number
    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');
    return passwordRegex.hasMatch(password);
  }

  // Get password strength
  static String getPasswordStrength(String password) {
    if (password.isEmpty) return 'No password';
    if (password.length < 6) return 'Weak';
    if (isValidPassword(password)) return 'Strong';
    return 'Medium';
  }

  // Truncate text
  static String truncateText(String text, {int length = 20}) {
    if (text.length > length) {
      return '${text.substring(0, length)}...';
    }
    return text;
  }

  // Get initials from name
  static String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  // Days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    return dateToCheck.difference(today).inDays;
  }

  // Is overdue
  static bool isOverdue(DateTime date) {
    return daysUntil(date) < 0;
  }
}
