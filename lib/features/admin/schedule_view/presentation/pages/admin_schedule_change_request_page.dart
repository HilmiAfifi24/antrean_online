import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antrean_online/features/doctor/data/datasources/schedule_change_request_datasource.dart';
import 'package:antrean_online/features/doctor/domain/entities/schedule_change_request_entity.dart';
import 'package:antrean_online/features/doctor/presentation/controllers/schedule_change_controller.dart';

class AdminScheduleChangeRequestPage extends StatelessWidget {
  const AdminScheduleChangeRequestPage({super.key});

  static const _primaryBlue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminScheduleChangeController(
      datasource: ScheduleChangeRequestDatasource(),
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(context, controller),
          _buildFilterBar(controller),
          Expanded(child: _buildList(controller)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AdminScheduleChangeController controller,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), _primaryBlue],
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x4D3B82F6), blurRadius: 16, offset: Offset(0, 4))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
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
                    Text('Permintaan Jadwal',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Text('Review & tindak lanjuti perubahan jadwal dokter',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Obx(() {
                final pendingCount = controller.requests
                    .where((r) =>
                        r.status == ScheduleChangeRequestStatus.pending)
                    .length;
                return pendingCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$pendingCount Pending',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      )
                    : const SizedBox();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(AdminScheduleChangeController controller) {
    final filters = [
      ('Semua', ''),
      ('Pending', 'pending'),
      ('Disetujui', 'approved'),
      ('Ditolak', 'rejected'),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: filters.map((f) {
                final isActive = controller.statusFilter.value == f.$2;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f.$1),
                    selected: isActive,
                    onSelected: (_) => controller.setStatusFilter(f.$2),
                    selectedColor:
                        _primaryBlue.withValues(alpha: 0.15),
                    checkmarkColor: _primaryBlue,
                    labelStyle: TextStyle(
                      color: isActive ? _primaryBlue : Colors.grey[700],
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isActive ? _primaryBlue : Colors.grey[300]!,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildList(AdminScheduleChangeController controller) {
    return Obx(() {
      final list = controller.filteredRequests;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 72, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('Tidak ada permintaan',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async => controller.setStatusFilter(
            controller.statusFilter.value),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => _AdminRequestCard(
            request: list[i],
            controller: controller,
          ),
        ),
      );
    });
  }
}

// ─── Admin Request Card ───────────────────────────────────────────────────────

class _AdminRequestCard extends StatelessWidget {
  final ScheduleChangeRequestEntity request;
  final AdminScheduleChangeController controller;
  const _AdminRequestCard(
      {required this.request, required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusColor = controller.getStatusColor(request.status);
    final statusLabel = controller.getStatusLabel(request.status);
    final isPending = request.status == ScheduleChangeRequestStatus.pending;

    return GestureDetector(
      onTap: () => _showDetailDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPending
              ? Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  width: 1.5)
              : null,
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    child: const Icon(Icons.person_outline,
                        color: Color(0xFF3B82F6), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.doctorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                              .format(request.createdAt),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _changeRow(
                from:
                    '${request.oldDay}  ${request.oldStartTime}–${request.oldEndTime}',
                to:
                    '${request.newDay}  ${request.newStartTime}–${request.newEndTime}',
              ),
              if (isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(context),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Tolak'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            onPressed: controller.isProcessing.value
                                ? null
                                : () => controller
                                    .approveRequest(request.requestId),
                            icon: controller.isProcessing.value
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.check, size: 16),
                            label: const Text('Setujui'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
                    const TextStyle(fontSize: 12, color: Colors.red),
                textAlign: TextAlign.center),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.arrow_forward_rounded,
              color: Colors.grey, size: 16),
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
                    fontSize: 12, color: Colors.green),
                textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }

  void _showDetailDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Detail Permintaan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _detailRow('Dokter', request.doctorName),
              _detailRow('Jadwal Lama',
                  '${request.oldDay}  ${request.oldStartTime}–${request.oldEndTime}'),
              _detailRow('Jadwal Baru',
                  '${request.newDay}  ${request.newStartTime}–${request.newEndTime}'),
              _detailRow('Alasan', request.reason),
              _detailRow(
                'Tanggal Request',
                DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                    .format(request.createdAt),
              ),
              if (request.rejectionReason != null)
                _detailRow('Alasan Tolak', request.rejectionReason!,
                    valueColor: Colors.red),
              const SizedBox(height: 16),
              if (request.status == ScheduleChangeRequestStatus.pending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                           Get.back();
                           _showRejectDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.isProcessing.value
                                ? null
                                : () => controller
                                    .approveRequest(request.requestId),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10))),
                            child: const Text('Setujui'),
                          )),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    controller.rejectionReasonController.clear();
    if (!context.mounted) return;
    Get.dialog(
      Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tolak Permintaan',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                'Berikan alasan penolakan untuk dr. ${request.doctorName}',
                style:
                    TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.rejectionReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alasan penolakan...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF3B82F6), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: Get.back,
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isProcessing.value
                              ? null
                              : () => controller
                                  .rejectRequest(request.requestId),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10))),
                          child: controller.isProcessing.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : const Text('Tolak'),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
