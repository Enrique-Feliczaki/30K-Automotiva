import 'package:flutter/foundation.dart';

import 'cart_item.dart';
import 'cart_store.dart';
import 'customer_profile.dart';
import 'local_accounts.dart';
import 'local_database.dart';

import 'product_store.dart';

/// Connects existing screen stores to one serialized, transactional write queue.
class LocalPersistence extends ChangeNotifier {
  LocalPersistence(this.database);

  static LocalPersistence? active;
  final LocalDatabase database;
  final _products = ProductStore.instance;
  final _cart = CartStore.instance;
  final _profile = CustomerProfile.instance;
  final _accounts = LocalAccounts.instance;
  final Map<String, List<CartItem>> _carts = {};
  Future<void> _pending = Future.value();
  String? _customerEmail;
  bool _restoring = false;
  bool _connected = false;
  Object? lastError;

  Future<void> initialize() async {
    final snapshot = await database.load();
    if (snapshot == null) {
      await database.save(
        LocalSnapshot(products: _products.products, accounts: [], carts: {}),
      );
      _accounts.restore([]);
    } else {
      _products.restore(snapshot.products);
      _accounts.restore(snapshot.accounts);
      _carts.addAll(snapshot.carts);
    }
    _profile.restore({});
    _cart.restore([]);
    _products.addListener(_save);
    _cart.addListener(_saveCart);
    _accounts.addListener(_save);
    _profile.addListener(_saveProfile);
    _connected = true;
    active = this;
  }

  void switchCustomer(String? email) {
    _restoring = true;
    _customerEmail = email;
    _cart.restore(email == null ? [] : _carts[email] ?? []);
    _restoring = false;
    if (email != null) _carts[email] = _cart.items;
  }

  void _saveProfile() => _accounts.updateProfile(_profile.toRecord());

  void _saveCart() {
    if (_restoring) return;
    if (_customerEmail != null) _carts[_customerEmail!] = _cart.items;
    _save();
  }

  LocalSnapshot _snapshot() => LocalSnapshot(
    products: _products.products,
    accounts: _accounts.accounts,
    carts: {
      for (final entry in _carts.entries) entry.key: List.of(entry.value),
    },
  );

  void _save() {
    if (_restoring || !_connected) return;
    _pending = _pending.then((_) async {
      try {
        await database.save(_snapshot());
        lastError = null;
      } catch (error) {
        lastError = error;
      }
      notifyListeners();
    });
  }

  Future<void> flush() async {
    await _pending;
    if (lastError != null) {
      throw StateError('Não foi possível salvar os dados no aparelho.');
    }
  }

  Future<void> completePurchase(List<CartItem> items) {
    final purchase = _pending.then((_) async {
      final products = _products.stockAfterPurchase(items);
      final snapshot = _snapshot();
      final carts = {...snapshot.carts};
      final customerEmail = _customerEmail;
      if (customerEmail != null) carts[customerEmail] = [];
      // Commit stock and the customer's cleared cart in one SQL transaction.
      // Publish to the screens only after the database confirms the write.
      await database.save(
        LocalSnapshot(
          products: products,
          accounts: snapshot.accounts,
          carts: carts,
        ),
      );
      _restoring = true;
      try {
        _products.restore(products);
        _cart.restore([]);
        _carts
          ..clear()
          ..addAll(carts);
      } finally {
        _restoring = false;
      }
      lastError = null;
      notifyListeners();
    });
    // Keep the queue usable after a failed purchase; the caller handles errors.
    _pending = purchase.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return purchase;
  }

  Future<void> retry() async {
    _save();
    await flush();
  }

  Future<void> close() async {
    if (_connected) {
      _products.removeListener(_save);
      _cart.removeListener(_saveCart);
      _accounts.removeListener(_save);
      _profile.removeListener(_saveProfile);
      _connected = false;
    }
    await _pending;
    await database.close();
    if (identical(active, this)) active = null;
    dispose();
  }
}
