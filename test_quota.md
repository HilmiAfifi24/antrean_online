# Debug Test Quota Per Tanggal

## Informasi Test:
- **Hari Ini**: Jumat, 25 Oktober 2025
- **Pasien Dio Mendaftar**: Selasa, 28 Oktober 2025
- **Jadwal Dr. Ali Akbar**: Sabtu, Selasa, Rabu, Kamis

## Expected Results:

### Filter "Sabtu" (26 Oktober 2025):
- ✅ Kuota: **0/10** (BENAR - tidak ada pasien yang mendaftar Sabtu 26 Okt)

### Filter "Selasa" (28 Oktober 2025):
- ✅ Kuota: **1/10** (BENAR - ada Dio yang mendaftar Selasa 28 Okt)

### Filter "Rabu" (29 Oktober 2025):
- ✅ Kuota: **0/10** (BENAR - tidak ada pasien yang mendaftar Rabu 29 Okt)

### Filter "Kamis" (30 Oktober 2025):
- ✅ Kuota: **0/10** (BENAR - tidak ada pasien yang mendaftar Kamis 30 Okt)

## Cara Test:

1. **Hot Restart Aplikasi**
2. **Login sebagai Pasien (Dio)**
3. **Buka Patient Home**
4. **Klik Filter "Sabtu"** → Lihat kuota = 0/10
5. **Klik Filter "Selasa"** → Lihat kuota = 1/10 ← INI YANG PENTING!
6. **Klik Filter "Rabu"** → Lihat kuota = 0/10
7. **Klik Filter "Kamis"** → Lihat kuota = 0/10

## Data di Firestore:

### Collection: queues
```javascript
{
  patient_id: "dio_uid",
  patient_name: "dio ramadhan",
  schedule_id: "ali_akbar_schedule_id",
  appointment_date: Timestamp(28 Oktober 2025, 00:00:00),
  status: "menunggu",
  // ...
}
```

### Penjelasan:
- `appointment_date` disimpan sebagai **Timestamp** dengan tanggal **28 Oktober 2025**
- Query di kode kita mencari queue dengan:
  - `schedule_id` = ID jadwal Ali Akbar
  - `appointment_date` = 28 Oktober 2025 (saat filter Selasa)
  - `status` IN ['menunggu', 'dipanggil', 'selesai']
- Jadi saat filter **Selasa** (28 Okt), query akan menemukan 1 queue (Dio)
- Saat filter **Sabtu** (26 Okt), query tidak menemukan queue (0)

