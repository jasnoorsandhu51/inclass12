## Inventory App Architecture

### Data Flow
```
Firestore Database
       ↓
InventoryService (typed streams)
       ↓
StreamBuilder widgets
       ↓
UI (real-time updates)
```

### Project Structure

```
lib/
├── models/
│   └── item.dart                 # Item model with strong typing
├── services/
│   └── inventory_service.dart    # Firestore operations & typed streams
├── widgets/
│   ├── item_list.dart           # Real-time item list display
│   └── add_item_form.dart       # Form for adding/editing items
├── main.dart                     # App entry point & home page
└── firebase_options.dart         # Firebase configuration
```

### Key Components

#### 1. **Item Model** (`models/item.dart`)
- **Strong Typing**: All properties have explicit types
- **Serialization**: `toJson()` for Firestore write operations
- **Deserialization**: `fromFirestore()` factory constructor
- **Immutability**: `copyWith()` for creating modified copies
- **Equality**: Proper `==` and `hashCode` implementation

```dart
Item(
  id: '123',
  name: 'Widget',
  quantity: 50,
  price: 9.99,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
)
```

#### 2. **InventoryService** (`services/inventory_service.dart`)
**All methods return strongly typed data:**

**Streams (real-time):**
- `Stream<List<Item>> getItemsStream()` - All items ordered by update time
- `Stream<Item?> getItemStream(String id)` - Single item by ID
- `Stream<List<Item>> getLowStockStream()` - Items below threshold

**CRUD Operations:**
- `Future<Item> createItem()` - Add new item, returns created item
- `Future<void> updateItem(Item)` - Update all fields
- `Future<void> updateItemFields()` - Update specific fields
- `Future<void> deleteItem()` - Remove item
- `Future<void> deleteItems()` - Batch delete

**Quantity Operations:**
- `Future<void> incrementQuantity()` - Add stock
- `Future<void> decrementQuantity()` - Remove stock

**Additional:**
- `Future<double> getTotalInventoryValue()` - Calculate total value
- `Future<List<Item>> searchItems()` - Search by name
- `Future<void> clearAllItems()` - Clear all data

#### 3. **UI Widgets**

**ItemListWidget** (`widgets/item_list.dart`)
- Displays real-time item list using `StreamBuilder`
- Shows loading/error states
- Tap to view details
- Right-click menu for increment/decrement/edit/delete

**AddItemForm** (`widgets/add_item_form.dart`)
- Modal form for adding items
- Form validation
- Error handling with SnackBars
- Loading state during submission

**InventoryHomePage** (`main.dart`)
- Bottom navigation (All Items / Low Stock)
- Floating action button to add items
- Inventory statistics modal

### Real-Time Updates

The app uses Firestore's native real-time capabilities:

```dart
// Changes in Firestore instantly update the UI
Stream<List<Item>> getItemsStream() {
  return _firestore
      .collection('items')
      .orderBy('updatedAt', descending: true)
      .snapshots()  // Real-time listener
      .map((snapshot) => snapshot.docs
          .map((doc) => Item.fromFirestore(doc))
          .toList());
}

// StreamBuilder automatically rebuilds when stream emits
StreamBuilder<List<Item>>(
  stream: service.getItemsStream(),
  builder: (context, snapshot) {
    // UI rebuilds with latest data
  }
)
```

### Firestore Database Structure

Collection: `items`
```json
{
  "items": {
    "doc-id": {
      "name": "Widget",
      "description": "Blue widget",
      "quantity": 50,
      "price": 9.99,
      "createdAt": Timestamp,
      "updatedAt": Timestamp
    }
  }
}
```

### Development Setup

1. **Configure Firebase**:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

2. **Enable Firestore Test Mode**:
   - Go to Firebase Console
   - Cloud Firestore → Create Database
   - Select "Start in test mode" for development

3. **Test Mode Security Rules**:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.time < timestamp.date(2026, 5, 6);
       }
     }
   }
   ```

4. **Run** the app:
   ```bash
   flutter pub get
   flutter run
   ```

### Testing Data Flow

1. Add an item using the form
2. See it instantly appear in the list (Firestore listener)
3. Tap to edit and see updates in real-time
4. Check "Low Stock" tab for items with quantity < 10
5. Delete an item and see list update immediately

### Error Handling

- Form validation in `AddItemForm`
- Try-catch blocks in async operations
- SnackBar notifications for user feedback
- StreamBuilder error states display to user

### Scalability Notes

- Indexed by `updatedAt` for efficient queries
- Batch operations for multiple deletes
- Field-level updates to avoid rewriting entire documents
- Atomic increment/decrement operations
- Local offline persistence enabled

