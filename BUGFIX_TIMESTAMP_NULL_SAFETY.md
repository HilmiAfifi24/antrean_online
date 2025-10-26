# Bug Fix: Timestamp Null Safety

## Error yang Terjadi

Saat patient mendaftar antrean, aplikasi crash dengan error:

```
E/flutter: Unhandled Exception: type 'Null' is not a subtype of type 'Timestamp' in type cast
E/flutter: #0  QueueRemoteDataSource.watchActiveQueue.<anonymous closure>
           (package:antrean_online/features/patient/data/datasources/queue_remote_datasource.dart:168:40)
```

## Root Cause

### Penyebab:
Ketika membuat queue baru menggunakan `FieldValue.serverTimestamp()`, Firestore **tidak langsung** memberikan nilai timestamp. Pada saat pertama kali document dibaca (sebelum server meng-update), field `created_at` bernilai **null**.

### Code Bermasalah:
```dart
// Di createQueue method
'created_at': FieldValue.serverTimestamp(),  // ❌ Null saat pertama dibaca

// Di watchActiveQueue/getActiveQueue
createdAt: (data['created_at'] as Timestamp).toDate(),  // ❌ Crash jika null!
```

### Alur Error:
1. Patient klik "Daftar Antrean"
2. `createQueue()` dipanggil → simpan dengan `serverTimestamp()`
3. `watchActiveQueue()` stream langsung membaca document baru
4. Field `created_at` masih **null** (belum di-update server)
5. Cast `as Timestamp` crash → **"Null is not a subtype of Timestamp"**

## Solusi

### Safe Null Check Pattern

Tambahkan null check sebelum cast Timestamp:

```dart
// ✅ BEFORE (Crash)
appointmentDate: (data['appointment_date'] as Timestamp).toDate(),
createdAt: (data['created_at'] as Timestamp).toDate(),

// ✅ AFTER (Safe)
appointmentDate: data['appointment_date'] != null 
    ? (data['appointment_date'] as Timestamp).toDate()
    : DateTime.now(),
createdAt: data['created_at'] != null
    ? (data['created_at'] as Timestamp).toDate()
    : DateTime.now(),
```

## Files Modified

### 1. `queue_remote_datasource.dart`

**Method: `getActiveQueue()`** (Line ~36, ~43)
```dart
return QueueEntity(
  // ... other fields
  appointmentDate: data['appointment_date'] != null 
      ? (data['appointment_date'] as Timestamp).toDate()
      : DateTime.now(),
  createdAt: data['created_at'] != null
      ? (data['created_at'] as Timestamp).toDate()
      : DateTime.now(),
);
```

**Method: `watchActiveQueue()`** (Line ~168, ~175)
```dart
return QueueEntity(
  // ... other fields
  appointmentDate: data['appointment_date'] != null 
      ? (data['appointment_date'] as Timestamp).toDate()
      : DateTime.now(),
  createdAt: data['created_at'] != null
      ? (data['created_at'] as Timestamp).toDate()
      : DateTime.now(),
);
```

### 2. `schedule_remote_datasource.dart`

**Method: `getAllActiveSchedules()`** (Line ~24)
```dart
final scheduleDate = data['date'] != null
    ? (data['date'] as Timestamp).toDate()
    : DateTime.now();
```

**Method: `searchSchedules()`** (Line ~188)
```dart
final scheduleDate = data['date'] != null
    ? (data['date'] as Timestamp).toDate()
    : DateTime.now();
```

## Testing

### Steps to Verify:
1. **Hot Restart** aplikasi
2. **Login sebagai Patient** (contoh: Dio)
3. **Pilih jadwal dokter** (contoh: Dr. Ali Akbar - Selasa)
4. **Klik "Daftar Antrean"**
5. **Isi form** keluhan
6. **Submit**

### Expected Results:
✅ **No crash** - aplikasi tidak error
✅ **Queue created** - antrean berhasil dibuat
✅ **Stream updated** - halaman "Antrean Saya" langsung update
✅ **Data complete** - nomor antrean, dokter, tanggal tampil lengkap

### Previous Behavior:
❌ App crash saat submit form
❌ Error: "type 'Null' is not a subtype of type 'Timestamp'"
❌ Stream tidak bisa membaca data baru

## Technical Details

### Why `serverTimestamp()` is Null Initially?

Firebase Firestore menggunakan **two-phase update** untuk `serverTimestamp()`:

1. **Local write**: Document ditulis ke local cache dengan placeholder `null`
2. **Server confirmation**: Server meng-update dengan timestamp sebenarnya
3. **Local update**: Cache di-update dengan nilai dari server

Pada **real-time listeners** (`.snapshots()`), phase 1 akan trigger callback dengan nilai `null`.

### Fallback Strategy

Kita menggunakan `DateTime.now()` sebagai fallback:
- **Acceptable** karena timestamp ini hanya untuk display/sorting
- **Server timestamp** tetap tersimpan di Firestore
- **Next read** akan mendapat timestamp yang benar dari server
- **No data loss** - hanya UI yang pakai fallback sementara

## Alternative Solutions (Not Used)

### 1. Skip Null Documents
```dart
if (data['created_at'] == null) return null;
```
**Drawback**: Queue tidak tampil sampai server update (UX buruk)

### 2. Use Local Timestamp
```dart
'created_at': Timestamp.fromDate(DateTime.now()),
```
**Drawback**: Timestamp tidak akurat (tergantung waktu device)

### 3. Wait for Server Update
```dart
await firestore.waitForPendingWrites();
```
**Drawback**: Blocking, lambat, kompleks

## Conclusion

✅ **Bug fixed** dengan menambahkan null safety check pada semua Timestamp cast
✅ **No breaking changes** - backward compatible
✅ **Better UX** - antrean langsung tampil meskipun timestamp belum final
✅ **Production ready** - handle edge cases dengan graceful fallback

## Related Issues

- **BUGFIX_QUOTA_PER_TANGGAL.md** - Related quota calculation fix
- **FIRESTORE_INDEXES_SETUP.md** - Required composite indexes for queries
