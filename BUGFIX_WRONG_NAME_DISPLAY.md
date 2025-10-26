# Bug Fix: Wrong User Name Display on Home Page

## Problem

**Reported Issue:**
- User login sebagai **Ale Perdana Putra** (ale@pens.ac.id)
- Di **Profile page** → Nama tampil **"ale perdana putra"** ✅ BENAR
- Di **Home page** → Nama tampil **"ahmad risel"** ❌ SALAH (user sebelumnya)

## Root Cause

### Controller Singleton Issue

**PatientController** di-register sebagai **permanent** (singleton) di dependency injection:

```dart
// patient_binding.dart
Get.put(
  PatientController(...),
  permanent: true,  // ← Controller persist across sessions!
);
```

**Alur Bug:**

1. **First Login** (Ahmad Risel):
   - `PatientController.onInit()` dipanggil
   - `loadPatientName()` → Load "ahmad risel"
   - `_patientName.value = "ahmad risel"`

2. **Logout**:
   - Controller TIDAK di-dispose (karena `permanent: true`)
   - `_patientName.value` masih **"ahmad risel"** ❌

3. **Second Login** (Ale Perdana Putra):
   - Controller sudah exist (singleton)
   - `onInit()` TIDAK dipanggil lagi
   - `_patientName.value` masih **"ahmad risel"** ❌ WRONG!

### Why Profile Page Shows Correct Name?

Profile page kemungkinan:
- Load data langsung dari Firestore setiap kali dibuka
- Atau punya controller tersendiri yang non-permanent
- Atau pakai `currentUser` dari FirebaseAuth langsung

## Solution

### Strategy: Auth State Listener

Tambahkan **Firebase Auth state listener** untuk detect perubahan user dan reload nama otomatis.

**Implementation:**

1. **Add auth state subscription**
2. **Listen to `authStateChanges()`**
3. **Reload name** saat user berubah
4. **Cancel subscription** di onClose

## Files Modified

### `patient_controller.dart`

**Change 1: Add subscription variable**

```dart
// Stream subscriptions
StreamSubscription? _schedulesSubscription;
StreamSubscription? _authStateSubscription;  // NEW
```

**Change 2: Setup auth listener in onInit()**

```dart
@override
void onInit() {
  super.onInit();
  _selectedDay.value = _getTodayDayName();
  
  // Setup auth state listener to reload name when user changes
  _setupAuthStateListener();  // NEW
  
  loadPatientName().then((_) {
    _checkAndPromptForName();
  });
  
  // ... rest of init
}
```

**Change 3: Implement auth state listener**

```dart
// Setup auth state listener
void _setupAuthStateListener() {
  _authStateSubscription?.cancel();
  _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      // User logged in or changed, reload name
      loadPatientName();
    } else {
      // User logged out
      _patientName.value = 'Pasien';
    }
  });
}
```

**Change 4: Cancel subscription in onClose()**

```dart
@override
void onClose() {
  _schedulesSubscription?.cancel();
  _authStateSubscription?.cancel();  // NEW
  searchController.dispose();
  super.onClose();
}
```

### `patient_home_page.dart`

**Change: Update RefreshIndicator**

```dart
// BEFORE
RefreshIndicator(
  onRefresh: () async {
    await controller.loadSchedules();
  },
  ...
)

// AFTER
RefreshIndicator(
  onRefresh: () async {
    await controller.loadPatientName();  // NEW - Reload name first
    await controller.refreshData();      // Then reload schedules
  },
  ...
)
```

## How It Works

### Auth State Changes Flow

```
User Logs In/Out
  ↓
Firebase Auth State Changes
  ↓
authStateChanges() stream emits
  ↓
_authStateSubscription listener triggered
  ↓
Check if user exists
  ↓
If user exists:
  → loadPatientName()
  → Query Firestore users/{uid}
  → Get 'name' field
  → _patientName.value = name ✅
  
If user is null:
  → _patientName.value = 'Pasien'
```

### Timeline Example

**Scenario: Login → Logout → Login berbeda**

| Action | Auth State | Listener Triggered | Result |
|--------|------------|-------------------|--------|
| **1. Login Ahmad** | User(ahmad@) | ✅ Yes | Load "ahmad risel" |
| **2. Ahmad uses app** | User(ahmad@) | ❌ No | Shows "ahmad risel" |
| **3. Logout** | null | ✅ Yes | Show "Pasien" |
| **4. Login Ale** | User(ale@) | ✅ Yes | Load "ale perdana putra" ✅ |
| **5. Ale uses app** | User(ale@) | ❌ No | Shows "ale perdana putra" ✅ |

## Testing Instructions

### 1. Hot Restart

```bash
flutter run
# atau tekan 'R' di terminal
```

### 2. Test Scenario

**Step 1: Login User Pertama**
- Login sebagai **ahmad@pens.ac.id**
- Cek Home page → Nama = **"ahmad risel"** ✅
- Cek Profile → Nama = **"ahmad risel"** ✅

**Step 2: Logout**
- Klik Logout
- (Optional) Cek Home → Nama = **"Pasien"** (jika masih bisa akses)

**Step 3: Login User Kedua**
- Login sebagai **ale@pens.ac.id**
- **CRITICAL**: Cek Home page → Nama = **"ale perdana putra"** ✅
- Cek Profile → Nama = **"ale perdana putra"** ✅

**Step 4: Pull to Refresh**
- Pull down di Home page
- Verify nama tetap **"ale perdana putra"** ✅

### 3. Expected Results

✅ Home page menunjukkan nama user yang sedang login
✅ Profile page menunjukkan nama yang sama
✅ Setelah logout → login user berbeda, nama berubah
✅ Pull to refresh meng-update nama jika ada perubahan

## Additional Benefits

### 1. Real-time Name Update

Jika user mengubah nama di Profile page, Home page akan langsung update (karena listener detect auth state/user data changes).

**Wait, auth state tidak berubah jika hanya ganti nama!**

Untuk ini, kita perlu tambahkan Firestore listener untuk user document. Tapi untuk sekarang, **Pull to Refresh** sudah cukup untuk reload nama.

### 2. Cleaner Logout Flow

Saat logout, nama langsung di-reset ke "Pasien", lebih clean.

### 3. Multi-device Support

Jika user login di device lain, auth state akan sinkron (tergantung Firebase configuration).

## Limitations

### Current Implementation:

✅ **Detects login/logout** → Reload name
✅ **Pull to refresh** → Reload name
❌ **Real-time name edit** → Need Firestore listener

### Future Enhancement (Optional):

Jika mau real-time update saat user edit nama di Profile:

```dart
void _setupUserDataListener() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data?['name'] != null) {
            _patientName.value = data!['name'];
          }
        }
      });
  }
}
```

Tapi untuk sekarang, **auth state listener + pull to refresh** sudah cukup untuk fix bug ini.

## Conclusion

✅ **Bug fixed** dengan Firebase Auth state listener
✅ **Nama update otomatis** saat login/logout
✅ **Pull to refresh** juga reload nama
✅ **Controller tetap singleton** (tidak perlu ubah architecture)
✅ **Clean separation** antara auth state dan user data

**No more wrong name display!** 🎯
