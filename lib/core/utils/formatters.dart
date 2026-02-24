import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    return formatter.format(value);
  }

  static String formatCurrencySimple(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  static double parseCurrency(String value) {
    final cleaned = value.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final int maxDigits;

  CurrencyInputFormatter({this.maxDigits = 8});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove tudo exceto dígitos
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    if (digitsOnly.length > maxDigits) {
      digitsOnly = digitsOnly.substring(0, maxDigits);
    }

    // Converte para double (centavos)
    double value = double.parse(digitsOnly) / 100;

    // Formata com vírgula
    String formatted = value.toStringAsFixed(2).replaceAll('.', ',');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
