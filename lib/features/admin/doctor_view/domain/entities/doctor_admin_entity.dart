class DoctorAdminEntity {
  final String id;
  final String userId;
  final String namaLengkap;
  final String nomorIdentifikasi;
  final String spesialisasi;
  final String nomorTelepon;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DoctorAdminEntity({
    required this.id,
    required this.userId,
    required this.namaLengkap,
    required this.nomorIdentifikasi,
    required this.spesialisasi,
    required this.nomorTelepon,
    required this.email,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  DoctorAdminEntity copyWith({
    String? id,
    String? userId,
    String? namaLengkap,
    String? nomorIdentifikasi,
    String? spesialisasi,
    String? nomorTelepon,
    String? email,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorAdminEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nomorIdentifikasi: nomorIdentifikasi ?? this.nomorIdentifikasi,
      spesialisasi: spesialisasi ?? this.spesialisasi,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}