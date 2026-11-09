class CustomerProfile {
  CustomerProfile._();

  static final CustomerProfile instance = CustomerProfile._();

  String name = '';
  String email = '';
  String document = '';
  bool isCompany = false;
  String postalCode = '';
  String state = '';
  String city = '';
  String neighborhood = '';
  String street = '';
  String houseNumber = '';

  String get address {
    final details = [
      if (street.isNotEmpty) '$street${houseNumber.isNotEmpty ? ', $houseNumber' : ''}',
      if (neighborhood.isNotEmpty) neighborhood,
      if (city.isNotEmpty || state.isNotEmpty)
        [city, state].where((part) => part.isNotEmpty).join(' - '),
      if (postalCode.isNotEmpty) 'CEP $postalCode',
    ];
    return details.join('\n');
  }
}
