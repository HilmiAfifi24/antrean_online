// features/admin/doctors/data/models/doctor_model.dart
import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAdminModel extends DoctorAdminEntity {
  const DoctorAdminModel({
    required super.id,
    required super.userId,
    required super.namaLengkap,
    required super.nomorIdentifikasi,
    required super.spesialisasi,
    required super.nomorTelepon,
    required super.email,
    required super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory DoctorAdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return DoctorAdminModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      namaLengkap: data['nama_lengkap'] ?? '',
      nomorIdentifikasi: data['nomor_identifikasi'] ?? '',
      spesialisasi: data['spesialisasi'] ?? '',
      nomorTelepon: data['nomor_telepon'] ?? '',
      email: data['email'] ?? '',
      isActive: data['is_active'] ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'nama_lengkap': namaLengkap,
      'nomor_identifikasi': nomorIdentifikasi,
      'spesialisasi': spesialisasi,
      'nomor_telepon': nomorTelepon,
      'email': email,
      'is_active': isActive,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreForUpdate() {
    return {
      'user_id': userId,
      'nama_lengkap': namaLengkap,
      'nomor_identifikasi': nomorIdentifikasi,
      'spesialisasi': spesialisasi,
      'nomor_telepon': nomorTelepon,
      'email': email,
      'is_active': isActive,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory DoctorAdminModel.fromEntity(DoctorAdminEntity doctor) {
    return DoctorAdminModel(
      id: doctor.id,
      userId: doctor.userId,
      namaLengkap: doctor.namaLengkap,
      nomorIdentifikasi: doctor.nomorIdentifikasi,
      spesialisasi: doctor.spesialisasi,
      nomorTelepon: doctor.nomorTelepon,
      email: doctor.email,
      isActive: doctor.isActive,
      createdAt: doctor.createdAt,
      updatedAt: doctor.updatedAt,
    );
  }

  @override
  DoctorAdminModel copyWith({
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
    return DoctorAdminModel(
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