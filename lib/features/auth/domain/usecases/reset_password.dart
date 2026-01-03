import '../repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<void> call(String email) async {
    if (email.trim().isEmpty) {
      throw Exception('Email tidak boleh kosong');
    }

    if (!email.contains('@')) {
      throw Exception('Format email tidak valid');
    }

    if (!email.endsWith('@pens.ac.id')) {
      throw Exception('Email harus menggunakan domain @pens.ac.id');
    }

    return await repository.resetPassword(email);
  }
}
