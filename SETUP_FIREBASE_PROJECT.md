# Setup Firebase untuk Proyek Anda

## Proyek Firebase: `manage-your-stock-f684a`

### ⚠️ PENTING: Gunakan Firestore, Bukan Realtime Database

Aplikasi ini menggunakan **Cloud Firestore**, bukan Realtime Database. Silakan ikuti langkah-langkah berikut:

## Langkah 1: Setup Firestore Database

1. Buka [Firebase Console](https://console.firebase.google.com/u/0/project/manage-your-stock-f684a)
2. Di sidebar kiri, klik **"Firestore Database"** (bukan Realtime Database)
3. Jika belum ada database:
   - Klik **"Create database"**
   - Pilih **"Start in test mode"** (untuk development)
   - Pilih lokasi terdekat (contoh: `asia-southeast2` untuk Indonesia)
   - Klik **"Enable"**

## Langkah 2: Tambahkan Android App ke Firebase

1. Di Firebase Console, klik ikon **Android** (atau "Add app" → Android)
2. Masukkan package name: `com.example.manage_your_logistic`
   - Atau cek di `android/app/build.gradle` pada baris `applicationId`
3. App nickname (opsional): "Warehouse Management"
4. Download **`google-services.json`**
5. Letakkan file tersebut di: `android/app/google-services.json`

## Langkah 3: Update Gradle Files

### Update `android/build.gradle`:

Tambahkan di bagian `dependencies`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### Update `android/app/build.gradle`:

Tambahkan di **bagian paling bawah** file:

```gradle
apply plugin: 'com.google.gms.google-services'
```

## Langkah 4: Enable Authentication

1. Di Firebase Console, klik **"Authentication"**
2. Klik **"Get started"** (jika pertama kali)
3. Pilih tab **"Sign-in method"**
4. Klik **"Email/Password"**
5. Enable dan klik **"Save"**

## Langkah 5: Setup Firestore Security Rules

1. Di Firebase Console → **Firestore Database** → tab **"Rules"**
2. Ganti rules dengan ini:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users - bisa baca/tulis data sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Items - user terautentikasi bisa baca/tulis
    match /items/{itemId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Stock levels - user terautentikasi bisa baca/tulis
    match /stock_levels/{docId} {
      allow read, write: if request.auth != null;
    }
    
    // Stock moves - user terautentikasi bisa baca/tulis
    match /stock_moves/{moveId} {
      allow read, write: if request.auth != null;
    }
    
    // Inventory counts - user terautentikasi bisa baca/tulis
    match /inventory_counts/{sessionId} {
      allow read, write: if request.auth != null;
    }
    
    // Inventory count lines - user terautentikasi bisa baca/tulis
    match /inventory_count_lines/{lineId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Klik **"Publish"**

## Langkah 6: Buat User Pertama

1. Di Firebase Console → **Authentication** → tab **"Users"**
2. Klik **"Add user"**
3. Masukkan email dan password
4. Klik **"Add user"**
5. **Simpan email dan password** untuk login di app

## Langkah 7: Test Aplikasi

```bash
cd /home/iqbal/project/flutter/manage_your_logistic
flutter clean
flutter pub get
flutter run
```

## Verifikasi Setup

Setelah setup, pastikan:

✅ File `android/app/google-services.json` ada  
✅ Firestore Database sudah dibuat (bukan Realtime Database)  
✅ Authentication Email/Password sudah enabled  
✅ Firestore Rules sudah di-update  
✅ User pertama sudah dibuat  

## Troubleshooting

### Error: "Default FirebaseApp is not initialized"
- Pastikan `google-services.json` ada di `android/app/`
- Jalankan `flutter clean` lalu `flutter pub get`

### Error: "MissingPluginException"
```bash
flutter clean
rm -rf build/
flutter pub get
flutter run
```

### Firestore permission denied
- Cek Firestore Rules sudah benar
- Pastikan user sudah login
- Pastikan menggunakan Firestore, bukan Realtime Database

### App tidak bisa connect ke Firebase
- Cek package name di `android/app/build.gradle` sama dengan di Firebase Console
- Pastikan `google-services.json` sudah di-download ulang setelah menambahkan Android app

## Link Penting

- Firebase Console: https://console.firebase.google.com/u/0/project/manage-your-stock-f684a
- Firestore Database: https://console.firebase.google.com/u/0/project/manage-your-stock-f684a/firestore
- Authentication: https://console.firebase.google.com/u/0/project/manage-your-stock-f684a/authentication

## Catatan

- **JANGAN** gunakan Realtime Database, aplikasi ini menggunakan **Firestore**
- Untuk production, update Firestore Rules sesuai kebutuhan keamanan
- Test mode hanya untuk development, jangan gunakan di production tanpa rules yang proper


