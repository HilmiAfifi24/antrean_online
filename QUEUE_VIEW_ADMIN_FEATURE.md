# FITUR ANTREAN ADMIN - DOKUMENTASI

## 📋 Overview

Fitur untuk menampilkan daftar antrean pasien yang terdaftar pada hari ini (sesuai tanggal sistem). Admin dapat melihat semua antrean dengan berbagai status dan filter berdasarkan status.

## 🎯 Fitur Utama

### 1. Tampilan Dashboard Statistik
- **Total Menunggu**: Jumlah pasien dengan status "menunggu"
- **Total Dipanggil**: Jumlah pasien dengan status "dipanggil"
- **Total Selesai**: Jumlah pasien dengan status "selesai"
- **Total Dibatalkan**: Jumlah pasien dengan status "dibatalkan"

### 2. Filter Status
- Filter chip horizontal scrollable
- Filter: Semua, Menunggu, Dipanggil, Selesai, Dibatalkan
- Menampilkan jumlah antrean per status
- UI berubah saat filter dipilih (selected state)

### 3. Daftar Antrean
- List pasien dengan informasi lengkap
- Badge nomor antrean yang prominent
- Informasi dokter dan waktu praktik
- Badge status dengan warna berbeda per status
- Tap untuk melihat detail lengkap

### 4. Detail Modal
- Bottom sheet dengan informasi lengkap pasien
- Nomor antrean, nama pasien, dokter, spesialisasi
- Tanggal dan waktu appointment
- Keluhan pasien
- Status antrean dengan icon

### 5. Realtime Updates
- Data update otomatis saat ada perubahan di Firestore
- Pull to refresh untuk refresh manual
- Auto-subscribe/unsubscribe on init/close

## 🏗️ Arsitektur Clean Architecture

### Domain Layer
```
lib/features/admin/queue_view/domain/
├── entities/
│   └── queue_admin_entity.dart          # Entity antrean
├── repositories/
│   └── queue_admin_repository.dart      # Interface repository
└── usecases/
    └── get_today_queues.dart            # Use case get antrean hari ini
```

### Data Layer
```
lib/features/admin/queue_view/data/
├── models/
│   └── queue_admin_model.dart           # Model Firestore
├── datasources/
│   └── queue_admin_remote_datasource.dart # Remote data source
└── repositories/
    └── queue_admin_repository_impl.dart  # Implementasi repository
```

### Presentation Layer
```
lib/features/admin/queue_view/presentation/
├── controllers/
│   └── queue_view_controller.dart       # GetX controller
├── pages/
│   └── queue_view_page.dart             # Main page
└── widgets/
    ├── queue_stats_card.dart            # Card statistik
    ├── status_filter_chip.dart          # Filter chip
    └── queue_list_item.dart             # Item list antrean
```

### Binding
```
lib/features/admin/queue_view/
└── queue_view_binding.dart              # Dependency injection
```

## 🔄 Data Flow

### Query Firestore
```dart
firestore
  .collection('queues')
  .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
  .orderBy('queue_number')
  .snapshots() // Realtime stream
```

**Filter Logic:**
- Hanya menampilkan antrean dengan `appointment_date` = hari ini (00:00:00)
- Diurutkan berdasarkan `queue_number` ascending
- Update realtime via Firestore snapshots()

## 🎨 UI Design

### Color Scheme
| Status | Color | Hex Code |
|--------|-------|----------|
| Menunggu | Yellow/Amber | #F59E0B |
| Dipanggil | Blue | #3B82F6 |
| Selesai | Green | #10B981 |
| Dibatalkan | Red | #EF4444 |
| Default | Grey | #64748B |

### Layout
1. **AppBar**: Title "Antrean Hari Ini" + Tanggal lengkap
2. **Stats Section**: 4 cards dalam 2 baris (gradient blue background)
3. **Filter Section**: Horizontal scrollable chips
4. **List Section**: Vertical scrollable list dengan empty state

### Component Details

#### QueueStatsCard
- White background dengan shadow
- Icon dalam container colored (10% opacity)
- Bold number dengan warna status
- Small subtitle text

#### StatusFilterChip
- Rounded pill shape
- Selected: Blue background, white text
- Unselected: White background, grey text
- Count badge dengan opacity background

#### QueueListItem
- Border dengan warna status
- Large queue number badge
- 3 lines of info: name, doctor, time
- Status badge di kanan
- Tap untuk detail modal

## 🚀 Cara Penggunaan

### Admin Flow
1. Login sebagai admin
2. Tap card **"Total Antrean"** di dashboard
3. Melihat statistik antrean hari ini
4. Filter berdasarkan status (optional)
5. Tap item untuk melihat detail lengkap
6. Pull down untuk refresh data

### Testing
1. Buat antrean dari aplikasi pasien untuk hari ini
2. Buka halaman admin queue view
3. Verifikasi antrean muncul dengan status "menunggu"
4. Ubah status antrean di Firestore (untuk testing)
5. Lihat perubahan realtime di UI

## 📱 Screenshots Features

- ✅ Responsive layout (mobile optimized)
- ✅ Empty state handling
- ✅ Loading state (circular progress indicator)
- ✅ Error handling dengan snackbar
- ✅ Pull to refresh
- ✅ Smooth animations (InkWell ripple, DraggableScrollableSheet)
- ✅ Modern Material Design 3

## 🔧 Technical Details

### Dependencies
- **get**: State management & routing
- **cloud_firestore**: Database & realtime updates
- **intl**: Date formatting (Indonesia locale)

### Firestore Index
Composite index dibutuhkan untuk query:
```json
{
  "collectionGroup": "queues",
  "fields": [
    { "fieldPath": "appointment_date", "order": "ASCENDING" },
    { "fieldPath": "queue_number", "order": "ASCENDING" }
  ]
}
```

### Memory Management
- StreamSubscription di-cancel di `onClose()`
- Controller di-lazyPut untuk efficient memory
- Auto-dispose GetX reactive variables

## 📝 Notes

### Date Logic
- Menggunakan **start of day** (00:00:00) untuk query
- Format tanggal: "Senin, 23 November 2025"
- Locale Indonesia untuk nama hari/bulan

### Status Flow
```
Pasien Daftar → menunggu
Dokter Panggil → dipanggil
Dokter Selesai → selesai
Pasien Batalkan → dibatalkan
```

### Future Enhancements (Optional)
- [ ] Export data antrean ke PDF/Excel
- [ ] Filter berdasarkan tanggal custom
- [ ] Filter berdasarkan dokter
- [ ] Search pasien by name
- [ ] Sort options (by number, time, status)
- [ ] Bulk actions (cancel multiple queues)

## ✅ Checklist Implementation

- [x] Domain layer (entity, repository, usecase)
- [x] Data layer (model, datasource, repository impl)
- [x] Presentation layer (controller, page, widgets)
- [x] Binding & dependency injection
- [x] Routing integration
- [x] Realtime updates
- [x] Filter functionality
- [x] Detail modal
- [x] Empty state
- [x] Error handling
- [x] Pull to refresh
- [x] Modern UI design

---

**Fitur ini mengikuti pattern yang sama dengan fitur lain di project ini (doctor_view, schedule_view, patient_view) sehingga mudah di-maintain dan di-scale.**
