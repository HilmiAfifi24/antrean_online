# Fitur Notifikasi WhatsApp - Sistem Antrean Online

## 📱 Deskripsi
Fitur notifikasi WhatsApp menggunakan Fonnte API untuk mengirim pemberitahuan kepada pasien secara otomatis ketika:
1. Antrean dibuka (Queue Opened)
2. Praktek dokter dimulai (Practice Started)

## 🏗️ Arsitektur Clean Architecture

### Domain Layer
- **Entities**: `NotificationEntity`
- **Repository Interface**: `NotificationRepository`
- **Use Cases**:
  - `SendQueueOpenedNotifications`
  - `SendPracticeStartedNotifications`
  - `ProcessPendingNotifications`

### Data Layer
- **Models**: 
  - `NotificationModel`
  - `FonnteResponseModel`
- **Data Sources**: `NotificationRemoteDataSource`
- **Repository Implementation**: `NotificationRepositoryImpl`

### Presentation Layer
- **Controller**: `NotificationController`
- **Widgets**: `NotificationButtons`
- **Binding**: `NotificationBinding`

## 🔧 Konfigurasi

### 1. Fonnte API Token
Token sudah dikonfigurasi di `lib/core/config/fonnte_config.dart`:
```dart
class FonnteConfig {
  static const String apiToken = "iYRLnWbwGijDJToqfc8v";
  static const String baseUrl = "https://api.fonnte.com/v1";
}
```

### 2. Firestore Collections
Fitur ini menggunakan collection:
- `notifications` - menyimpan log notifikasi
- `queues` - mengambil data pasien yang booking
- `users` - mengambil data kontak pasien
- `schedules` - mengambil data jadwal dokter

### 3. Required Fields di Users Collection
Pastikan setiap user (pasien) memiliki field:
- `name` (String) - Nama pasien
- `phone` (String) - Nomor telepon (format: 628xxxxx atau 08xxxxx)

## 📋 Cara Penggunaan

### A. Dari Halaman Kelola Jadwal

1. **Buka Antrean**
   - Buka halaman "Kelola Jadwal"
   - Pada card jadwal yang aktif, klik tombol **"Buka Antrean"**
   - Konfirmasi pengiriman
   - Sistem akan mengirim notifikasi ke SEMUA pasien yang sudah booking untuk jadwal tersebut hari ini

2. **Mulai Praktek**
   - Pada card jadwal yang aktif, klik tombol **"Mulai Praktek"**
   - Konfirmasi pengiriman
   - Sistem akan mengirim notifikasi hanya ke pasien dengan status "menunggu"

### B. Template Pesan

**Template "Buka Antrean":**
```
🏥 *Antrean Dibuka*

Halo [Nama Pasien],

Antrean Anda untuk *Dr. [Nama Dokter]* telah dibuka!

📋 Nomor Antrean: *[Nomor]*
📅 Tanggal: [Hari, Tanggal]

Silakan datang tepat waktu ke klinik.

_Sistem Antrean Online_
```

**Template "Mulai Praktek":**
```
🏥 *Praktek Dimulai*

Halo [Nama Pasien],

Praktek *Dr. [Nama Dokter]* telah dimulai!

📋 Nomor Antrean: *[Nomor]*
📅 Tanggal: [Hari, Tanggal]

Mohon segera datang ke klinik untuk pemeriksaan.

_Sistem Antrean Online_
```

## 🔍 Fitur Teknis

### 1. Format Nomor Telepon
Sistem otomatis mengkonversi nomor telepon ke format internasional:
- Input: `081234567890` atau `8123456789`
- Output: `6281234567890`

### 2. Error Handling
- Jika nomor telepon kosong/null → skip pasien tersebut
- Jika gagal kirim → simpan error message di Firestore
- Notifikasi tetap tersimpan untuk tracking

### 3. Realtime Sending
- Notifikasi langsung dikirim saat tombol diklik
- Tidak perlu menunggu cron job/scheduler
- Status tersimpan di Firestore untuk audit

### 4. Logging
Semua notifikasi tersimpan di collection `notifications` dengan field:
- `type`: 'queue_opened' atau 'practice_started'
- `recipient_phone`: Nomor telepon penerima
- `recipient_name`: Nama penerima
- `message`: Isi pesan
- `schedule_id`: ID jadwal terkait
- `doctor_name`: Nama dokter
- `scheduled_time`: Waktu dijadwalkan
- `sent_at`: Waktu terkirim
- `is_sent`: Status pengiriman (true/false)
- `error_message`: Pesan error jika gagal

## 🚀 Testing

### 1. Test Kirim Notifikasi
```dart
// Manual test di controller
final controller = Get.find<NotificationController>();
await controller.sendQueueOpenedNotificationsForSchedule('schedule_id');
```

### 2. Test Format Nomor
```dart
// Pastikan nomor pasien sudah benar di Firestore
// Format yang valid:
// - 081234567890
// - 6281234567890
// - +6281234567890
```

### 3. Check Logs
- Lihat console untuk log pengiriman
- Cek collection `notifications` di Firestore
- Verifikasi field `is_sent` dan `sent_at`

## ⚠️ Troubleshooting

### 1. Notifikasi Tidak Terkirim
**Kemungkinan penyebab:**
- Token Fonnte tidak valid → cek di `fonnte_config.dart`
- Nomor telepon pasien kosong → cek field `phone` di collection `users`
- Quota Fonnte habis → cek dashboard Fonnte
- Format nomor salah → pastikan menggunakan format Indonesia

**Solusi:**
```dart
// Check di console log
// Akan muncul: "Sending WhatsApp to: 628xxxxx"
// Jika tidak muncul, berarti nomor tidak ditemukan
```

### 2. Tombol Tidak Muncul
**Kemungkinan penyebab:**
- Jadwal tidak aktif (is_active = false)
- NotificationBinding belum di-initialize

**Solusi:**
```dart
// Pastikan di schedule_admin_binding.dart sudah ada:
NotificationBinding().dependencies();
```

### 3. Error "Schedule not found"
**Penyebab:** Schedule ID tidak ada di Firestore

**Solusi:**
- Pastikan schedule ID benar
- Cek di Firestore console apakah schedule exists

## 📊 Monitoring

### Metrics yang Bisa Dipantau:
1. **Total notifikasi terkirim**: Query `notifications` where `is_sent = true`
2. **Total notifikasi gagal**: Query `notifications` where `is_sent = false`
3. **Notifikasi per jadwal**: Query by `schedule_id`
4. **Notifikasi per dokter**: Query by `doctor_name`

### Dashboard Fonnte:
- Login ke https://fonnte.com
- Cek usage dan quota
- Monitor delivery status

## 🔐 Security

1. **API Token**: Disimpan di config file (jangan commit ke public repo)
2. **Phone Number**: Validasi format sebelum kirim
3. **Rate Limiting**: Fonnte memiliki rate limit, pastikan tidak spam

## 📝 Future Improvements

1. **Scheduled Notifications**: Kirim otomatis based on jam praktek
2. **Custom Templates**: Admin bisa edit template pesan
3. **Multi-Language**: Support bahasa lain selain Indonesia
4. **SMS Fallback**: Jika WhatsApp gagal, kirim SMS
5. **Push Notification**: Tambah in-app notification

## 📞 Support

Jika ada masalah dengan Fonnte API:
- Website: https://fonnte.com
- Support: support@fonnte.com
- Dokumentasi: https://fonnte.com/api

---

**Developer**: Clean Architecture Implementation
**Last Updated**: November 29, 2025
