import 'package:flutter/foundation.dart';

class CustomerProfile extends ChangeNotifier {
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

  Map<String, dynamic> toRecord() => {
    'name': name,
    'email': email,
    'document': document,
    'isCompany': isCompany,
    'postalCode': postalCode,
    'state': state,
    'city': city,
    'neighborhood': neighborhood,
    'street': street,
    'houseNumber': houseNumber,
  };

  void restore(Map<String, dynamic> data) {
    name = data['name'] as String? ?? '';
    email = data['email'] as String? ?? '';
    document = data['document'] as String? ?? '';
    isCompany = data['isCompany'] as bool? ?? false;
    postalCode = data['postalCode'] as String? ?? '';
    state = data['state'] as String? ?? '';
    city = data['city'] as String? ?? '';
    neighborhood = data['neighborhood'] as String? ?? '';
    street = data['street'] as String? ?? '';
    houseNumber = data['houseNumber'] as String? ?? '';
  }

  void save() => notifyListeners();

  String get address {
    final details = [
      if (street.isNotEmpty)
        '$street${houseNumber.isNotEmpty ? ', $houseNumber' : ''}',
      if (neighborhood.isNotEmpty) neighborhood,
      if (city.isNotEmpty || state.isNotEmpty)
        [city, state].where((part) => part.isNotEmpty).join(' - '),
      if (postalCode.isNotEmpty) 'CEP $postalCode',
    ];
    return details.join('\n');
  }
}
