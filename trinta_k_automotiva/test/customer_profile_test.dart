import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/customer_profile.dart';

void main() {
  final profile = CustomerProfile.instance;
  late Map<String, Object> original;

  setUp(() {
    original = {
      'name': profile.name,
      'email': profile.email,
      'document': profile.document,
      'isCompany': profile.isCompany,
      'postalCode': profile.postalCode,
      'state': profile.state,
      'city': profile.city,
      'neighborhood': profile.neighborhood,
      'street': profile.street,
      'houseNumber': profile.houseNumber,
    };
    profile
      ..name = ''
      ..email = ''
      ..document = ''
      ..isCompany = false
      ..postalCode = ''
      ..state = ''
      ..city = ''
      ..neighborhood = ''
      ..street = ''
      ..houseNumber = '';
  });

  tearDown(() {
    profile
      ..name = original['name'] as String
      ..email = original['email'] as String
      ..document = original['document'] as String
      ..isCompany = original['isCompany'] as bool
      ..postalCode = original['postalCode'] as String
      ..state = original['state'] as String
      ..city = original['city'] as String
      ..neighborhood = original['neighborhood'] as String
      ..street = original['street'] as String
      ..houseNumber = original['houseNumber'] as String;
  });

  test('QA-47 endereco vazio retorna texto vazio', () {
    expect(profile.address, isEmpty);
  });

  test('QA-48 monta endereco completo em linhas', () {
    profile
      ..street = 'Rua das Flores'
      ..houseNumber = '100'
      ..neighborhood = 'Centro'
      ..city = 'Curitiba'
      ..state = 'PR'
      ..postalCode = '80000-000';
    expect(profile.address, 'Rua das Flores, 100\nCentro\nCuritiba - PR\nCEP 80000-000');
  });

  test('QA-49 endereco sem numero nao insere virgula', () {
    profile.street = 'Avenida Central';
    expect(profile.address, 'Avenida Central');
  });

  test('QA-50 permite endereco somente com cidade', () {
    profile.city = 'Guarapuava';
    expect(profile.address, 'Guarapuava');
  });

  test('QA-51 permite endereco somente com estado', () {
    profile.state = 'PR';
    expect(profile.address, 'PR');
  });

  test('QA-52 inclui apenas CEP quando demais campos estao vazios', () {
    profile.postalCode = '85000-000';
    expect(profile.address, 'CEP 85000-000');
  });

  test('QA-53 atualiza dados pessoais', () {
    profile
      ..name = 'Cliente QA'
      ..email = 'cliente.qa@example.com'
      ..document = '52998224725';
    expect(profile.name, 'Cliente QA');
    expect(profile.email, 'cliente.qa@example.com');
    expect(profile.document, '52998224725');
  });

  test('QA-54 distingue pessoa fisica e juridica', () {
    expect(profile.isCompany, isFalse);
    profile.isCompany = true;
    expect(profile.isCompany, isTrue);
  });
}
