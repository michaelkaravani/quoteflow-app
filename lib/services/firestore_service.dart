import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/catalog_item.dart';
import '../models/customer.dart';
import '../models/profile.dart';
import '../models/quote.dart';

class FirestoreService {
  FirestoreService({required this._uid});

  final String _uid;


  CollectionReference<Map<String, dynamic>> get _customers =>
      FirebaseFirestore.instance.collection('users').doc(_uid).collection('customers');

  CollectionReference<Map<String, dynamic>> get _catalog =>
      FirebaseFirestore.instance.collection('users').doc(_uid).collection('catalog');

  CollectionReference<Map<String, dynamic>> get _quotes =>
      FirebaseFirestore.instance.collection('users').doc(_uid).collection('quotes');

  DocumentReference<Map<String, dynamic>> get _profile =>
      FirebaseFirestore.instance.collection('users').doc(_uid);

  // ── Profile ──

  Future<Profile?> loadProfile() async {
    final doc = await _profile.get();
    if (!doc.exists) return null;
    return Profile.fromMap(doc.data()!);
  }

  Future<void> saveProfile(Profile profile) async {
    await _profile.set(profile.toMap(), SetOptions(merge: true));
  }

  // ── Customers ──

  Stream<List<Customer>> watchCustomers() {
    return _customers.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Customer.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addCustomer(Customer customer) async {
    await _customers.doc(customer.id).set(customer.toMap());
  }

  Future<void> updateCustomer(Customer customer) async {
    await _customers.doc(customer.id).update(customer.toMap());
  }

  Future<void> deleteCustomer(String id) async {
    await _customers.doc(id).delete();
  }

  // ── Catalog ──

  Stream<List<CatalogItem>> watchCatalog() {
    return _catalog.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CatalogItem.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addCatalogItem(CatalogItem item) async {
    await _catalog.doc(item.id).set(item.toMap());
  }

  Future<void> updateCatalogItem(CatalogItem item) async {
    await _catalog.doc(item.id).update(item.toMap());
  }

  Future<void> deleteCatalogItem(String id) async {
    await _catalog.doc(id).delete();
  }

  // ── Quotes ──

  Stream<List<Quote>> watchQuotes() {
    return _quotes.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Quote.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<int> generateQuoteNumber() async {
    final snapshot = await _quotes
        .orderBy('quoteNumber', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return 1001;
    final lastNumber = snapshot.docs.first.data()['quoteNumber'] as int? ?? 1000;
    return lastNumber + 1;
  }

  Future<void> addQuote(Quote quote) async {
    await _quotes.doc(quote.id).set(quote.toMap());
  }

  Future<void> updateQuote(Quote quote) async {
    await _quotes.doc(quote.id).update(quote.toMap());
  }

  Future<void> deleteQuote(String id) async {
    await _quotes.doc(id).delete();
  }

  // ── Helpers ──

  static String generateId() =>
      FirebaseFirestore.instance.collection('_').doc().id;
}
