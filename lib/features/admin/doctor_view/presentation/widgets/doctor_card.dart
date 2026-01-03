import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:flutter/material.dart';

class DoctorCard extends StatefulWidget {
  final DoctorAdminEntity doctor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _getSpecializationColor(
                  widget.doctor.spesialisasi,
                ).withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? _getSpecializationColor(
                        widget.doctor.spesialisasi,
                      ).withValues(alpha: 0.2)
                    : const Color(0xFF3B82F6).withValues(alpha: 0.08),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 6 : 3),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
            border: Border.all(
              color: _isHovered
                  ? _getSpecializationColor(
                      widget.doctor.spesialisasi,
                    ).withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Animated background pattern
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _getSpecializationColor(
                            widget.doctor.spesialisasi,
                          ).withValues(alpha: 0.1),
                          _getSpecializationColor(
                            widget.doctor.spesialisasi,
                          ).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildCardContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar with animation
            Hero(
              tag: 'doctor_${widget.doctor.id}',
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getSpecializationColor(
                        widget.doctor.spesialisasi,
                      ).withValues(alpha: 0.2),
                      _getSpecializationColor(
                        widget.doctor.spesialisasi,
                      ).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _getSpecializationColor(
                      widget.doctor.spesialisasi,
                    ).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getSpecializationColor(
                        widget.doctor.spesialisasi,
                      ).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  size: 32,
                  color: _getSpecializationColor(widget.doctor.spesialisasi),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dr. ${widget.doctor.namaLengkap}',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Specialization Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getSpecializationColor(
                            widget.doctor.spesialisasi,
                          ).withValues(alpha: 0.15),
                          _getSpecializationColor(
                            widget.doctor.spesialisasi,
                          ).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getSpecializationColor(
                          widget.doctor.spesialisasi,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSpecializationIcon(widget.doctor.spesialisasi),
                          size: 14,
                          color: _getSpecializationColor(
                            widget.doctor.spesialisasi,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.doctor.spesialisasi,
                          style: TextStyle(
                            fontSize: 13,
                            color: _getSpecializationColor(
                              widget.doctor.spesialisasi,
                            ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ID Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.doctor.nomorIdentifikasi,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Divider
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _getSpecializationColor(
                  widget.doctor.spesialisasi,
                ).withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Contact Info with modern cards
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.phone_rounded,
                text: widget.doctor.nomorTelepon,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactCard(
                icon: Icons.email_rounded,
                text: widget.doctor.email,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Action Buttons with gradient
        Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onEdit,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          const Color(0xFF3B82F6).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Color(0xFF3B82F6),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onDelete,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEF4444).withValues(alpha: 0.1),
                          const Color(0xFFEF4444).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          size: 18,
                          color: Color(0xFFEF4444),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSpecializationIcon(String specialization) {
    switch (specialization.toLowerCase()) {
      case 'umum':
        return Icons.local_hospital_rounded;
      case 'jantung':
        return Icons.favorite_rounded;
      case 'anak':
        return Icons.child_care_rounded;
      case 'mata':
        return Icons.visibility_rounded;
      case 'kulit':
        return Icons.face_rounded;
      case 'gigi':
        return Icons.emoji_emotions_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Color _getSpecializationColor(String specialization) {
    switch (specialization.toLowerCase()) {
      case 'umum':
        return const Color(0xFF3B82F6);
      case 'jantung':
        return const Color(0xFFEF4444);
      case 'anak':
        return const Color(0xFF10B981);
      case 'mata':
        return const Color(0xFFF59E0B);
      case 'kulit':
        return const Color(0xFF8B5CF6);
      case 'gigi':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
