import 'package:flutter/services.dart';

/// Accepts four digits and inserts the MM/AA separator automatically.
class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;
    String digitsOf(String text) => text.replaceAll(RegExp(r'\D'), '');
    int digitsBefore(int offset) => digitsOf(
      newValue.text.substring(0, offset.clamp(0, newValue.text.length)),
    ).length;

    var digits = digitsOf(newValue.text);
    var base = digitsBefore(newValue.selection.baseOffset);
    var extent = digitsBefore(newValue.selection.extentOffset);
    // Backspacing over the inserted slash also removes the preceding digit.
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
    if (digits.length > 4) digits = digits.substring(0, 4);
    final text = digits.length < 2
        ? digits
        : '${digits.substring(0, 2)}/${digits.substring(2)}';
    int cursorFor(int count) {
      count = count.clamp(0, digits.length);
      return count < 2 ? count : count + 1;
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
