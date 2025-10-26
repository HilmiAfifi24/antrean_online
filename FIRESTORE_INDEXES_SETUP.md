# Firestore Composite Indexes Setup

## Error yang Muncul

Saat membuka halaman Patient Queue, muncul error:

```
[cloud_firestore/failed-precondition] The query requires an index
```

## Penyebab

Firestore membutuhkan **composite index** untuk query yang menggunakan:
- Multiple `where` clauses + `orderBy`
- `whereIn` + `orderBy`
- Filter kompleks lainnya

## Query yang Membutuhkan Index

### 1. Patient Active Queues (watchActiveQueue)
```dart
firestore.collection('queues')
  .where('patient_id', isEqualTo: userId)
  .where('status', whereIn: ['menunggu', 'dipanggil'])
  .orderBy('created_at', descending: true)
```

**Index yang dibutuhkan:**
- `patient_id` (ASCENDING)
- `status` (ASCENDING)
- `created_at` (DESCENDING)
- `__name__` (DESCENDING)

### 2. Current Called Queue (currentQueue)
```dart
firestore.collection('queues')
  .where('schedule_id', isEqualTo: scheduleId)
  .where('status', isEqualTo: 'dipanggil')
  .orderBy('queue_number')
```

**Index yang dibutuhkan:**
- `schedule_id` (ASCENDING)
- `status` (ASCENDING)
- `queue_number` (ASCENDING)
- `__name__` (ASCENDING)

### 3. Waiting Queue Count (waitingCount)
```dart
firestore.collection('queues')
  .where('schedule_id', isEqualTo: scheduleId)
  .where('status', whereIn: ['menunggu', 'dipanggil'])
  .where('queue_number', isLessThan: currentQueueNumber)
  .orderBy('queue_number')
```

**Index yang dibutuhkan:** (sama dengan #2)
- `schedule_id` (ASCENDING)
- `status` (ASCENDING)
- `queue_number` (ASCENDING)
- `__name__` (ASCENDING)

## Solusi yang Sudah Diterapkan

### 1. Konfigurasi `firestore.indexes.json`

File ini berisi definisi index yang dibutuhkan:

```json
{
  "indexes": [
    {
      "collectionGroup": "queues",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "patient_id", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "DESCENDING" },
        { "fieldPath": "__name__", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "queues",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "schedule_id", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "queue_number", "order": "ASCENDING" },
        { "fieldPath": "__name__", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

### 2. Update `firebase.json`

Menambahkan konfigurasi Firestore:

```json
{
  "firestore": {
    "indexes": "firestore.indexes.json"
  },
  "flutter": { ... }
}
```

### 3. Deploy Indexes

```bash
# Set active project
firebase use antrean-online-e0060

# Deploy indexes
firebase deploy --only "firestore:indexes"
```

Output sukses:
```
✓ firestore: deployed indexes in firestore.indexes.json successfully
```

## Status Index

Cek status index di:
https://console.firebase.google.com/project/antrean-online-e0060/firestore/indexes

Index akan dalam status **"Building"** selama beberapa menit, kemudian berubah menjadi **"Enabled"**.

## Testing

Setelah index selesai dibuild (status = Enabled):

1. **Hot Restart aplikasi**
2. **Login sebagai Patient (Dio)**
3. **Buka halaman "Antrean Saya"**
4. **Verifikasi:**
   - ✅ Tidak ada error `failed-precondition`
   - ✅ Antrean aktif muncul (Nomor 001)
   - ✅ Informasi dokter dan jadwal tampil lengkap

## Catatan Penting

- **Index building bisa memakan waktu 5-15 menit** tergantung jumlah data
- Selama building, query akan tetap error
- Setelah status "Enabled", aplikasi langsung bisa menggunakan query tersebut
- Index hanya perlu dibuat **satu kali**, akan tetap ada meskipun deploy ulang app

## Jika Index Gagal

Jika masih error setelah index "Enabled":

1. Cek Firebase Console → Indexes → Pastikan status = **Enabled** (hijau)
2. Copy link auto-generated dari error message
3. Paste di browser untuk langsung buat index dari Firebase Console
4. Tunggu building selesai
5. Hot restart aplikasi

## Maintenance

Jika membuat query baru dengan filter kompleks di masa depan:

1. Error `failed-precondition` akan muncul dengan link auto-generated
2. Klik link tersebut → Create Index di Firebase Console
3. Atau tambahkan ke `firestore.indexes.json` dan deploy ulang

## Files Modified

- ✅ `firestore.indexes.json` - Added composite indexes
- ✅ `firebase.json` - Added firestore configuration
- ✅ `.firebaserc` - Auto-created by `firebase use`
