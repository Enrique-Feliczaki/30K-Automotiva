const requiredAddressFieldError = 'Campo obrigatório';
const invalidPostalCodeError = 'Informe um CEP válido';
const invalidStateError = 'Informe a sigla do estado com 2 letras';
const invalidAddressTextError = 'Use apenas letras, números e espaços';
const invalidHouseNumberError = 'Use apenas números';
const invalidHouseNumberLengthError = 'Use no máximo 6 dígitos';
const maximumHouseNumberLength = 6;

final _postalCodePattern = RegExp(r'^(?:[0-9]{8}|[0-9]{5}-[0-9]{3})$');
final _statePattern = RegExp(r'^[A-Za-z]{2}$');
final _addressTextPattern = RegExp(
  r'^[\p{L}\p{M}\p{N}]+(?: +[\p{L}\p{M}\p{N}]+)*$',
  unicode: true,
);
final _addressTextContentPattern = RegExp(r'[\p{L}\p{N}]', unicode: true);
final _houseNumberPattern = RegExp(r'^[0-9]+$');

String? validatePostalCode(String? value) {
  final postalCode = value?.trim() ?? '';
  return _postalCodePattern.hasMatch(postalCode)
      ? null
      : invalidPostalCodeError;
}

String? validateState(String? value) {
  final state = value?.trim() ?? '';
  if (state.isEmpty) return requiredAddressFieldError;
  return _statePattern.hasMatch(state) ? null : invalidStateError;
}

String? validateAddressText(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return requiredAddressFieldError;
  return _addressTextPattern.hasMatch(text) &&
          _addressTextContentPattern.hasMatch(text)
      ? null
      : invalidAddressTextError;
}

String? validateHouseNumber(String? value) {
  final number = value?.trim() ?? '';
  if (number.isEmpty) return requiredAddressFieldError;
  if (!_houseNumberPattern.hasMatch(number)) return invalidHouseNumberError;
  return number.length <= maximumHouseNumberLength
      ? null
      : invalidHouseNumberLengthError;
}
