import 'package:flutter/services.dart';

/// Formats numeric CPF/CNPJ input without moving the cursor to the end.
class DocumentInputFormatter extends TextInputFormatter {
  DocumentInputFormatter({required this.isCompany});

  final bool isCompany;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;
    final mask = isCompany ? '00.000.000/0000-00' : '000.000.000-00';
    final limit = isCompany ? 14 : 11;
    String digitsOf(String text) => text.replaceAll(RegExp(r'\D'), '');
    int digitsBefore(int offset) => digitsOf(
      newValue.text.substring(0, offset.clamp(0, newValue.text.length)),
    ).length;

    var digits = digitsOf(newValue.text);
    var base = digitsBefore(newValue.selection.baseOffset);
    var extent = digitsBefore(newValue.selection.extentOffset);
    // Backspace over a separator should also remove the preceding digit.
    if (oldValue.selection.isCollapsed &&
        newValue.selection.isCollapsed &&
        newValue.text.length < oldValue.text.length &&
        newValue.selection.baseOffset < oldValue.selection.baseOffset &&
        digits == digitsOf(oldValue.text) &&
        base > 0) {
      digits = digits.replaceRange(base - 1, base, '');
      base--;
      extent = base;
    }
    if (digits.length > limit) digits = digits.substring(0, limit);
    final formatted = StringBuffer();
    var index = 0;
    for (final character in mask.split('')) {
      if (index >= digits.length) break;
      formatted.write(character == '0' ? digits[index++] : character);
    }
    final text = formatted.toString();
    int cursorFor(int count) {
      count = count.clamp(0, digits.length);
      if (count == 0) return 0;
      var seen = 0;
      for (var i = 0; i < text.length; i++) {
        if (RegExp(r'\d').hasMatch(text[i]) && ++seen == count) return i + 1;
      }
      return text.length;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: cursorFor(base),
        extentOffset: cursorFor(extent),
      ),
    );
  }
}
