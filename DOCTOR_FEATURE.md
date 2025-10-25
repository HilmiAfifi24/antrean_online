# FITUR DOKTER - DOKUMENTASI

## 📋 Struktur File

### Controller
- **doctor_controller.dart** - Mengelola state dan business logic untuk dokter
  - Load data dokter dari Firestore
  - Statistik antrean hari ini
  - Panggil pasien berikutnya
  - Lewati pasien
  - Selesaikan pasien

### Pages
- **doctor_home_page.dart** - Halaman utama dokter dengan fitur:
  - Header dengan greeting & nama dokter
  - Card "Antrean Saat Ini" (realtime)
  - Tombol aksi: Panggil & Lewati
  - Statistik: Total, Menunggu, Selesai
  - Daftar antrean pasien (realtime)

### Binding
- **doctor_binding.dart** - Dependency injection untuk DoctorController

## 🎨 Fitur Utama

### 1. Header Dokter
- Greeting berdasarkan waktu (Pagi/Siang/Sore/Malam)
- Nama dokter dengan prefix "dr."
- Spesialisasi dokter
- Icon profil

### 2. Card Antrean Saat Ini
**Jika ada pasien dipanggil:**
- Background hijau gradient
- Nomor antrean (format: 001, 002, dst)
- Nama pasien
- Icon medical services

**Jika belum ada yang dipanggil:**
- Background abu-abu
- Icon event_busy
- Text: "Belum ada yang dipanggil"

### 3. Tombol Aksi

**Tombol Panggil (Biru):**
- Memanggil pasien berikutnya dari daftar "menunggu"
- Update status menjadi "dipanggil"
- Mencatat waktu dipanggil (called_at)
- Disabled saat loading

**Tombol Lewati (Orange Outline):**
- Melewati pasien yang sedang dipanggil
- Update status kembali ke "menunggu"
- Mencatat waktu dilewati (skipped_at)
- Disabled saat loading

### 4. Statistik Cards
Menampilkan 3 card dengan warna berbeda:
- **Total** (Biru): Total pasien hari ini
- **Menunggu** (Orange): Pasien yang belum dipanggil
- **Selesai** (Hijau): Pasien yang sudah dilayani

### 5. Daftar Antrean Pasien
Menampilkan semua pasien dengan status "menunggu" dan "dipanggil":
- Nomor antrean (dalam kotak biru/hijau)
- Nama pasien
- Keluhan pasien
- Badge "Dipanggil" untuk pasien aktif (hijau)
- Border hijau untuk pasien yang sedang dipanggil
- Urut berdasarkan nomor antrean

## 🔄 Flow Penggunaan

1. **Dokter Login**
   - Login dengan role "doctor"
   - Redirect ke `/doctor/home`

2. **Lihat Daftar Antrean**
   - Semua pasien hari ini ditampilkan
   - Realtime update via StreamBuilder

3. **Panggil Pasien**
   - Klik tombol "Panggil"
   - Sistem ambil pasien pertama dengan status "menunggu"
   - Update status → "dipanggil"
   - Card hijau muncul di atas

4. **Opsi Setelah Panggil**
   - **Lewati**: Pasien dikembalikan ke status "menunggu"
   - **Selesai**: (fitur future) Update status → "selesai"

5. **Refresh Data**
   - Pull to refresh di halaman
   - Klik tombol refresh di header daftar

## 📊 Data Firestore

### Collection: queues
```javascript
{
  patient_id: "uid123",
  patient_name: "Rifky",
  doctor_id: "uid456",
  doctor_name: "Dr. Aldo",
  schedule_id: "schedule789",
  appointment_date: Timestamp,
  appointment_time: "08:00 - 17:00",
  queue_number: 1,
  status: "menunggu" | "dipanggil" | "selesai" | "dibatalkan",
  complaint: "Sakit kepala",
  created_at: Timestamp,
  called_at: Timestamp,      // when status → dipanggil
  skipped_at: Timestamp,     // when lewati clicked
  completed_at: Timestamp    // when selesai clicked
}
```

### Collection: users
```javascript
{
  uid: "uid456",
  email: "doctor@example.com",
  role: "doctor",
  name: "Aldo Marsendo",
  phone: "08123456789"
}
```

### Collection: doctors
```javascript
{
  user_id: "uid456",
  name: "Dr. Aldo Marsendo",
  specialization: "Mata",
  // ... other fields
}
```

## 🎯 Routing

### Routes Terdaftar:
```dart
// app_routes.dart
static const doctorHome = '/doctor/home';

// app_pages.dart
GetPage(
  name: AppRoutes.doctorHome,
  page: () => const DoctorHomePage(),
  binding: doctor_binding.DoctorBinding(),
)
```

### Navigasi:
```dart
// Dari login setelah auth sukses (role: doctor)
Get.offNamed(AppRoutes.dokter);
// DokterDashboard akan redirect ke:
Get.offNamed('/doctor/home');
```

## 🎨 Design System

### Warna:
- **Primary Blue**: `Color(0xFF1976D2)`
- **Light Blue**: `Color(0xFF42A5F5)`
- **Green (Active)**: `Color(0xFF4CAF50)`
- **Orange (Warning)**: `Color(0xFFFF9800)`
- **Grey Background**: `Colors.grey[50]`

### Gradient:
```dart
LinearGradient(
  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
)
```

### Border Radius:
- Card: `16px`
- Button: `12px`
- Avatar: `12px`

### Spacing:
- Small: `12px`
- Medium: `16px`
- Large: `24px`

## 📱 Responsive Design

### Screen Size Detection:
```dart
final isSmallScreen = screenWidth < 360;
```

### Adaptive Sizing:
- Font: 14-24px (adaptif)
- Padding: 12-20px (adaptif)
- Icon: 20-28px (adaptif)

## 🔧 Methods di DoctorController

### 1. _loadDoctorData()
- Load nama dokter dari collection `users`
- Load spesialisasi dari collection `doctors`
- Match by `user_id`

### 2. _loadQueueStats()
- Hitung total pasien hari ini
- Hitung pasien selesai
- Hitung pasien menunggu
- Filter by `doctor_id` dan `appointment_date`

### 3. callNextPatient()
- Query pasien dengan status "menunggu"
- Order by queue_number (ambil terkecil)
- Update status → "dipanggil"
- Set `called_at` timestamp
- Refresh statistik

### 4. completeCurrentPatient() [Future Implementation]
- Query pasien dengan status "dipanggil"
- Update status → "selesai"
- Set `completed_at` timestamp
- Refresh statistik

### 5. skipCurrentPatient()
- Query pasien dengan status "dipanggil"
- Update status → "menunggu"
- Set `skipped_at` timestamp
- Refresh statistik

### 6. refreshData()
- Reload semua data dokter
- Reload semua statistik
- Called by pull-to-refresh

## 🚀 Cara Testing

### 1. Login sebagai Dokter
- Email: doctor@example.com
- Role harus "doctor" di Firestore

### 2. Pastikan Ada Antrean
- Buat antrean dari aplikasi pasien
- Pilih dokter yang sedang login
- Hari harus hari ini

### 3. Test Flow Lengkap
1. Buka halaman dokter
2. Lihat daftar antrean kosong
3. Buat antrean dari pasien
4. Refresh halaman dokter
5. Klik "Panggil" → lihat card hijau muncul
6. Klik "Lewati" → card hilang, pasien kembali ke daftar
7. Klik "Panggil" lagi
8. [Future] Klik "Selesai" → pasien hilang dari daftar

## 📝 TODO / Future Enhancements

1. **Tombol Selesai**
   - Tambah tombol "Selesai" di samping "Lewati"
   - Call method `completeCurrentPatient()`

2. **Detail Pasien**
   - Klik card pasien → lihat detail lengkap
   - Riwayat medis
   - Nomor telepon

3. **Statistik Lanjutan**
   - Grafik harian/mingguan/bulanan
   - Rata-rata waktu pelayanan
   - Tingkat pembatalan

4. **Notifikasi**
   - Push notification saat ada pasien baru
   - Sound saat pasien datang

5. **Jadwal Dokter**
   - Lihat jadwal praktik
   - Update status kehadiran

6. **Profile Dokter**
   - Edit profil
   - Change password
   - Logout

## 🐛 Known Issues

- Belum ada tombol "Selesai" (masih manual di Firestore)
- Belum ada validasi jadwal dokter (bisa panggil kapan saja)
- Belum ada profile/logout button

## ✅ Checklist Implementasi

- [x] DoctorController dengan semua methods
- [x] DoctorHomePage dengan UI lengkap
- [x] DoctorBinding untuk dependency injection
- [x] Routing integration
- [x] Realtime queue updates
- [x] Statistics cards
- [x] Call & Skip functionality
- [ ] Complete functionality
- [ ] Doctor profile page
- [ ] Logout button
- [ ] Detail pasien modal
