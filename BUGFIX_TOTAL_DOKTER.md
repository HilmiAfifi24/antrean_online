# 🐛 Bug Fix: Total Dokter Tidak Update

## 📋 Deskripsi Masalah
Ketika menambahkan dokter baru (misalnya Dr. Attar), total dokter di dashboard tetap menampilkan **0** dan tidak ter-update.

## 🔍 Penyebab Masalah

### 1. **Query yang Salah** ❌
File: `lib/features/admin/home/data/datasources/admin_remote_data_source.dart`

**Masalah:**
```dart
// SEBELUM (SALAH)
Future<int> getTotalDoctors() async {
  final snapshot = await firestore
      .collection('users')  // ❌ Query ke collection yang salah
      .where('role', isEqualTo: 'dokter')
      .where('is_active', isEqualTo: true)
      .orderBy('updated_at', descending: true)  // ❌ Memerlukan composite index
      .get();
  // ...
}
```

**Alasan:**
- Query ke collection `users` padahal data dokter ada di collection `doctors`
- Menggunakan `orderBy('updated_at')` yang memerlukan composite index di Firestore
- Field `updated_at` belum ada saat dokter baru dibuat (hanya ada saat update)
- Query gagal/error tetapi ter-handle dengan return 0

### 2. **Realtime Listener yang Salah** ❌
File: `lib/features/admin/home/presentation/controllers/admin_controller.dart`

**Masalah:**
```dart
// SEBELUM (SALAH)
void _setupRealtimeListener() {
  _statsSubscription = FirebaseFirestore.instance
      .collection('users')  // ❌ Listen ke collection yang salah
      .where('role', isEqualTo: 'dokter')
      .snapshots()
      .listen((snapshot) {
    loadDashboardData();
  });
}
```

**Alasan:**
- Mendengarkan perubahan di collection `users`, bukan `doctors`
- Tidak akan mendeteksi saat dokter baru ditambahkan ke collection `doctors`

## ✅ Solusi yang Diterapkan

### 1. **Perbaiki Query getTotalDoctors()** ✅

```dart
// SESUDAH (BENAR)
Future<int> getTotalDoctors() async {
  try {
    // Ambil langsung dari collection doctors yang aktif
    final snapshot = await firestore
        .collection('doctors')  // ✅ Collection yang benar
        .where('is_active', isEqualTo: true)
        .get();
    
    return snapshot.docs.length;
  } catch (e) {
    print('Error getting total doctors: $e');
    return 0;
  }
}
```

**Keuntungan:**
- ✅ Query langsung ke collection `doctors`
- ✅ Tidak perlu composite index
- ✅ Lebih sederhana dan efisien
- ✅ Hanya menghitung dokter yang aktif (`is_active == true`)

### 2. **Perbaiki Realtime Listener** ✅

```dart
// SESUDAH (BENAR)
void _setupRealtimeListener() {
  _statsSubscription?.cancel();
  // Listen to doctors collection untuk auto-update saat ada perubahan
  _statsSubscription = FirebaseFirestore.instance
      .collection('doctors')  // ✅ Collection yang benar
      .snapshots()
      .listen((snapshot) {
    loadDashboardData();
  });
}
```

**Keuntungan:**
- ✅ Mendengarkan perubahan di collection `doctors`
- ✅ Auto-update saat ada dokter baru ditambahkan
- ✅ Auto-update saat dokter di-edit atau dihapus

### 3. **Tambahkan Refresh on Page Load** ✅

File: `lib/features/admin/home/presentation/pages/home_page.dart`

```dart
// Ubah dari StatelessWidget ke StatefulWidget
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> with RouteAware {
  @override
  void initState() {
    super.initState();
    // Refresh data saat pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AdminController>().loadDashboardData();
    });
  }
  // ...
}
```

**Keuntungan:**
- ✅ Dashboard selalu refresh saat halaman dibuka
- ✅ Data selalu up-to-date saat kembali dari halaman lain

## 🎯 Hasil Akhir

### Sebelum Fix:
1. Tambah dokter baru (Dr. Attar)
2. Kembali ke dashboard
3. Total Dokter = **0** ❌

### Setelah Fix:
1. Tambah dokter baru (Dr. Attar)
2. Kembali ke dashboard
3. Total Dokter = **1** ✅ (atau jumlah sesuai data)
4. **Auto-update realtime** saat ada perubahan di collection doctors ✅

## 📝 Files yang Diubah

1. ✅ `lib/features/admin/home/data/datasources/admin_remote_data_source.dart`
   - Method: `getTotalDoctors()`

2. ✅ `lib/features/admin/home/presentation/controllers/admin_controller.dart`
   - Method: `_setupRealtimeListener()`

3. ✅ `lib/features/admin/home/presentation/pages/home_page.dart`
   - Widget: `AdminHomePage` (StatelessWidget → StatefulWidget)
   - Added: `initState()` dengan refresh callback

## 🧪 Testing

### Test Case 1: Tambah Dokter Baru
1. Login sebagai Admin
2. Buka halaman "Kelola Dokter"
3. Klik "Tambah Dokter"
4. Isi form (nama: Dr. Attar, email: attar@pens.ac.id, dll)
5. Simpan
6. Kembali ke Dashboard
7. **Expected:** Total Dokter bertambah ✅

### Test Case 2: Hapus Dokter
1. Buka halaman "Kelola Dokter"
2. Hapus dokter yang sudah ada
3. Kembali ke Dashboard
4. **Expected:** Total Dokter berkurang ✅

### Test Case 3: Realtime Update
1. Buka Dashboard di device/browser A
2. Di device/browser B, tambah dokter baru
3. **Expected:** Dashboard di device A auto-update ✅

## 💡 Catatan Tambahan

### Query Collection yang Benar:
- **Total Pasien**: `users` where `role == 'pasien'`
- **Total Dokter**: `doctors` where `is_active == true` ✅ (FIXED)
- **Total Jadwal**: `schedules` where `is_active == true`
- **Total Antrean**: `queues`

### Struktur Data Firestore:
```
users/
  {userId}/
    - email: string
    - role: 'admin' | 'dokter' | 'pasien'
    - is_active: boolean
    - created_at: timestamp

doctors/
  {doctorId}/
    - user_id: string (reference to users)
    - nama_lengkap: string
    - nomor_identifikasi: string
    - spesialisasi: string
    - nomor_telepon: string
    - email: string
    - is_active: boolean ✅ (digunakan untuk filtering)
    - created_at: timestamp
    - updated_at: timestamp (optional, hanya saat update)
```

## ✨ Kesimpulan

Bug ini terjadi karena **mismatch antara collection yang di-query dan collection tempat data disimpan**. 

Dengan perbaikan ini:
- ✅ Total dokter akan langsung ter-update saat dokter baru ditambahkan
- ✅ Dashboard mendapat update realtime dari Firestore
- ✅ Tidak ada lagi masalah dengan composite index
- ✅ Query lebih efisien dan reliable

---

**Date Fixed:** October 13, 2025  
**Fixed By:** AI Assistant  
**Status:** ✅ Resolved
