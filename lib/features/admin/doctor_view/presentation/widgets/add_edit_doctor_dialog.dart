// features/admin/doctors/presentation/widgets/add_edit_doctor_dialog.dart
import 'package:antrean_online/features/admin/doctor_view/presentation/controllers/doctor_admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditDoctorDialog extends StatelessWidget {
  final bool isEditing;

  const AddEditDoctorDialog({
    super.key,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_rounded : Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Dokter' : 'Tambah Dokter Baru',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Lengkap
                    _buildFormField(
                      label: 'Nama Lengkap',
                      controller: controller.nameController,
                      hint: 'Masukkan nama lengkap dokter',
                      icon: Icons.person_rounded,
                      required: true,
                    ),

                    const SizedBox(height: 20),

                    // Nomor Identifikasi
                    _buildFormField(
                      label: 'Nomor Identifikasi',
                      controller: controller.identificationController,
                      hint: 'Masukkan nomor SIP/STR',
                      icon: Icons.badge_rounded,
                      required: true,
                    ),

                    const SizedBox(height: 20),

                    // Spesialisasi
                    _buildSpecializationField(controller),

                    const SizedBox(height: 20),

                    // Nomor Telepon
                    _buildFormField(
                      label: 'Nomor Telepon',
                      controller: controller.phoneController,
                      hint: 'Masukkan nomor telepon',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      required: true,
                    ),

                    const SizedBox(height: 20),

                    // Email
                    _buildFormField(
                      label: 'Email',
                      controller: controller.emailController,
                      hint: 'Masukkan alamat email',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      required: true,
                      enabled: !isEditing, // Email tidak bisa diubah saat edit
                    ),

                    if (isEditing) 
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Email tidak dapat diubah setelah akun dibuat',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    // Password Field (hanya untuk mode tambah)
                    if (!isEditing) ...[
                      const SizedBox(height: 20),
                      _buildPasswordField(controller),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isFormValid
                          ? () {
                              if (isEditing) {
                                controller.updateExistingDoctor(
                                  controller.currentDoctor!.id,
                                );
                              } else {
                                controller.addNewDoctor();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                      ),
                      child: Obx(() => controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isEditing ? 'Simpan Perubahan' : 'Tambah Dokter',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: enabled ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  // Password field khusus dengan toggle visibility
Widget _buildPasswordField(DoctorController controller) {
  // deklarasi variable di luar builder supaya bisa di-toggle oleh StatefulBuilder
  bool isPasswordVisible = false;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          Text(
            'Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            ' *',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return TextField(
              controller: controller.passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Masukkan password (minimal 6 karakter)',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    // <-- ternary expression harus ada di sini, tidak terputus
                    isPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Password akan digunakan dokter untuk login ke sistem',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
          fontStyle: FontStyle.italic,
        ),
      ),
    ],
  );
}


  Widget _buildSpecializationField(DoctorController controller) {
    final specializations = [
      'Umum',
      'Anak',
      'Jantung',
      'Mata',
      'Kulit',
      'Gigi',
      'Bedah',
      'Kandungan',
      'Syaraf',
      'Paru',
      'Orthopedi',
      'THT',
      'Psikiatri',
      'Radiologi',
      'Anestesi',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Spesialisasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Obx(() => DropdownButtonFormField<String>(
            initialValue: controller.selectedSpecialization.isEmpty 
                ? null 
                : controller.selectedSpecialization,
            hint: const Text(
              'Pilih spesialisasi dokter',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.medical_services_rounded,
                color: Color(0xFF64748B),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: specializations.map((String specialization) {
              return DropdownMenuItem<String>(
                value: specialization,
                child: Text(
                  specialization,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                controller.setSelectedSpecialization(value);
              }
            },
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
            ),
            dropdownColor: Colors.white,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          )),
        ),
      ],
    );
  }
}