# Firebase Setup Guide

## Quick Setup Steps

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Warehouse Management" (or your choice)
4. Follow the setup wizard

### 2. Add Android App
1. In Firebase Console, click the Android icon
2. Package name: `com.example.manage_your_logistic` (or update in `android/app/build.gradle`)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### 3. Configure Gradle Files

#### Update `android/build.gradle`:
Add to the `dependencies` block:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

#### Update `android/app/build.gradle`:
Add at the bottom of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4. Enable Firebase Services

#### Authentication:
1. Go to Firebase Console → Authentication
2. Click "Get started"
3. Enable "Email/Password" provider
4. Click "Save"

#### Firestore Database:
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Start in **test mode** (for development)
4. Choose a location (closest to your users)
5. Click "Enable"

#### (Optional) Firebase Storage:
1. Go to Firebase Console → Storage
2. Click "Get started"
3. Start in test mode
4. Click "Next" → "Done"

### 5. Set Up Firestore Security Rules

Go to Firestore Database → Rules tab and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Items - authenticated users can read/write
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

### 6. Create First User

1. Go to Firebase Console → Authentication
2. Click "Add user"
3. Enter email and password
4. Note: You may want to add a registration screen to the app later

### 7. Test the App

```bash
flutter pub get
flutter run
```

## Troubleshooting

### Error: "Default FirebaseApp is not initialized"
- Make sure `google-services.json` is in `android/app/`
- Run `flutter clean` and `flutter pub get`
- Rebuild the app

### Error: "MissingPluginException"
- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`
- Rebuild

### Authentication not working
- Check that Email/Password provider is enabled
- Verify `google-services.json` is correct
- Check Firestore rules allow authenticated access

### Firestore permission denied
- Check security rules
- Verify user is authenticated
- Check Firestore is in test mode (for development)

## Next Steps

1. Create sample data in Firestore:
   - Add items to `items` collection
   - Add locations to `locations` collection
   - Add warehouses to `warehouses` collection

2. Test workflows:
   - Login with created user
   - Scan/create items
   - Process inbound/outbound
   - Run stock opname

3. Customize:
   - Update app name and package
   - Add more user roles
   - Implement item creation UI
   - Add location management


