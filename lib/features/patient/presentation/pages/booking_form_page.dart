  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:get/get.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import '../../../../core/routes/app_routes.dart';
  import '../../domain/entities/schedule_entity.dart';

  // Helper function for formatting date
  String _formatDate(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }



class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  late final TextEditingController complaintController;
  late final TextEditingController birthDateController;
  late final GlobalKey<FormState> formKey;
  bool isLoading = false;
  // Profile fields
  String? userName;
  String? userPhone;
  // Form fields
  DateTime? birthDate;
  String? gender;

  @override
  void initState() {
    super.initState();
    complaintController = TextEditingController();
  birthDateController = TextEditingController();
    formKey = GlobalKey<FormState>();
    // Load user profile from Firestore
    _loadUserProfile();
  }

  @override
  void dispose() {
    complaintController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safe way to get arguments
    final schedule = Get.arguments as ScheduleEntity?;
    // If no schedule provided, show a friendly error screen with a Back button.
    if (schedule == null) {
      // Debug log to help trace transient null args during navigation
      // ignore: avoid_print
      print('[BookingFormPage] arguments are null on open: Get.arguments=${Get.arguments}');

      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1976D2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: const Text('Daftar Antrean'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Mencoba memuat data jadwal...'),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Retry: read Get.arguments again and rebuild
                        final retrySchedule = Get.arguments as ScheduleEntity?;
                        // ignore: avoid_print
                        print('[BookingFormPage] retry get.arguments=$retrySchedule');
                        if (retrySchedule != null) {
                          // rebuild by pushing a new route with the correct args
                          // Use Get.offNamed to replace this page with fresh instance
                          Get.offNamed(AppRoutes.booking, arguments: retrySchedule);
                        } else {
                          // if still null, show a gentle snackbar rather than immediate error
                          Get.snackbar(
                            'Info',
                            'Jadwal belum tersedia. Coba lagi.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange.shade50,
                            colorText: Colors.orange.shade800,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Custom AppBar
                _buildAppBar(context),
                // Form Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Schedule Info Card
                            _buildScheduleCard(schedule),
                            const SizedBox(height: 24),
                            // Profile Info (readonly)
                            if (userName != null && userPhone != null) ...[
                              _buildReadonlyField(label: 'Nama', initialValue: userName!),
                              const SizedBox(height: 12),
                              _buildReadonlyField(label: 'No. HP', initialValue: userPhone!),
                              const SizedBox(height: 16),
                            ],
                            // Form Title
                            const Text(
                              'Data Pendaftaran',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Date of Birth
                            GestureDetector(
                              onTap: () async {
                                final today = DateTime.now();
                                final initial = birthDate ?? DateTime(today.year - 20, today.month, today.day);
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: initial,
                                  firstDate: DateTime(today.year - 100),
                                  lastDate: today,
                                );
                                if (picked != null) {
                                  setState(() {
                                    birthDate = picked;
                                    birthDateController.text = _formatDate(picked);
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: birthDateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Tanggal Lahir',
                                    prefixIcon: const Icon(Icons.cake),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (birthDate == null) {
                                      return 'Tanggal lahir harus dipilih';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Gender Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: gender,
                              decoration: InputDecoration(
                                labelText: 'Jenis Kelamin',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                                DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                              ],
                              onChanged: (val) => setState(() => gender = val),
                              validator: (val) => val == null ? 'Pilih jenis kelamin' : null,
                            ),
                            const SizedBox(height: 16),
                            // Complaint Field
                            _buildTextField(
                              controller: complaintController,
                              label: 'Keluhan',
                              icon: Icons.note_alt_outlined,
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Keluhan tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Capacity Warning
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Sisa kuota: ${schedule.maxPatients - schedule.currentPatients} pasien',
                                      style: TextStyle(
                                        color: Colors.blue[900],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _submitBooking(schedule),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Daftar Antrean',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Daftar Antrean',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleEntity schedule) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    schedule.doctorInitials,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.doctorName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.doctorSpecialization,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hari & Tanggal Pertemuan: ${_formatDate(schedule.date)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadonlyField({required String label, required String initialValue}) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }



  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            userName = data?['name'] ?? '';
            userPhone = data?['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _submitBooking(ScheduleEntity schedule) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Check if schedule is full
      if (schedule.isFull) {
        throw Exception('Maaf, jadwal dokter sudah penuh');
      }

      // Use schedule date as registration date
      final normalizedDate = DateTime(
        schedule.date.year,
        schedule.date.month,
        schedule.date.day,
      );

      // Get current active queue count for this schedule on this specific date
      final querySnapshot = await FirebaseFirestore.instance
          .collection('queues')
          .where('schedule_id', isEqualTo: schedule.id)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .where('status', whereIn: ['menunggu', 'dipanggil', 'selesai'])
          .get();
      
      final queueNumber = querySnapshot.docs.length + 1;

      // Create queue document
      await FirebaseFirestore.instance
          .collection('queues')
          .add({
        'patient_id': user.uid,
        'patient_name': userName ?? '',
        'patient_phone': userPhone ?? '',
        'birth_date': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
        'gender': gender,
        'schedule_id': schedule.id,
        'doctor_id': schedule.doctorId,
        'doctor_name': schedule.doctorName,
        'doctor_specialization': schedule.doctorSpecialization,
        'appointment_date': Timestamp.fromDate(normalizedDate),
        'queue_number': queueNumber,
        'status': 'menunggu',
        'complaint': complaintController.text,
        'created_at': FieldValue.serverTimestamp(),
      });

      // NOTE: Do NOT update a global 'current_patients' on the schedule here.
      // Booking counts should be computed per appointment date by counting
      // queues with the same schedule_id and appointment_date.

      if (!mounted) return;

      // Navigate back first
      Get.until((route) => route.settings.name == '/patient/queue');
      
      // Then show success message after navigation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Get.snackbar(
          'Berhasil',
          'Antrean berhasil dibuat! Nomor antrean Anda: ${queueNumber.toString().padLeft(3, '0')}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
      });
      
    } catch (e) {
      if (!mounted) return;
      
      Get.snackbar(
        'Error',
        'Gagal membuat antrean: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
