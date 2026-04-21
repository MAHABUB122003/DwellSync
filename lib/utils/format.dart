class AppFormat {
  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}