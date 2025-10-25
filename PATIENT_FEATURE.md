# Patient Feature - Jadwal Dokter

## 📋 Overview
Fitur untuk menampilkan jadwal dokter yang telah dibuat oleh admin kepada pasien. Pasien dapat melihat, mencari, dan memfilter jadwal berdasarkan hari.

## 🏗️ Architecture
Menggunakan Clean Architecture dengan 3 layer:

### 1. Domain Layer
- **Entity**: `ScheduleEntity` - Model untuk jadwal dokter
- **Repository Interface**: `PatientScheduleRepository` - Contract untuk data operations
- **Use Cases**:
  - `GetAllSchedules` - Mengambil semua jadwal aktif
  - `SearchSchedules` - Mencari jadwal berdasarkan nama dokter

### 2. Data Layer
- **Data Source**: `ScheduleRemoteDataSource` - Komunikasi dengan Firestore
- **Repository Implementation**: `PatientScheduleRepositoryImpl` - Implementasi contract

### 3. Presentation Layer
- **Controller**: `PatientController` - State management dengan GetX
- **Page**: `PatientHomePage` - UI untuk dashboard pasien

## ✨ Features

### 1. Realtime Updates
Jadwal akan otomatis terupdate ketika admin melakukan perubahan:
```dart
StreamSubscription? _schedulesSubscription;

void _setupRealtimeListener() {
  _schedulesSubscription = FirebaseFirestore.instance
      .collection('schedules')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .listen((snapshot) {
        // Update schedules automatically
      });
}
```

### 2. Filter by Day
Pasien dapat memfilter jadwal berdasarkan hari:
- Senin, Selasa, Rabu, Kamis, Jumat, Sabtu, Minggu
- Menampilkan hanya jadwal yang sesuai dengan hari yang dipilih

### 3. Search Functionality
Pencarian jadwal berdasarkan nama dokter:
```dart
void performSearch(String query) {
  if (query.isEmpty) {
    _filteredSchedules.value = _schedules;
  } else {
    _filteredSchedules.value = _schedules
        .where((schedule) => schedule.doctorName
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }
}
```

### 4. Dynamic Greeting
Menampilkan sapaan berdasarkan waktu:
- Pagi (00:00 - 11:59): "Selamat Pagi"
- Siang (12:00 - 14:59): "Selamat Siang"
- Sore (15:00 - 17:59): "Selamat Sore"
- Malam (18:00 - 23:59): "Selamat Malam"

## 🎨 UI Components

### Header Section
```dart
- Greeting (Selamat Pagi/Siang/Sore/Malam)
- Patient Name (dari Firebase Auth)
- Motivational Message: "Semoga anda lekas sembuh"
- Search Bar
```

### Action Buttons
1. **Antrean Saya** - Lihat antrean pasien (coming soon)
2. **Daftar Dokter** - Lihat daftar semua dokter (coming soon)
3. **Profil Saya** - Edit profil pasien (coming soon)

### Day Filter Tabs
Horizontal scrollable tabs untuk memilih hari

### Schedule List
Menampilkan kartu jadwal dokter dengan informasi:
- Avatar dokter
- Nama dokter
- Spesialisasi
- Jam praktik (08:00 - 09:40)
- Kuota pasien (3/10)
- Status: Tersedia / Penuh

## 📊 Data Flow

### Admin → Firestore → Patient

1. **Admin creates schedule**:
```dart
// Admin creates schedule in Firestore
await FirebaseFirestore.instance.collection('schedules').add({
  'doctorId': 'doctor_123',
  'doctorName': 'dr. Firza',
  'doctorSpecialization': 'Dokter Umum',
  'date': '2024-03-20',
  'startTime': '08:00',
  'endTime': '09:40',
  'daysOfWeek': ['Senin', 'Rabu'],
  'maxPatients': 10,
  'currentPatients': 0,
  'isActive': true,
});
```

2. **Patient views schedule**:
```dart
// Realtime listener automatically fetches and updates
_schedulesSubscription = FirebaseFirestore.instance
    .collection('schedules')
    .where('isActive', isEqualTo: true)
    .orderBy('date')
    .snapshots()
    .listen((snapshot) {
      // UI updates automatically
    });
```

## 🔧 Setup & Usage

### 1. Dependencies Injection
```dart
// lib/features/patient/patient_binding.dart
class PatientBinding extends Bindings {
  @override
  void dependencies() {
    // Register all dependencies
    Get.put<ScheduleRemoteDataSource>(...);
    Get.put<PatientScheduleRepository>(...);
    Get.put(GetAllSchedules(...));
    Get.put(SearchSchedules(...));
    Get.put(PatientController(...));
  }
}
```

### 2. Routing
```dart
// lib/core/routes/app_pages.dart
GetPage(
  name: AppRoutes.pasien,
  page: () => const PatientHomePage(),
  binding: PatientBinding(),
),
```

### 3. Navigation
```dart
// Navigate to patient dashboard
Get.toNamed(AppRoutes.pasien);
```

## 🧪 Testing

### Unit Test Example
```dart
test('should filter schedules by day', () {
  // Arrange
  final schedules = [
    ScheduleEntity(daysOfWeek: ['Senin']),
    ScheduleEntity(daysOfWeek: ['Selasa']),
  ];
  
  // Act
  controller.filterByDay('Senin');
  
  // Assert
  expect(controller.filteredSchedules.length, 1);
  expect(controller.filteredSchedules.first.daysOfWeek.contains('Senin'), true);
});
```

## 🔄 State Management

### Observable Variables
```dart
final RxList<ScheduleEntity> _schedules = <ScheduleEntity>[].obs;
final RxList<ScheduleEntity> _filteredSchedules = <ScheduleEntity>[].obs;
final RxBool _isLoading = false.obs;
final RxString _selectedDay = 'Senin'.obs;
final RxString _patientName = ''.obs;
```

### Getters (tanpa .value)
```dart
List<ScheduleEntity> get schedules => _schedules.toList();
List<ScheduleEntity> get filteredSchedules => _filteredSchedules.toList();
bool get isLoading => _isLoading.value;
String get selectedDay => _selectedDay.value;
String get patientName => _patientName.value;
```

## 📝 Notes

### Firestore Collection Structure
```
schedules/
  {scheduleId}/
    - doctorId: string
    - doctorName: string
    - doctorSpecialization: string
    - date: string (YYYY-MM-DD)
    - startTime: string (HH:mm)
    - endTime: string (HH:mm)
    - daysOfWeek: array<string>
    - maxPatients: number
    - currentPatients: number
    - isActive: boolean
    - createdAt: timestamp
```

### Memory Management
Controller properly cleans up subscriptions:
```dart
@override
void onClose() {
  _schedulesSubscription?.cancel();
  searchController.dispose();
  super.onClose();
}
```

## 🚀 Future Enhancements

1. **Booking System**
   - Pasien dapat booking jadwal
   - Konfirmasi booking realtime
   - Notifikasi ke admin dan dokter

2. **Queue Management**
   - Lihat nomor antrean
   - Estimasi waktu tunggu
   - Status antrean (menunggu, dipanggil, selesai)

3. **Doctor Details**
   - Profil lengkap dokter
   - Riwayat praktik
   - Rating dan review

4. **Patient Profile**
   - Edit data diri
   - Riwayat kunjungan
   - Medical records

5. **Notifications**
   - Push notification untuk jadwal baru
   - Reminder untuk appointment
   - Update status antrean

## ✅ Checklist Implementation

- [x] Create domain entities
- [x] Create repository interface
- [x] Create data source
- [x] Create repository implementation
- [x] Create use cases
- [x] Create controller with realtime listener
- [x] Create UI page
- [x] Setup dependency injection (binding)
- [x] Configure routing
- [ ] Add booking functionality
- [ ] Add queue management
- [ ] Add doctor details page
- [ ] Add patient profile page
- [ ] Add push notifications

## 🎯 How to Test

1. **Login sebagai Admin**
   - Buat beberapa jadwal dokter
   - Set status aktif

2. **Logout dan Login sebagai Pasien**
   - Dashboard akan menampilkan jadwal yang dibuat admin
   - Coba search dokter
   - Filter berdasarkan hari
   - Pull to refresh untuk update data

3. **Test Realtime**
   - Buka aplikasi di 2 device/emulator
   - Device 1: Admin - tambah/edit jadwal
   - Device 2: Pasien - lihat perubahan secara realtime

## 📖 References

- [GetX State Management](https://pub.dev/packages/get)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
