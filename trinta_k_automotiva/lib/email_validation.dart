const invalidEmailError = 'Informe um e-mail válido';
const acceptedRegistrationEmailSuffixes = {
  'com',
  'com.br',
  'co',
  'co.uk',
  'net',
  'net.br',
  'org',
  'org.br',
  'edu',
  'edu.br',
  'gov',
  'gov.br',
  'info',
  'biz',
  'io',
  'app',
  'dev',
  'me',
  'tech',
  'online',
  'store',
  'site',
  'pt',
};
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
      domainLabels.any((label) => !_domainLabelPattern.hasMatch(label)) ||
      domainLabels
          .take(domainLabels.length - 1)
          .any((label) => label.length < 2)) {
    return invalidEmailError;
  }

  final domain = parts.last.toLowerCase();
  final hasAcceptedSuffix = acceptedRegistrationEmailSuffixes.any(
    (suffix) => domain == suffix || domain.endsWith('.$suffix'),
  );
  return hasAcceptedSuffix ? null : invalidEmailError;
}
