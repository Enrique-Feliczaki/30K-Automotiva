import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'cart_item.dart';
import 'local_accounts.dart';
import 'local_records.dart';
import 'product_store.dart';

class LocalSnapshot {
  LocalSnapshot({
    required this.products,
    required this.accounts,
    required this.carts,
  });
  final List<StoreProduct> products;
  final List<LocalAccount> accounts;
  final Map<String, List<CartItem>> carts;
}

/// SQL is kept explicit here; versioned schema and transactions are managed by Drift.
class LocalDatabase extends GeneratedDatabase {
  LocalDatabase(super.executor);

  factory LocalDatabase.onDevice() => LocalDatabase(
    driftDatabase(
      name: 'trinta_k_automotiva',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (result) {
          if (result.chosenImplementation ==
              WasmStorageImplementation.inMemory) {
            throw StateError(
              'O navegador não permitiu armazenamento persistente.',
            );
          }
        },
      ),
    ),
  );

  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      await customStatement(
        'CREATE TABLE app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      );
      await customStatement(
        'CREATE TABLE products (id TEXT PRIMARY KEY, payload TEXT NOT NULL)',
      );
      await customStatement('''CREATE TABLE customers (
        email TEXT PRIMARY KEY, document TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL, password_salt TEXT NOT NULL,
        password_iterations INTEGER NOT NULL, profile TEXT NOT NULL
      )''');
      await customStatement('''CREATE TABLE cart_items (
        customer_email TEXT NOT NULL REFERENCES customers(email) ON DELETE CASCADE,
        product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
        quantity INTEGER NOT NULL CHECK (quantity > 0), payload TEXT NOT NULL,
        PRIMARY KEY (customer_email, product_id)
      )''');
    },
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );

  Future<LocalSnapshot?> load() async {
    final initialized = await customSelect(
      "SELECT value FROM app_meta WHERE key = 'initialized'",
    ).get();
    if (initialized.isEmpty) return null;
    final products = await customSelect(
      'SELECT payload FROM products ORDER BY rowid',
    ).get();
    final customers = await customSelect(
      'SELECT * FROM customers ORDER BY rowid',
    ).get();
    final rows = await customSelect(
      'SELECT customer_email, payload FROM cart_items ORDER BY rowid',
    ).get();
    final carts = <String, List<CartItem>>{};
    for (final row in rows) {
      (carts[row.read<String>('customer_email')] ??= []).add(
        cartFromRecord(
          jsonDecode(row.read<String>('payload')) as Map<String, dynamic>,
        ),
      );
    }
    return LocalSnapshot(
      products: products
          .map(
            (row) => productFromRecord(
              jsonDecode(row.read<String>('payload')) as Map<String, dynamic>,
            ),
          )
          .toList(),
      accounts: customers
          .map(
            (row) => LocalAccount(
              email: row.read<String>('email'),
              document: row.read<String>('document'),
              passwordHash: row.read<String>('password_hash'),
              salt: row.read<String>('password_salt'),
              iterations: row.read<int>('password_iterations'),
              profile: jsonDecode(
                row.read<String>('profile'),
              ) as Map<String, dynamic>,
            ),
          )
          .toList(),
      carts: carts,
    );
  }

  Future<void> save(LocalSnapshot snapshot) => transaction(() async {
    await customStatement('DELETE FROM cart_items');
    await customStatement('DELETE FROM customers');
    await customStatement('DELETE FROM products');
    for (final product in snapshot.products) {
      await customStatement(
        'INSERT INTO products (id, payload) VALUES (?, ?)',
        [product.id, jsonEncode(productRecord(product))],
      );
    }
    for (final account in snapshot.accounts) {
      await customStatement(
        '''INSERT INTO customers
        (email, document, password_hash, password_salt, password_iterations, profile)
        VALUES (?, ?, ?, ?, ?, ?)''',
        [
          account.email,
          account.document,
          account.passwordHash,
          account.salt,
          account.iterations,
          jsonEncode(account.profile),
        ],
      );
    }
    for (final entry in snapshot.carts.entries) {
      for (final item in entry.value) {
        // Legacy/demo items without a catalog identifier are never persisted.
        if (item.productId == null) continue;
        final products = snapshot.products.where((p) => p.id == item.productId);
        if (products.isEmpty || products.single.stock <= 0) continue;
        final quantity = item.quantity.clamp(1, products.single.stock);
        final bounded = item.copyWith(quantity: quantity);
        await customStatement(
          '''INSERT INTO cart_items
          (customer_email, product_id, quantity, payload) VALUES (?, ?, ?, ?)''',
          [
            entry.key,
            item.productId,
            quantity,
            jsonEncode(cartRecord(bounded)),
          ],
        );
      }
    }
    await customStatement(
      "INSERT OR REPLACE INTO app_meta (key, value) VALUES ('initialized', '1')",
    );
  });
}
