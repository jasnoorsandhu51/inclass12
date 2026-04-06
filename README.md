# Inventory Manager

A modern Flutter app for managing inventory with real-time Firestore sync. Built with Material 3 design and strong Dart typing.

## Features

✨ **Real-time Inventory Sync** - Items sync instantly across all devices using Firestore listeners

📦 **Complete CRUD Operations**
- Create new inventory items with form validation
- Edit existing items  
- Delete items with confirmation
- Increment/Decrement quantities

🏷️ **Smart Organization**
- View all items with "All Items" tab
- Filter low stock items (quantity < 10) with dedicated tab
- Sort items by most recently updated

🎨 **Modern UI**
- Material 3 design system with custom color scheme
- Card-based item display with gradient accents
- Real-time status badges (In Stock / Low Stock / Out of Stock)
- Native bottom navigation for tab switching

✅ **Form Validation**
- Item name: 2-100 characters
- Description: 3-500 characters  
- Quantity: 0-1,000,000
- Price: Valid currency format (< $999,999.99)
- Real-time error feedback

📊 **Inventory Statistics**
- Total items count
- Total inventory value
- Quick-access modal dialog

🔥 **Firebase Integration**
- Cloud Firestore for persistent data
- Proper Firebase configuration via FlutterFire CLI
- Offline persistence enabled

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Firebase project setup
- Google Chrome (for web testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/jasnoorsandhu51/inclass12.git
   cd inventory
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (local only, credentials not tracked)
   ```bash
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` locally.

4. **Run the app**
   ```bash
   flutter run -d chrome    # For web
   flutter run -d macos     # For macOS desktop
   flutter run             # To select device interactively
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point, theme, navigation
├── models/
│   └── item.dart            # Item data model with serialization
├── services/
│   └── inventory_service.dart # Firestore CRUD & streams
└── widgets/
    ├── item_list.dart       # Real-time item list with StreamBuilder
    └── add_item_form.dart   # Form with validation
```

## Architecture

**Stream-based State Management** - Uses Firestore listeners and StreamBuilder for reactive UI updates without external state management libraries.

**Strong Typing** - Full Dart type annotations on models, services, and streams (Stream<List<Item>>, Future<Item>, etc.).

**Service Layer Pattern** - `InventoryService` encapsulates all Firestore operations, making the UI layer clean and testable.

## Key Technologies

- **Flutter** - Cross-platform mobile/web framework
- **Firebase Core 3.15+** - Cloud services backend
- **Cloud Firestore 5.6+** - NoSQL database with real-time listeners
- **Material 3** - Modern design system

## Deployment

The app is configured to run on:
- ✅ **Web** (Android & Web apps registered in Firebase)
- 🔄 **macOS Desktop** (tested locally)
- ⬜ **iOS** (platform SDK available, not yet configured)

Firebase test mode is active (expires May 6, 2026). Before production, set up proper Firestore security rules.

## Future Enhancements

- Search / filter items by name
- Barcode scanning for quick quantity updates  
- Inventory alerts and notifications
- CSV export / import
- Multi-user collaboration with role-based access
- Production Firestore security rules
