import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class InventoryService {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'items';

  InventoryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get a typed stream of all items
  Stream<List<Item>> getItemsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
        });
  }

  /// Get a typed stream of a single item by ID
  Stream<Item?> getItemStream(String itemId) {
    return _firestore.collection(_collectionName).doc(itemId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return null;
      }
      return Item.fromFirestore(
        snapshot as DocumentSnapshot<Map<String, dynamic>>,
      );
    });
  }

  /// Get a typed stream of items by quantity threshold
  Stream<List<Item>> getLowStockStream({int threshold = 10}) {
    return _firestore
        .collection(_collectionName)
        .where('quantity', isLessThan: threshold)
        .orderBy('quantity')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
        });
  }

  /// Create a new item - returns the created item with generated ID
  Future<Item> createItem({
    required String name,
    required String description,
    required int quantity,
    required double price,
  }) async {
    final now = DateTime.now();
    final newItem = Item(
      id: '', // Temporary, will be set by Firestore
      name: name,
      description: description,
      quantity: quantity,
      price: price,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _firestore
        .collection(_collectionName)
        .add(newItem.toJson());

    return newItem.copyWith(id: docRef.id);
  }

  /// Update an existing item
  Future<void> updateItem(Item item) async {
    await _firestore.collection(_collectionName).doc(item.id).update({
      ...item.toJson(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Update specific fields of an item
  Future<void> updateItemFields(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore.collection(_collectionName).doc(itemId).update({
      ...updates,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Increment the quantity of an item
  Future<void> incrementQuantity(String itemId, int amount) async {
    await _firestore.collection(_collectionName).doc(itemId).update({
      'quantity': FieldValue.increment(amount),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Decrement the quantity of an item
  Future<void> decrementQuantity(String itemId, int amount) async {
    await _firestore.collection(_collectionName).doc(itemId).update({
      'quantity': FieldValue.increment(-amount),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection(_collectionName).doc(itemId).delete();
  }

  /// Delete multiple items
  Future<void> deleteItems(List<String> itemIds) async {
    final batch = _firestore.batch();
    for (final id in itemIds) {
      batch.delete(_firestore.collection(_collectionName).doc(id));
    }
    await batch.commit();
  }

  /// Get total inventory value (all items * price)
  Future<double> getTotalInventoryValue() async {
    final snapshot = await _firestore.collection(_collectionName).get();
    double total = 0;
    for (final doc in snapshot.docs) {
      final item = Item.fromFirestore(doc);
      total += item.quantity * item.price;
    }
    return total;
  }

  /// Search items by name
  Future<List<Item>> searchItems(String query) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();

    return snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
  }

  /// Clear all items (use with caution!)
  Future<void> clearAllItems() async {
    final snapshot = await _firestore.collection(_collectionName).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
