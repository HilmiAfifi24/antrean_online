# Display User Name Feature

## Overview
Fitur untuk menampilkan nama user yang didaftarkan saat registrasi di Patient Home Page, menggantikan text "Pasien" default.

## Changes Made

### 1. **Data Layer - Auth Remote Data Source**
**File:** `lib/features/auth/data/datasources/auth_remote_data_source.dart`

**Changes:**
- Tambah parameter `name` di method `register()`
- Simpan field `name` ke Firestore collection `users`
- Tambah timestamp `created_at`

```dart
Future<UserModel> register(String email, String password, String role, String name) async {
  // ...
  await firestore.collection("users").doc(uid).set({
    ...userModel.toMap(),
    'name': name,
    'created_at': FieldValue.serverTimestamp(),
  });
}
```

### 2. **Repository Layer**
**Files:**
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`

**Changes:**
- Update signature method `register()` untuk menerima parameter `name`

```dart
Future<UserEntity> register(String email, String password, String role, String name);
```

### 3. **Use Case Layer**
**File:** `lib/features/auth/domain/usecases/register_user.dart`

**Changes:**
- Update method `call()` untuk menerima parameter `name`

```dart
Future<UserEntity> call(String email, String password, String role, String name) {
  return repository.register(email, password, role, name);
}
```

### 4. **Presentation Layer - Controller**
**File:** `lib/features/auth/presentation/controllers/auth_controller.dart`

**Changes:**
- Update method `register()` untuk menerima parameter `name`
- Tambah success snackbar setelah registrasi berhasil
- Import `flutter/material.dart` untuk Colors

```dart
Future<void> register(String email, String password, String role, String name) async {
  // ...
  Get.snackbar(
    "Sukses",
    "Registrasi berhasil! Silakan login dengan akun Anda",
    backgroundColor: Colors.green.shade100,
    colorText: Colors.green.shade900,
  );
}
```

### 5. **Presentation Layer - UI**
**File:** `lib/features/auth/presentation/pages/register_page.dart`

**Changes:**
- Pass `nameController.text.trim()` ke method `register()`

```dart
controller.register(
  emailController.text.trim(),
  passwordController.text.trim(),
  role.value,
  nameController.text.trim(), // ← NEW
);
```

### 6. **Patient Feature - Display**
**File:** `lib/features/patient/presentation/controllers/patient_controller.dart`

**Already Implemented:**
- Method `loadPatientName()` sudah membaca field `name` dari Firestore
- Jika tidak ada nama, fallback ke "Pasien"

```dart
if (userDoc.exists) {
  final data = userDoc.data();
  _patientName.value = data?['name'] ?? 'Pasien';
}
```

**File:** `lib/features/patient/presentation/pages/patient_home_page.dart`

**Already Implemented:**
- Menggunakan `controller.patientName` untuk menampilkan nama

```dart
GetX<PatientController>(
  builder: (controller) => Text(
    controller.patientName, // ← Display user name
    style: TextStyle(...),
  ),
)
```

## Data Structure

### Firestore Collection: `users`
```json
{
  "uid": "string",
  "email": "string",
  "role": "string",
  "name": "string",           // ← NEW FIELD
  "created_at": "timestamp"    // ← NEW FIELD
}
```

## User Flow

1. **Registration:**
   - User mengisi form registrasi dengan:
     - Nama Lengkap ✓
     - Email
     - Password
     - Role
   - Data disimpan ke Firestore dengan field `name`

2. **Login & Display:**
   - User login dengan email & password
   - Redirect ke Patient Home Page
   - Controller `loadPatientName()` dipanggil
   - Nama user dibaca dari Firestore
   - Tampilkan nama di header: "Selamat Pagi, **[Nama User]**"

3. **Fallback:**
   - Jika field `name` tidak ada → tampilkan "Pasien"
   - Jika error saat load → tampilkan "Pasien"

## Testing Checklist

- [ ] Register user baru dengan nama
- [ ] Cek Firestore apakah field `name` tersimpan
- [ ] Login dengan user yang baru didaftar
- [ ] Verify nama tampil di Patient Home Page
- [ ] Test dengan user lama (tanpa field name) → harus fallback ke "Pasien"
- [ ] Test error handling (network error, dll)

## Benefits

✅ **Personalisasi** - User merasa lebih welcome dengan nama mereka
✅ **User Experience** - Lebih friendly dan professional
✅ **Backward Compatible** - User lama tetap bisa login (fallback ke "Pasien")

## Future Improvements

- [ ] Tambah field profile photo
- [ ] Edit profile feature
- [ ] Display name di header semua halaman
- [ ] Validasi nama (min 3 karakter, tidak boleh angka saja)
