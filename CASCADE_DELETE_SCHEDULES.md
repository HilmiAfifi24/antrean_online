# 🔄 Cascade Delete: Hapus Jadwal saat Dokter Dihapus

## 📋 Deskripsi Masalah

**Sebelum Fix:**
Ketika dokter (misalnya Dr. Alfian) dihapus dari sistem, jadwal-jadwal yang terkait dengan dokter tersebut **TIDAK IKUT TERHAPUS**. Ini menyebabkan:

❌ Jadwal "orphan" (tidak ada dokter tapi jadwalnya masih ada)
❌ Data tidak konsisten
❌ User bingung melihat jadwal tanpa dokter
❌ Error saat akses jadwal tersebut

**Contoh Kasus:**
```
1. Dr. Alfian memiliki 3 jadwal:
   - Senin 08:00-12:00
   - Rabu 13:00-17:00
   - Jumat 08:00-12:00

2. Admin hapus Dr. Alfian

3. Dr. Alfian terhapus ✅
   Jadwal-jadwalnya MASIH ADA ❌ (MASALAH!)
```

---

## ✅ **Solusi: Cascade Delete**

Implementasi **cascade delete** yang akan:
1. ✅ Hapus semua jadwal dokter saat dokter dihapus (permanent delete)
2. ✅ Nonaktifkan semua jadwal saat dokter dinonaktifkan (soft delete)
3. ✅ Tampilkan konfirmasi jumlah jadwal yang akan terhapus
4. ✅ Log activity dengan detail jumlah jadwal

---

## 🏗️ **Implementasi Teknis**

### 1️⃣ **Data Layer - Remote Datasource**

**File:** `lib/features/admin/doctor_view/data/datasources/doctor_admin_remote_datasource.dart`

#### **A. Soft Delete dengan Cascade**

```dart
// Soft delete doctor (set isActive to false)
Future<void> deleteDoctor(String id) async {
  final doctor = await getDoctorById(id);
  if (doctor == null) throw Exception('Doctor not found');

  // 1. Nonaktifkan dokter
  await firestore.collection('doctors').doc(id).update({
    'is_active': false,
    'updated_at': FieldValue.serverTimestamp(),
  });

  // 2. Nonaktifkan user account
  if (doctor.userId.isNotEmpty) {
    await firestore.collection('users').doc(doctor.userId).update({
      'is_active': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // 3. CASCADE: Nonaktifkan semua jadwal dokter ini
  final schedules = await firestore
      .collection('schedules')
      .where('doctor_id', isEqualTo: id)
      .get();

  for (var scheduleDoc in schedules.docs) {
    await scheduleDoc.reference.update({
      'is_active': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  await _logActivity(
    title: 'Dokter Dinonaktifkan',
    subtitle: 'Dr. ${doctor.namaLengkap} dan ${schedules.docs.length} jadwal telah dinonaktifkan',
    type: 'doctor_deactivated',
  );
}
```

**Penjelasan:**
- Step 1-2: Nonaktifkan dokter dan user account (seperti biasa)
- **Step 3 (CASCADE)**: 
  - Query semua jadwal dengan `doctor_id` sama dengan dokter yang dihapus
  - Loop dan set `is_active: false` untuk setiap jadwal
  - Jumlah jadwal yang dinonaktifkan dicatat di activity log

---

#### **B. Permanent Delete dengan Cascade**

```dart
// Permanently delete doctor
Future<void> permanentlyDeleteDoctor(String id) async {
  final doctor = await getDoctorById(id);
  if (doctor == null) throw Exception('Doctor not found');

  // 1. CASCADE: Hapus semua jadwal dokter ini terlebih dahulu
  final schedules = await firestore
      .collection('schedules')
      .where('doctor_id', isEqualTo: id)
      .get();

  int deletedSchedulesCount = 0;
  for (var scheduleDoc in schedules.docs) {
    await scheduleDoc.reference.delete();
    deletedSchedulesCount++;
  }

  // 2. Hapus dokter dari collection doctors
  await firestore.collection('doctors').doc(id).delete();

  // 3. Hapus user account
  if (doctor.userId.isNotEmpty) {
    await firestore.collection('users').doc(doctor.userId).delete();
  }

  await _logActivity(
    title: 'Dokter Dihapus Permanen',
    subtitle: 'Dr. ${doctor.namaLengkap} dan $deletedSchedulesCount jadwal telah dihapus permanen dari sistem',
    type: 'doctor_permanently_deleted',
  );
}
```

**Penjelasan:**
- **Step 1 (CASCADE)**: 
  - Query semua jadwal dengan `doctor_id` sama dengan dokter
  - Loop dan **DELETE** setiap jadwal (permanent delete)
  - Hitung jumlah jadwal yang dihapus
- Step 2: Hapus dokter
- Step 3: Hapus user account
- Log mencatat jumlah jadwal yang ikut terhapus

**⚠️ PENTING: Order Matters!**
Jadwal harus dihapus SEBELUM dokter, karena query menggunakan `doctor_id`.

---

### 2️⃣ **Presentation Layer - Controller dengan Konfirmasi**

**File:** `lib/features/admin/doctor_view/presentation/controllers/doctor_admin_controller.dart`

#### **Import Firebase**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
```

#### **Method removeDoctor() dengan Preview Cascade**

```dart
Future<void> removeDoctor(String id, String name) async {
  // CEK: Berapa banyak jadwal yang akan terhapus
  int schedulesCount = 0;
  try {
    final schedules = await Get.find<FirebaseFirestore>()
        .collection('schedules')
        .where('doctor_id', isEqualTo: id)
        .get();
    schedulesCount = schedules.docs.length;
  } catch (e) {
    // Jika gagal cek jadwal, tetap lanjut
  }

  // KONFIRMASI dengan info cascade delete
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Konfirmasi Hapus Dokter'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apakah Anda yakin ingin menghapus dokter $name?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEF4444)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 20),
                    SizedBox(width: 8),
                    Text('PERINGATAN', ...),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('• Data dokter akan dihapus PERMANEN'),
                if (schedulesCount > 0)
                  Text('• $schedulesCount jadwal akan IKUT TERHAPUS'),
                const Text('• Tindakan TIDAK DAPAT dibatalkan'),
              ],
            ),
          ),
        ],
      ),
      actions: [...],
    ),
  );

  if (confirmed != true) return;

  // EKSEKUSI DELETE
  try {
    _isLoading.value = true;
    
    final doctorRepo = Get.find<DoctorAdminRepository>();
    await doctorRepo.permanentlyDeleteDoctor(id);
    await loadDoctors();
    
    _showSuccess(schedulesCount > 0 
      ? 'Dokter dan $schedulesCount jadwal berhasil dihapus'
      : 'Dokter berhasil dihapus secara permanen');
  } catch (e) {
    _showError('Gagal menghapus dokter: ${e.toString()}');
  } finally {
    _isLoading.value = false;
  }
}
```

**Fitur Baru:**
1. ✅ **Preview**: Cek dulu berapa jadwal yang akan terhapus
2. ✅ **Warning Box**: Tampilkan peringatan dengan highlight merah
3. ✅ **Clear Info**: User tahu persis apa yang akan terjadi
4. ✅ **Success Message**: Konfirmasi berapa jadwal yang ikut terhapus

---

## 🎯 **Flow Cascade Delete**

### **Skenario: Hapus Dr. Alfian dengan 3 Jadwal**

```
┌─────────────────────────────────────────────────┐
│ 1. Admin klik "Hapus" pada Dr. Alfian         │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│ 2. System CEK jadwal di Firestore              │
│    Query: schedules where doctor_id == alfianId │
│    Result: 3 jadwal ditemukan                   │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│ 3. TAMPILKAN DIALOG KONFIRMASI                  │
│                                                  │
│    ⚠️ PERINGATAN                                │
│    • Data dokter akan dihapus PERMANEN          │
│    • 3 jadwal akan IKUT TERHAPUS               │
│    • Tindakan TIDAK DAPAT dibatalkan            │
│                                                  │
│    [Batal]  [Ya, Hapus Permanen]               │
└─────────────────────────────────────────────────┘
                      ↓
          User klik "Ya, Hapus Permanen"
                      ↓
┌─────────────────────────────────────────────────┐
│ 4. EKSEKUSI CASCADE DELETE                      │
│                                                  │
│    Step 1: Query jadwal-jadwal Dr. Alfian      │
│    Step 2: Loop & DELETE setiap jadwal         │
│            - Jadwal 1 (Senin) ✅ DELETED       │
│            - Jadwal 2 (Rabu) ✅ DELETED        │
│            - Jadwal 3 (Jumat) ✅ DELETED       │
│    Step 3: DELETE dokter Dr. Alfian            │
│    Step 4: DELETE user account Dr. Alfian      │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│ 5. LOG ACTIVITY                                 │
│    Title: "Dokter Dihapus Permanen"            │
│    Subtitle: "Dr. Alfian dan 3 jadwal telah    │
│               dihapus permanen dari sistem"     │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│ 6. TAMPILKAN SUCCESS MESSAGE                    │
│    "Dokter dan 3 jadwal berhasil dihapus"     │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│ 7. REFRESH LIST DOKTER                          │
│    Dr. Alfian tidak muncul lagi ✅             │
└─────────────────────────────────────────────────┘
```

---

## 🎨 **UI/UX Improvement**

### **Dialog Konfirmasi SEBELUM Fix:**
```
┌──────────────────────────────────┐
│ Konfirmasi Hapus                 │
├──────────────────────────────────┤
│ Apakah Anda yakin ingin menghapus│
│ dokter Dr. Alfian?               │
│                                   │
│ PERHATIAN: Tindakan ini akan      │
│ menghapus data secara permanen    │
│ dan tidak dapat dibatalkan.       │
│                                   │
│      [Batal]  [Hapus Permanen]   │
└──────────────────────────────────┘
```

### **Dialog Konfirmasi SETELAH Fix:**
```
┌──────────────────────────────────┐
│ Konfirmasi Hapus Dokter          │
├──────────────────────────────────┤
│ Apakah Anda yakin ingin menghapus│
│ dokter Dr. Alfian?               │
│                                   │
│ ┌────────────────────────────┐  │
│ │ ⚠️ PERINGATAN              │  │
│ │                             │  │
│ │ • Data dokter akan dihapus  │  │
│ │   PERMANEN                  │  │
│ │ • 3 jadwal akan IKUT        │  │
│ │   TERHAPUS                  │  │  ← INFORMASI BARU!
│ │ • Tindakan TIDAK DAPAT      │  │
│ │   dibatalkan                │  │
│ └────────────────────────────┘  │
│                                   │
│ [Batal]  [Ya, Hapus Permanen]    │
└──────────────────────────────────┘
```

**Keuntungan:**
- ✅ User tahu persis impact dari delete
- ✅ Tidak ada surprise setelah delete
- ✅ Warna merah untuk warning yang jelas
- ✅ Informasi terstruktur dengan bullet points

---

## 📊 **Database Operations**

### **Query yang Dijalankan:**

#### **1. Check Schedules Count (Preview)**
```dart
GET /schedules
WHERE doctor_id == 'doc_alfian_123'
// Returns: 3 documents
```

#### **2. Cascade Delete Schedules**
```dart
GET /schedules
WHERE doctor_id == 'doc_alfian_123'
// Returns: [schedule1, schedule2, schedule3]

DELETE /schedules/schedule1_id
DELETE /schedules/schedule2_id
DELETE /schedules/schedule3_id
```

#### **3. Delete Doctor**
```dart
DELETE /doctors/doc_alfian_123
```

#### **4. Delete User Account**
```dart
DELETE /users/user_alfian_123
```

#### **5. Log Activity**
```dart
CREATE /activities
{
  title: "Dokter Dihapus Permanen",
  subtitle: "Dr. Alfian dan 3 jadwal telah dihapus permanen dari sistem",
  type: "doctor_permanently_deleted",
  timestamp: serverTimestamp()
}
```

**Total Operations:** 5 + N (dimana N = jumlah jadwal)

---

## 🧪 **Test Cases**

### ✅ **Test Case 1: Hapus Dokter dengan Jadwal**

**Setup:**
```
Dr. Alfian:
  - ID: doc_123
  - Jadwal: 3 items (jadwal_1, jadwal_2, jadwal_3)
```

**Action:**
```
Admin → Kelola Dokter → Hapus Dr. Alfian → Konfirmasi
```

**Expected:**
```
1. Dialog muncul dengan info "3 jadwal akan IKUT TERHAPUS" ✅
2. Setelah konfirmasi:
   - Dr. Alfian terhapus ✅
   - jadwal_1 terhapus ✅
   - jadwal_2 terhapus ✅
   - jadwal_3 terhapus ✅
3. Success message: "Dokter dan 3 jadwal berhasil dihapus" ✅
4. Activity log mencatat "Dr. Alfian dan 3 jadwal" ✅
```

---

### ✅ **Test Case 2: Hapus Dokter tanpa Jadwal**

**Setup:**
```
Dr. Budi:
  - ID: doc_456
  - Jadwal: 0 items (belum ada jadwal)
```

**Action:**
```
Admin → Kelola Dokter → Hapus Dr. Budi → Konfirmasi
```

**Expected:**
```
1. Dialog muncul TANPA info jadwal (karena 0 jadwal) ✅
2. Setelah konfirmasi:
   - Dr. Budi terhapus ✅
3. Success message: "Dokter berhasil dihapus secara permanen" ✅
4. Activity log mencatat "Dr. Budi dan 0 jadwal" ✅
```

---

### ✅ **Test Case 3: Soft Delete (Nonaktifkan)**

**Setup:**
```
Dr. Citra:
  - ID: doc_789
  - Jadwal: 2 items (jadwal_4, jadwal_5)
  - is_active: true
```

**Action:**
```
Admin → Kelola Dokter → Nonaktifkan Dr. Citra
```

**Expected:**
```
1. Dr. Citra.is_active = false ✅
2. jadwal_4.is_active = false ✅
3. jadwal_5.is_active = false ✅
4. Activity log: "Dr. Citra dan 2 jadwal telah dinonaktifkan" ✅
```

**Note:** Data masih ada di database, hanya di-hide dengan flag `is_active: false`

---

### ✅ **Test Case 4: Verifikasi di Halaman Jadwal**

**Sebelum Hapus:**
```
Kelola Jadwal:
  - Dr. Alfian - Senin 08:00-12:00 ✅
  - Dr. Alfian - Rabu 13:00-17:00 ✅
  - Dr. Alfian - Jumat 08:00-12:00 ✅
  - Dr. Budi - Selasa 10:00-14:00 ✅
```

**Setelah Hapus Dr. Alfian:**
```
Kelola Jadwal:
  - Dr. Budi - Selasa 10:00-14:00 ✅
  
(Jadwal Dr. Alfian TIDAK MUNCUL lagi) ✅
```

---

## ⚠️ **Edge Cases Handled**

### 1. **Dokter Tidak Ditemukan**
```dart
if (doctor == null) throw Exception('Doctor not found');
```
→ Error message: "Doctor not found"

### 2. **Gagal Cek Jumlah Jadwal**
```dart
try {
  schedulesCount = await checkSchedules();
} catch (e) {
  // Tetap lanjut delete, tapi tanpa info jumlah
}
```
→ Dialog tetap muncul, tapi tanpa angka jadwal

### 3. **User Cancel Delete**
```dart
if (confirmed != true) return;
```
→ Tidak ada operasi yang dijalankan, langsung return

### 4. **Firestore Transaction Partial Failure**
- Jika gagal hapus jadwal: Error tapi dokter belum terhapus ✅
- Jika gagal hapus dokter: Jadwal sudah terhapus, tapi dokter masih ada ⚠️

**Solusi Future (Firestore Batch):**
```dart
WriteBatch batch = firestore.batch();
// Delete all schedules
for (var schedule in schedules) {
  batch.delete(schedule.reference);
}
// Delete doctor
batch.delete(doctorRef);
// Commit all or nothing
await batch.commit();
```

---

## 📈 **Performance Considerations**

### **Worst Case Scenario:**
```
Dokter dengan 100 jadwal
= 1 query (get schedules)
+ 100 delete operations (schedules)
+ 1 delete (doctor)
+ 1 delete (user)
+ 1 create (activity log)
─────────────────────────
= 104 Firestore operations
```

**Estimated Time:** ~5-10 seconds (tergantung network)

### **Optimization (Future):**
Use **Firestore Batch Write** (max 500 operations per batch):
```dart
WriteBatch batch = firestore.batch();
// Add all deletes to batch
await batch.commit(); // Atomic operation
```

**Benefit:**
- ✅ Faster (1 network call instead of N)
- ✅ Atomic (all-or-nothing)
- ✅ Cheaper (count as 1 operation for billing in some cases)

---

## 📝 **Files Modified**

1. ✅ `lib/features/admin/doctor_view/data/datasources/doctor_admin_remote_datasource.dart`
   - Modified: `deleteDoctor()` - Added cascade to deactivate schedules
   - Modified: `permanentlyDeleteDoctor()` - Added cascade to delete schedules

2. ✅ `lib/features/admin/doctor_view/presentation/controllers/doctor_admin_controller.dart`
   - Added: `import 'package:cloud_firestore/cloud_firestore.dart'`
   - Modified: `removeDoctor()` - Added preview & enhanced confirmation dialog

---

## 🎯 **Summary**

### **Masalah:**
❌ Jadwal tidak terhapus saat dokter dihapus

### **Solusi:**
✅ Cascade delete: Hapus jadwal otomatis saat dokter dihapus
✅ Preview jumlah jadwal sebelum delete
✅ Konfirmasi dialog yang informatif
✅ Activity log mencatat jumlah jadwal yang terhapus
✅ Success message yang detail

### **Impact:**
✅ Data konsistensi terjaga
✅ Tidak ada jadwal orphan
✅ User experience lebih baik
✅ Transparency dalam operasi delete

---

**Date Implemented:** October 13, 2025  
**Status:** ✅ Completed & Ready to Test
