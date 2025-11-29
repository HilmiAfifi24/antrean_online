import 'package:antrean_online/features/admin/doctor_view/data/models/doctor_admin_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorAdminRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  DoctorAdminRemoteDatasource({
    required this.firestore,
    required this.auth,
  });

  // Get all doctors
  Future<List<DoctorAdminModel>> getAllDoctors() async {
    final snapshot = await firestore
        .collection('doctors')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DoctorAdminModel.fromFirestore(doc))
        .toList();
  }

  // Get doctor by ID
  Future<DoctorAdminModel?> getDoctorById(String id) async {
    final doc = await firestore.collection('doctors').doc(id).get();
    if (!doc.exists) return null;
    return DoctorAdminModel.fromFirestore(doc);
  }

  // Add new doctor
  Future<String> addDoctor(DoctorAdminModel doctor, String password) async {
    try {
      // Cek apakah email sudah ada di deleted_accounts (akun yang sudah dihapus)
      final deletedAccountQuery = await firestore
          .collection('deleted_accounts')
          .where('email', isEqualTo: doctor.email)
          .get();
      
      if (deletedAccountQuery.docs.isNotEmpty) {
        // Email pernah dihapus, gunakan user_id yang lama
        final deletedAccount = deletedAccountQuery.docs.first;
        final deletedData = deletedAccount.data();
        final oldUserId = deletedData['user_id'] as String;
        
        // Re-create user document in users collection dengan user_id yang sama
        await firestore.collection('users').doc(oldUserId).set({
          'email': doctor.email,
          'nama_lengkap': doctor.namaLengkap,
          'role': 'dokter',
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
          'reactivated_at': FieldValue.serverTimestamp(),
        });

        final doctorData = doctor.toFirestore();
        doctorData['user_id'] = oldUserId;

        final docRef = await firestore.collection('doctors').add(doctorData);
        
        // Hapus dari deleted_accounts
        await deletedAccount.reference.delete();
        
        // Kirim email reset password
        try {
          await auth.sendPasswordResetEmail(email: doctor.email);
        } catch (e) {
          // Ignore jika gagal kirim email
        }

        await _logActivity(
          title: 'Dokter Ditambahkan (Reaktivasi)',
          subtitle: 'Dr. ${doctor.namaLengkap} telah ditambahkan kembali. Email reset password dikirim ke ${doctor.email}',
          type: 'doctor_reactivated',
        );

        return docRef.id;
      }

      // Email belum pernah digunakan, buat akun baru
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: doctor.email,
        password: password,
      );

      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': doctor.email,
        'nama_lengkap': doctor.namaLengkap,
        'role': 'dokter',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      final doctorData = doctor.toFirestore();
      doctorData['user_id'] = userCredential.user!.uid;

      final docRef = await firestore.collection('doctors').add(doctorData);

      await _logActivity(
        title: 'Dokter Baru Ditambahkan',
        subtitle: 'Dr. ${doctor.namaLengkap} telah ditambahkan ke sistem',
        type: 'doctor_added',
      );

      return docRef.id;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Email masih aktif di Firebase Auth
        // Cek apakah ada di deleted_accounts
        final deletedCheck = await firestore
            .collection('deleted_accounts')
            .where('email', isEqualTo: doctor.email)
            .get();
        
        if (deletedCheck.docs.isNotEmpty) {
          // Akun sudah dihapus tapi masih ada di Firebase Auth
          // Berikan instruksi untuk menggunakan email reset password
          throw Exception(
            'Email ${doctor.email} pernah digunakan sebelumnya. '
            'Akun Firebase Auth masih aktif. Dokter dapat login dengan email reset password yang telah dikirim. '
            'Atau gunakan email berbeda untuk membuat dokter baru.'
          );
        } else {
          // Email digunakan oleh akun aktif lain
          throw Exception(
            'Email ${doctor.email} sudah digunakan oleh akun lain yang masih aktif. '
            'Silakan gunakan email berbeda.'
          );
        }
      }
      throw Exception('Gagal membuat akun: ${e.message}');
    } catch (e) {
      if (e.toString().contains('Email') && e.toString().contains('pernah digunakan')) {
        rethrow;
      }
      throw Exception('Gagal menambahkan dokter: ${e.toString()}');
    }
  }

  // Update doctor
  Future<void> updateDoctor(String id, DoctorAdminModel doctor) async {
    await firestore
        .collection('doctors')
        .doc(id)
        .update(doctor.toFirestoreForUpdate());

    if (doctor.userId.isNotEmpty) {
      await firestore.collection('users').doc(doctor.userId).update({
        'nama_lengkap': doctor.namaLengkap,
        'email': doctor.email,
        'is_active': doctor.isActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    await _logActivity(
      title: 'Data Dokter Diperbarui',
      subtitle: 'Data Dr. ${doctor.namaLengkap} telah diperbarui',
      type: 'doctor_updated',
    );
  }

  // Soft delete doctor (set isActive to false)
  Future<void> deleteDoctor(String id) async {
    final doctor = await getDoctorById(id);
    if (doctor == null) throw Exception('Doctor not found');

    await firestore.collection('doctors').doc(id).update({
      'is_active': false,
      'updated_at': FieldValue.serverTimestamp(),
    });

    if (doctor.userId.isNotEmpty) {
      await firestore.collection('users').doc(doctor.userId).update({
        'is_active': false,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    await _logActivity(
      title: 'Dokter Dinonaktifkan',
      subtitle: 'Dr. ${doctor.namaLengkap} telah dinonaktifkan',
      type: 'doctor_deactivated',
    );
  }

  // Permanently delete doctor with cascade delete (schedules and queues)
  Future<void> permanentlyDeleteDoctor(String id) async {
    final doctor = await getDoctorById(id);
    if (doctor == null) throw Exception('Dokter tidak ditemukan');

    try {
      int totalSchedules = 0;
      int totalQueues = 0;

      // 1. Hapus semua jadwal yang terkait dengan dokter ini (menggunakan userId, bukan document id)
      if (doctor.userId.isNotEmpty) {
        final schedulesSnapshot = await firestore
            .collection('schedules')
            .where('doctor_id', isEqualTo: doctor.userId)
            .get();
        
        totalSchedules = schedulesSnapshot.docs.length;
        
        for (final scheduleDoc in schedulesSnapshot.docs) {
          // Hapus semua antrean yang terkait dengan jadwal ini
          final queuesSnapshot = await firestore
              .collection('queues')
              .where('schedule_id', isEqualTo: scheduleDoc.id)
              .get();
          
          totalQueues += queuesSnapshot.docs.length;
          
          for (final queueDoc in queuesSnapshot.docs) {
            await queueDoc.reference.delete();
          }
          
          // Hapus jadwal
          await scheduleDoc.reference.delete();
        }

        // 2. Hapus juga antrean yang langsung terkait dengan doctor userId
        final doctorQueuesSnapshot = await firestore
            .collection('queues')
            .where('doctor_id', isEqualTo: doctor.userId)
            .get();
        
        totalQueues += doctorQueuesSnapshot.docs.length;
        
        for (final queueDoc in doctorQueuesSnapshot.docs) {
          await queueDoc.reference.delete();
        }
      }

      // 3. Hapus dokumen dokter dari collection doctors
      await firestore.collection('doctors').doc(id).delete();

      // 4. Tandai email di deleted_accounts SEBELUM menghapus user
      if (doctor.userId.isNotEmpty) {
        // Simpan info untuk reaktivasi nanti
        await firestore.collection('deleted_accounts').doc(doctor.userId).set({
          'email': doctor.email,
          'user_id': doctor.userId,
          'deleted_at': FieldValue.serverTimestamp(),
          'doctor_id': id,
          'doctor_name': doctor.namaLengkap,
          'can_reuse': true,
        });
        
        // Hapus dokumen user dari collection users
        await firestore.collection('users').doc(doctor.userId).delete();
      }

      await _logActivity(
        title: 'Dokter Dihapus Permanen',
        subtitle: 'Dr. ${doctor.namaLengkap} beserta $totalSchedules jadwal dan $totalQueues antrean telah dihapus',
        type: 'doctor_permanently_deleted',
      );
    } catch (e) {
      throw Exception('Gagal menghapus dokter: ${e.toString()}');
    }
  }

  // Search doctors by name or specialization
  Future<List<DoctorAdminModel>> searchDoctors(String query) async {
    final snapshot = await firestore.collection('doctors').get();

    final doctors = snapshot.docs
        .map((doc) => DoctorAdminModel.fromFirestore(doc))
        .where((doctor) =>
            doctor.namaLengkap.toLowerCase().contains(query.toLowerCase()) ||
            doctor.spesialisasi.toLowerCase().contains(query.toLowerCase()) ||
            doctor.nomorIdentifikasi
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();

    return doctors;
  }

  // Get doctors by specialization
  Future<List<DoctorAdminModel>> getDoctorsBySpecialization(
      String specialization) async {
    final snapshot = await firestore
        .collection('doctors')
        .where('spesialisasi', isEqualTo: specialization)
        .where('is_active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => DoctorAdminModel.fromFirestore(doc))
        .toList();
  }

  // Get available specializations
  Future<List<String>> getSpecializations() async {
    final snapshot = await firestore.collection('doctors').get();

    final specializations = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final spec = data['spesialisasi'] as String?;
      if (spec != null && spec.isNotEmpty) {
        specializations.add(spec);
      }
    }

    return specializations.toList()..sort();
  }

  // Check if identification number already exists
  Future<bool> isIdentificationNumberExists(String nomorIdentifikasi, {String? excludeDoctorId}) async {
    var query = firestore
        .collection('doctors')
        .where('nomor_identifikasi', isEqualTo: nomorIdentifikasi)
        .where('is_active', isEqualTo: true);

    final snapshot = await query.get();
    
    // Jika ada excludeDoctorId (untuk update), filter out dokter tersebut
    if (excludeDoctorId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeDoctorId);
    }
    
    return snapshot.docs.isNotEmpty;
  }

  // Check if phone number already exists
  Future<bool> isPhoneNumberExists(String nomorTelepon, {String? excludeDoctorId}) async {
    var query = firestore
        .collection('doctors')
        .where('nomor_telepon', isEqualTo: nomorTelepon)
        .where('is_active', isEqualTo: true);

    final snapshot = await query.get();
    
    // Jika ada excludeDoctorId (untuk update), filter out dokter tersebut
    if (excludeDoctorId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeDoctorId);
    }
    
    return snapshot.docs.isNotEmpty;
  }

  // Check if email already exists
  Future<bool> isEmailExists(String email, {String? excludeDoctorId}) async {
    var query = firestore
        .collection('doctors')
        .where('email', isEqualTo: email)
        .where('is_active', isEqualTo: true);

    final snapshot = await query.get();
    
    // Jika ada excludeDoctorId (untuk update), filter out dokter tersebut
    if (excludeDoctorId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeDoctorId);
    }
    
    return snapshot.docs.isNotEmpty;
  }

  // Private: log admin activities
  Future<void> _logActivity({
    required String title,
    required String subtitle,
    required String type,
  }) async {
    await firestore.collection('activities').add({
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
