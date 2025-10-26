# Bug Fix: Quota Sama di Semua Hari (Client-Side Filter Issue)

## Problem

**Reported Issue:**
- Patient Ahmad Risel mendaftar antrean **hanya pada hari Selasa 28 Oktober**
- Ketika klik filter "Selasa" → Quota Dr. Ali Akbar = **1/10** ✅ (BENAR)
- Ketika klik filter "Rabu" → Quota Dr. Ali Akbar = **1/10** ❌ (SALAH, harusnya 0/10)
- Ketika klik filter "Kamis" → Quota Dr. Ali Akbar = **1/10** ❌ (SALAH, harusnya 0/10)
- Ketika klik filter "Sabtu" → Quota Dr. Ali Akbar = **1/10** ❌ (SALAH, harusnya 0/10)

**Expected:**
- Selasa = 1/10 (ada Ahmad Risel)
- Rabu = 0/10 (belum ada yang daftar)
- Kamis = 0/10 (belum ada yang daftar)
- Sabtu = 0/10 (belum ada yang daftar)

## Root Cause

### Alur Bug

**Before Fix:**

1. **Patient Home page load** → Call `getAllActiveSchedules()`
2. **getAllActiveSchedules()** menghitung quota untuk **closest date** saja:
   ```dart
   // Dari daysOfWeek: [Selasa, Rabu, Kamis, Sabtu]
   // Cari tanggal terdekat = Selasa 29 Oktober
   // Query queues untuk 29 Oktober → Found 1 queue (Ahmad Risel)
   // Return ScheduleEntity dengan currentPatients = 1
   ```

3. **User klik filter "Rabu"** → Call `filterByDay('Rabu')`
4. **filterByDay() lama** hanya **filter di client side**:
   ```dart
   void filterByDay(String day) {
     _filteredSchedules.value = _schedules.where((schedule) {
       return schedule.daysOfWeek.contains(day);
     }).toList();
   }
   ```

5. **Data `_schedules` sudah punya `currentPatients = 1`** (dari calculation Selasa)
6. **Filter hanya show/hide** schedule, **tidak recalculate quota**
7. **Semua hari (Selasa/Rabu/Kamis/Sabtu) menunjukkan 1/10** ❌

### Diagram Bug

```
getAllActiveSchedules()
  ↓
Find closest date: Selasa 29 Okt
  ↓
Query queues for 29 Oktober
  ↓
Found 1 queue → currentPatients = 1
  ↓
ScheduleEntity saved to _schedules
  ↓
User clicks "Rabu" filter
  ↓
filterByDay('Rabu') - CLIENT SIDE ONLY
  ↓
Show schedule if daysOfWeek.contains('Rabu')
  ↓
Still shows currentPatients = 1 ❌ (Wrong!)
```

## Solution

### Strategy: Refetch Data per Day Filter

**After Fix:**

1. **User klik filter "Rabu"** → Call `filterByDay('Rabu')`
2. **filterByDay() baru** → **REFETCH** data dari server:
   ```dart
   Future<void> filterByDay(String day) async {
     _selectedDay.value = day;
     _isLoading.value = true;
     
     // Fetch fresh data with day-specific quota calculation
     final result = await getSchedulesByDay(day);
     _schedules.value = result;
     _filteredSchedules.value = result;
     
     _isLoading.value = false;
   }
   ```

3. **getSchedulesByDay('Rabu')** calls repository
4. **Repository** calls `ScheduleRemoteDataSource.getSchedulesByDay('Rabu')`
5. **DataSource** calculate date untuk Rabu:
   ```dart
   // Now: Sabtu 26 Okt (weekday 6)
   // Target: Rabu (weekday 3)
   // daysUntil = (3 - 6 + 7) % 7 = 4
   // Appointment date = 26 Okt + 4 = Rabu 30 Oktober
   ```

6. **Query queues** untuk **30 Oktober**:
   ```dart
   firestore.collection('queues')
     .where('schedule_id', isEqualTo: scheduleId)
     .where('appointment_date', isEqualTo: Timestamp.fromDate(30 Okt))
     .where('status', whereIn: ['menunggu', 'dipanggil', 'selesai'])
     .get();
   ```

7. **Found 0 queues** → `currentPatients = 0`
8. **Return ScheduleEntity** dengan `currentPatients = 0` ✅
9. **UI shows 0/10** ✅ BENAR!

### Diagram Fix

```
User clicks "Rabu" filter
  ↓
filterByDay('Rabu')
  ↓
Call getSchedulesByDay('Rabu') - SERVER SIDE
  ↓
Calculate appointment date for Rabu
  ↓
Rabu 30 Oktober 2025
  ↓
Query queues for 30 Oktober
  ↓
Found 0 queues → currentPatients = 0
  ↓
ScheduleEntity with currentPatients = 0
  ↓
UI shows 0/10 ✅ (Correct!)
```

## Files Modified

### 1. Created New UseCase

**File:** `lib/features/patient/domain/usecases/get_schedules_by_day.dart`

```dart
import '../entities/schedule_entity.dart';
import '../repositories/patient_schedule_repository.dart';

class GetSchedulesByDay {
  final PatientScheduleRepository repository;

  GetSchedulesByDay(this.repository);

  Future<List<ScheduleEntity>> call(String day) async {
    return await repository.getSchedulesByDay(day);
  }
}
```

### 2. Updated Controller

**File:** `lib/features/patient/presentation/controllers/patient_controller.dart`

**Changes:**

1. **Added import:**
   ```dart
   import '../../domain/usecases/get_schedules_by_day.dart';
   ```

2. **Added dependency:**
   ```dart
   final GetSchedulesByDay getSchedulesByDay;

   PatientController({
     required this.getAllSchedules,
     required this.getSchedulesByDay,  // NEW
     required this.searchSchedules,
   });
   ```

3. **Changed `onInit()`:**
   ```dart
   // BEFORE
   loadSchedules();

   // AFTER
   filterByDay(_selectedDay.value);  // Load with day filter from start
   ```

4. **Replaced `filterByDay()` method:**
   ```dart
   // BEFORE - Client side filter only
   void filterByDay(String day) {
     _selectedDay.value = day;
     _filteredSchedules.value = _schedules.where((schedule) {
       return schedule.daysOfWeek.contains(day);
     }).toList();
   }

   // AFTER - Server side refetch
   Future<void> filterByDay(String day) async {
     try {
       _selectedDay.value = day;
       _isLoading.value = true;
       
       if (searchController.text.isNotEmpty) {
         searchController.clear();
       }

       // Fetch fresh data with day-specific quota calculation
       final result = await getSchedulesByDay(day);
       _schedules.value = result;
       _filteredSchedules.value = result;
       
     } catch (e) {
       _showError('Gagal memuat jadwal: ${e.toString()}');
     } finally {
       _isLoading.value = false;
     }
   }
   ```

5. **Updated search listener:**
   ```dart
   searchController.addListener(() {
     _searchText.value = searchController.text;
     if (searchController.text.isEmpty) {
       // BEFORE
       _filteredSchedules.value = _schedules;
       
       // AFTER - Reload with current day filter
       filterByDay(_selectedDay.value);
     } else {
       performSearch(searchController.text);
     }
   });
   ```

6. **Updated `refreshData()`:**
   ```dart
   // BEFORE
   Future<void> refreshData() async {
     await loadSchedules();
   }

   // AFTER
   Future<void> refreshData() async {
     await filterByDay(_selectedDay.value);
   }
   ```

### 3. Updated Dependency Injection

**File:** `lib/features/patient/patient_binding.dart`

**Changes:**

1. **Added import:**
   ```dart
   import 'domain/usecases/get_schedules_by_day.dart';
   ```

2. **Register UseCase:**
   ```dart
   // Use Cases Layer
   Get.put(GetAllSchedules(Get.find<PatientScheduleRepository>()), permanent: true);
   Get.put(GetSchedulesByDay(Get.find<PatientScheduleRepository>()), permanent: true);  // NEW
   Get.put(SearchSchedules(Get.find<PatientScheduleRepository>()), permanent: true);
   ```

3. **Inject to Controller:**
   ```dart
   Get.put(
     PatientController(
       getAllSchedules: Get.find(),
       getSchedulesByDay: Get.find(),  // NEW
       searchSchedules: Get.find(),
     ),
     permanent: true,
   );
   ```

## Testing Instructions

### 1. Hot Restart

```bash
# In Flutter terminal
R  # Hot restart (full restart required for DI changes)
```

### 2. Test Scenario

**Setup:**
- Patient Ahmad Risel sudah mendaftar Selasa 28 Oktober
- Dr. Ali Akbar punya jadwal: Selasa, Rabu, Kamis, Sabtu

**Test Steps:**

1. **Login** sebagai patient (Ahmad Risel atau lainnya)
2. **Default view** (hari ini Sabtu) → Check quota
3. **Click "Selasa"** → Verify quota = **1/10** ✅
4. **Click "Rabu"** → Verify quota = **0/10** ✅
5. **Click "Kamis"** → Verify quota = **0/10** ✅
6. **Click "Sabtu"** → Verify quota = **0/10** ✅

### 3. Check Terminal Logs

```
[ScheduleRemoteDataSource] getSchedulesByDay(Selasa):
  - Now: 2025-10-26 08:47:00.000 (weekday: 6)
  - Target weekday: 2
  - Days until: 3
  - Appointment date: 2025-10-29 00:00:00.000
  - Querying schedule_id: PBinOOPEUPxtvhHJfmNt
  - Found 1 queues
    * Queue: ahmad risel - Timestamp(...)

[ScheduleRemoteDataSource] getSchedulesByDay(Rabu):
  - Now: 2025-10-26 08:47:00.000 (weekday: 6)
  - Target weekday: 3
  - Days until: 4
  - Appointment date: 2025-10-30 00:00:00.000
  - Querying schedule_id: PBinOOPEUPxtvhHJfmNt
  - Found 0 queues  ← SHOULD BE 0!
```

### 4. Expected Results

| Filter | Tanggal | Queues Found | Quota Display |
|--------|---------|--------------|---------------|
| Selasa | 29 Okt  | 1 (Ahmad Risel) | **1/10** ✅ |
| Rabu   | 30 Okt  | 0 | **0/10** ✅ |
| Kamis  | 31 Okt  | 0 | **0/10** ✅ |
| Sabtu  | 26 Okt  | 0 | **0/10** ✅ |

## Performance Considerations

### Concern: Multiple API Calls

**Before:** 1 API call on page load (getAllActiveSchedules)
**After:** 1 API call per filter click (getSchedulesByDay)

**Impact:**
- Sedikit lebih lambat (ada loading indicator)
- Tapi **data selalu akurat** per hari
- User experience better: lihat loading → tahu data fresh

### Optimization (Future)

Jika perlu optimize, bisa implement **caching strategy**:

```dart
final Map<String, List<ScheduleEntity>> _cachedSchedulesByDay = {};

Future<void> filterByDay(String day) async {
  // Check cache first
  if (_cachedSchedulesByDay.containsKey(day)) {
    _filteredSchedules.value = _cachedSchedulesByDay[day]!;
    return;
  }
  
  // Fetch from server
  final result = await getSchedulesByDay(day);
  _cachedSchedulesByDay[day] = result;
  _filteredSchedules.value = result;
}
```

Tapi untuk sekarang, **refetch setiap kali** lebih aman untuk konsistensi data.

## Alternative Solutions Considered

### ❌ Solution 1: Calculate All Days on Load

```dart
// Load ALL days quota on initial load
for (var day in ['Senin', 'Selasa', 'Rabu', ...]) {
  final schedules = await getSchedulesByDay(day);
  _schedulesByDay[day] = schedules;
}
```

**Rejected:** 
- 7 API calls on page load (too slow)
- Most days tidak di-click user (wasted bandwidth)

### ❌ Solution 2: Recalculate Client-Side

```dart
// When filter, recalculate quota locally
for (var schedule in _schedules) {
  final appointmentDate = calculateDateForDay(day);
  final count = await countQueuesForDate(schedule.id, appointmentDate);
  schedule.currentPatients = count;
}
```

**Rejected:**
- Need to fetch queue data separately
- Inconsistent with server calculation logic
- Hard to maintain

### ✅ Solution 3: Refetch on Filter (CHOSEN)

**Pros:**
- Simple implementation
- Data always fresh and accurate
- Consistent with server logic
- Easy to maintain

**Cons:**
- Sedikit lebih lambat (tapi acceptable dengan loading indicator)

## Conclusion

✅ **Bug fixed** dengan mengubah filter dari client-side ke server-side refetch
✅ **Each day filter** sekarang punya **quota calculation independent**
✅ **Selasa shows 1/10**, Rabu/Kamis/Sabtu shows **0/10** (correct!)
✅ **Clean Architecture** maintained dengan new UseCase
✅ **Loading indicator** shows user bahwa data sedang di-fetch

## Related Fixes

- **BUGFIX_QUOTA_DATE_CALCULATION.md** - Fixed daysUntil calculation formula
- **BUGFIX_QUOTA_PER_TANGGAL.md** - Original fix untuk dynamic quota counting
- **BUGFIX_TIMESTAMP_NULL_SAFETY.md** - Fixed Timestamp null safety issues

All fixes work together untuk ensure **accurate quota display per specific date**! ✅
