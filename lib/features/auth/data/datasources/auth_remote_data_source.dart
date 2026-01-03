import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource(this.firebaseAuth, this.firestore);

  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      if(!email.endsWith("@pens.ac.id")) {
        await firebaseAuth.signOut();
        throw Exception("Email harus menggunakan domain @pens.ac.id");
      }

      final doc = await firestore.collection("users").doc(uid).get();
      
      if (!doc.exists) {
        await firebaseAuth.signOut();
        throw Exception("Data pengguna tidak ditemukan");
      }
      
      return UserModel.fromFirestore(doc.data()!, uid);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar. Silakan periksa kembali email Anda');
        case 'wrong-password':
          throw Exception('Password salah. Silakan periksa kembali password Anda');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'user-disabled':
          throw Exception('Akun Anda telah dinonaktifkan. Hubungi administrator');
        case 'invalid-credential':
          throw Exception('Email atau password salah. Silakan periksa kembali kredensial Anda');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan login. Silakan coba lagi nanti');
        default:
          throw Exception('Login gagal: ${e.message ?? "Terjadi kesalahan"}');
      }
    } catch (e) {
      if (e.toString().contains('@pens.ac.id')) {
        rethrow;
      }
      throw Exception('Login gagal: ${e.toString()}');
    }
  }

  Future<UserModel> register(String email, String password, String role, String name, String phone) async {
    try {
      if (!email.endsWith("@pens.ac.id")) {
        throw Exception("Email harus menggunakan domain @pens.ac.id");
      }
      
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final userModel = UserModel(uid: uid, email: email, role: role);
      
      // Save user data with name and phone to Firestore
      await firestore.collection("users").doc(uid).set({
        ...userModel.toMap(),
        'name': name,
        'phone': phone,
        'created_at': FieldValue.serverTimestamp(),
      });
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email sudah terdaftar. Silakan gunakan email lain atau login');
        case 'weak-password':
          throw Exception('Password terlalu lemah. Gunakan minimal 6 karakter');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'operation-not-allowed':
          throw Exception('Registrasi tidak diizinkan. Hubungi administrator');
        default:
          throw Exception('Registrasi gagal: ${e.message ?? "Terjadi kesalahan"}');
      }
    } catch (e) {
      if (e.toString().contains('@pens.ac.id')) {
        rethrow;
      }
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      if (!email.endsWith('@pens.ac.id')) {
        throw Exception('Email harus menggunakan domain @pens.ac.id');
      }

      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar dalam sistem');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan. Silakan coba lagi nanti');
        default:
          throw Exception('Gagal mengirim email reset password: ${e.message ?? "Terjadi kesalahan"}');
      }
    } catch (e) {
      if (e.toString().contains('@pens.ac.id')) {
        rethrow;
      }
      throw Exception('Gagal mengirim email reset password: ${e.toString()}');
    }
  }
}
