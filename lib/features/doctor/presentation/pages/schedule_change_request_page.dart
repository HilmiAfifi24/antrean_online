import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/schedule_change_controller.dart';
import '../../domain/entities/schedule_change_request_entity.dart';

class ScheduleChangeRequestPage extends StatelessWidget {
  const ScheduleChangeRequestPage({super.key});

  static const _primaryBlue = Color(0xFF1976D2);
  static const _lightBlue = Color(0xFF42A5F5);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleChangeController>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Column(
          children: [
            _buildHeader(context, controller),
            const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                Tab(text: 'Ajukan Perubahan'),
                Tab(text: 'Riwayat Request'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _SubmitTab(controller: controller),
                  _HistoryTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ScheduleChangeController controller,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryBlue, _lightBlue],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jadwal Praktik',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Text('Ajukan perubahan jadwal',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Obx(() {
                final count = controller.unreadCount.value;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => _showNotificationsSheet(controller),
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 26),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: Center(
                            child: Text('$count',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet(ScheduleChangeController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Notifikasi',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Obx(() {
              final notifs = controller.notifications;
              if (notifs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Tidak ada notifikasi',
                      style: TextStyle(color: Colors.grey)),
                );
              }
              return SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: notifs.length,
                  itemBuilder: (_, i) {
                    final n = notifs[i];
                    final isRead = n['is_read'] == true;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: n['type']
                                    ?.toString()
                                    .contains('approved') ==
                                true
                            ? Colors.green[100]
                            : Colors.red[100],
                        child: Icon(
                          n['type']?.toString().contains('approved') == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: n['type']
                                      ?.toString()
                                      .contains('approved') ==
                                  true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      title: Text(n['title'] ?? '',
                          style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14)),
                      subtitle: Text(n['body'] ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600])),
                      tileColor: isRead ? null : Colors.blue[50],
                      onTap: () {
                        if (!isRead) {
                          controller.markNotificationRead(n['id']);
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Form Ajukan Perubahan ─────────────────────────────────────────────

class _SubmitTab extends StatelessWidget {
  final ScheduleChangeController controller;
  const _SubmitTab({required this.controller});

  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('1. Pilih Jadwal yang Ingin Diubah'),
            const SizedBox(height: 12),
            _buildScheduleSelector(context),
            const SizedBox(height: 24),
            _sectionTitle('2. Jadwal Baru'),
            const SizedBox(height: 12),
            _buildNewDaySelector(),
            const SizedBox(height: 12),
            _buildTimeRow(context),
            const SizedBox(height: 24),
            _sectionTitle('3. Alasan Perubahan'),
            const SizedBox(height: 12),
            _buildReasonField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      );
    });
  }

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)));

  Widget _buildScheduleSelector(BuildContext context) {
    if (controller.activeSchedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text('Tidak ada jadwal aktif. Hubungi admin.',
                  style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
    }

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: controller.activeSchedules.map((schedule) {
              final id = schedule['id'] ?? '';
              final days =
                  List<String>.from(schedule['days_of_week'] ?? []);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Color(0xFF1976D2), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${schedule['start_time']} – ${schedule['end_time']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (schedule['poli_name'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        schedule['poli_name'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: days.map((day) {
                        final isSelected =
                            controller.selectedScheduleId.value == id &&
                            controller.selectedOldDay.value == day;
                        return ChoiceChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (_) =>
                              controller.selectSchedule(schedule, day: day),
                          selectedColor: const Color(0xFF1976D2),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF1976D2)
                                  : Colors.grey[300]!,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildNewDaySelector() {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _days.map((day) {
            final isSelected = controller.newDay.value == day;
            return ChoiceChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (_) => controller.newDay.value = day,
              selectedColor: const Color(0xFF1976D2),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF1976D2)
                        : Colors.grey[300]!),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildTimeRow(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _TimePickerCard(
                label: 'Jam Mulai',
                value: controller.newStartTime.value,
                icon: Icons.access_time,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (ctx, child) => MediaQuery(
                      data: MediaQuery.of(ctx)
                          .copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    controller.newStartTime.value =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimePickerCard(
                label: 'Jam Selesai',
                value: controller.newEndTime.value,
                icon: Icons.access_time_filled,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (ctx, child) => MediaQuery(
                      data: MediaQuery.of(ctx)
                          .copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    controller.newEndTime.value =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  }
                },
              ),
            ),
          ],
        ));
  }

  Widget _buildReasonField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller.reasonController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Contoh: Ada kepentingan keluarga yang mendesak...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.isSubmitting.value
                ? null
                : controller.submitRequest,
            icon: controller.isSubmitting.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded),
            label: Text(controller.isSubmitting.value
                ? 'Mengirim...'
                : 'Kirim Permintaan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }
}

// ─── Tab 2: Riwayat Request ───────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final ScheduleChangeController controller;
  const _HistoryTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final requests = controller.myRequests;
      if (requests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off, size: 72, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('Belum ada riwayat request',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (_, i) {
          final req = requests[i];
          return _RequestHistoryCard(
            request: req,
            controller: controller,
          );
        },
      );
    });
  }
}

class _RequestHistoryCard extends StatelessWidget {
  final ScheduleChangeRequestEntity request;
  final ScheduleChangeController controller;
  const _RequestHistoryCard(
      {required this.request, required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusColor = controller.getStatusColor(request.status);
    final statusLabel = controller.getStatusLabel(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                        .format(request.createdAt),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500]),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _changeRow(
              from: '${request.oldDay}  ${request.oldStartTime}–${request.oldEndTime}',
              to: '${request.newDay}  ${request.newStartTime}–${request.newEndTime}',
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Alasan: ${request.reason}',
                style:
                    TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ),
            if (request.status ==
                    ScheduleChangeRequestStatus.rejected &&
                request.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel_outlined,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Alasan penolakan: ${request.rejectionReason}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _changeRow({required String from, required String to}) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(from,
                style:
                    const TextStyle(fontSize: 13, color: Colors.red),
                textAlign: TextAlign.center),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward_rounded,
              color: Colors.grey, size: 18),
        ),
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(to,
                style: const TextStyle(
                    fontSize: 13, color: Colors.green),
                textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}

// ─── Time Picker Card ─────────────────────────────────────────────────────────

class _TimePickerCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  const _TimePickerCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? const Color(0xFF1976D2)
                : Colors.grey[300]!,
            width: hasValue ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon,
                  size: 16,
                  color: hasValue
                      ? const Color(0xFF1976D2)
                      : Colors.grey[400]),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: hasValue
                          ? const Color(0xFF1976D2)
                          : Colors.grey[500])),
            ]),
            const SizedBox(height: 6),
            Text(
              hasValue ? value : 'Pilih waktu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: hasValue
                    ? const Color(0xFF1976D2)
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
