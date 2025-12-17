# Warehouse Management System

A complete Flutter mobile application for warehouse management with Firebase backend integration.

## Features

- 🔐 **Authentication**: Email/password login with role-based access
- 📦 **Item Management**: CRUD operations for items with barcode support
- 📊 **Stock Management**: Real-time stock level tracking
- 📥 **Inbound Operations**: Process incoming stock with automatic logging
- 📤 **Outbound Operations**: Process outgoing stock with validation
- 📋 **Stock Opname**: Physical inventory counting with variance tracking
- 📜 **Transaction History**: Complete ledger of all stock movements
- 📱 **Barcode Scanning**: Quick item lookup using barcode scanner
- 🔄 **Real-time Updates**: Firestore streams for live data synchronization

## Tech Stack

- **Flutter**: Cross-platform mobile framework
- **Firebase**: Backend services
  - Firebase Auth: User authentication
  - Cloud Firestore: Database
  - Firebase Storage: File storage (optional)
  - Firebase Messaging: Push notifications (optional)
- **Riverpod**: State management
- **Mobile Scanner**: Barcode scanning
- **Intl**: Date/time formatting

## Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── models/                   # Data models
│   ├── user_model.dart
│   ├── item_model.dart
│   ├── stock_level_model.dart
│   ├── stock_move_model.dart
│   ├── inventory_count_model.dart
│   └── inventory_count_line_model.dart
├── services/                 # Firebase services
│   ├── firestore_paths.dart
│   ├── auth_service.dart
│   ├── item_service.dart
│   └── stock_service.dart
├── providers/                # Riverpod providers
│   ├── auth_provider.dart
│   ├── item_provider.dart
│   └── stock_provider.dart
└── screens/                  # UI screens
    ├── login_screen.dart
    ├── dashboard_screen.dart
    ├── items_screen.dart
    ├── item_detail_screen.dart
    ├── scan_screen.dart
    ├── inbound_screen.dart
    ├── outbound_screen.dart
    ├── stock_opname_screen.dart
    ├── history_screen.dart
    └── settings_screen.dart
```

## Firestore Collections

### users
- `uid` (document ID)
- `name`: string
- `email`: string
- `role`: string

### items
- `id` (document ID)
- `sku`: string
- `name`: string
- `barcode`: string (optional)
- `reorderLevel`: number
- `uom`: string (unit of measure)
- `createdAt`: timestamp

### stock_levels
- Document ID: `{itemId}_{locationId}`
- `itemId`: string
- `locationId`: string
- `qty`: number

### stock_moves
- `id` (document ID)
- `itemId`: string
- `userId`: string
- `qty`: number
- `type`: string ("inbound" | "outbound")
- `timestamp`: timestamp
- `locationId`: string (optional)

### inventory_counts
- `sessionId` (document ID)
- `userId`: string
- `locationId`: string
- `date`: timestamp
- `status`: string ("draft" | "completed" | "cancelled")

### inventory_count_lines
- Document ID: `{sessionId}_{itemId}`
- `sessionId`: string
- `itemId`: string
- `countedQty`: number
- `systemQty`: number
- `variance`: number

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Configuration

#### Android Setup:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app to your Firebase project
3. Download `google-services.json`
4. Place it in `android/app/`
5. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS Setup (optional):
1. Add an iOS app to your Firebase project
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/`
4. Update `ios/Runner/Info.plist` with required permissions

### 3. Enable Firebase Services

In Firebase Console:
- Enable **Authentication** → Email/Password provider
- Enable **Cloud Firestore** → Create database (start in test mode)
- (Optional) Enable **Firebase Storage**
- (Optional) Enable **Cloud Messaging**

### 4. Firestore Security Rules

Update your Firestore rules (initially for development):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Items - authenticated users can read, admins can write
    match /items/{itemId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Stock levels - authenticated users can read/write
    match /stock_levels/{docId} {
      allow read, write: if request.auth != null;
    }
    
    // Stock moves - authenticated users can read/write
    match /stock_moves/{moveId} {
      allow read, write: if request.auth != null;
    }
    
    // Inventory counts - authenticated users can read/write
    match /inventory_counts/{sessionId} {
      allow read, write: if request.auth != null;
    }
    
    // Inventory count lines - authenticated users can read/write
    match /inventory_count_lines/{lineId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Run the App

```bash
flutter run
```

## Usage

### First Time Setup

1. **Create a User**: Use Firebase Console → Authentication → Add User, or implement registration in the app
2. **Create Items**: Add items through the Items screen (you may need to implement item creation UI)
3. **Set Locations**: Create location documents in Firestore `locations` collection
4. **Start Managing**: Use Inbound/Outbound screens to manage stock

### Core Workflows

#### Inbound Process:
1. Navigate to Inbound screen
2. Scan or enter item barcode/ID
3. Enter location ID
4. Enter quantity
5. Process inbound → Stock level updated + transaction logged

#### Outbound Process:
1. Navigate to Outbound screen
2. Scan or enter item barcode/ID
3. Enter location ID
4. Enter quantity
5. Process outbound → Stock validated, decremented + transaction logged

#### Stock Opname:
1. Navigate to Stock Opname screen
2. Enter location ID and create session
3. Scan items and enter counted quantities
4. System compares with actual stock levels
5. View variances and complete session

## Development Notes

- The app uses Riverpod for state management
- All data is streamed from Firestore for real-time updates
- Barcode scanning uses `mobile_scanner` package
- The app is optimized for Android but works on iOS too

## Future Enhancements

- [ ] Item creation/editing UI
- [ ] Location management screen
- [ ] Warehouse management
- [ ] Advanced search and filters
- [ ] Reports and analytics
- [ ] Export functionality
- [ ] Offline support
- [ ] Push notifications for low stock alerts

## License

This project is created for warehouse management purposes.
