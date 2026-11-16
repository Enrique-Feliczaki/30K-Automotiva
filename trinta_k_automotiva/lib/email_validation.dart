const invalidEmailError = 'Informe um e-mail válido';

final _localPartPattern = RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+$");
final _domainLabelPattern = RegExp(
  r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$',
);
String? validateRegistrationEmail(String? value) {
  final email = value?.trim() ?? '';
  final parts = email.split('@');
  if (parts.length != 2) return invalidEmailError;

  final localPart = parts.first;
  if (localPart.isEmpty ||
      localPart.startsWith('.') ||
      localPart.endsWith('.') ||
      localPart.contains('..') ||
      !_localPartPattern.hasMatch(localPart)) {
    return invalidEmailError;
  }

  final domainLabels = parts.last.split('.');
  if (domainLabels.length < 2 ||
      domainLabels.any((label) => !_domainLabelPattern.hasMatch(label))) {
    return invalidEmailError;
  }

  final normalizedLabels = domainLabels
      .map((label) => label.toLowerCase())
      .toList();
  final hasValidSuffix =
      normalizedLabels.last == 'com' ||
      (normalizedLabels.length >= 3 &&
          normalizedLabels[normalizedLabels.length - 2] == 'com' &&
          normalizedLabels.last == 'br');
  return hasValidSuffix ? null : invalidEmailError;
}
