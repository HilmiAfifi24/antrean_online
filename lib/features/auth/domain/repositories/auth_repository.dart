import 'package:antrean_online/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password, String role, String name, String phone);
  Future<void> logout();
  Future<void> resetPassword(String email);
  
  // Remember Me functionality
  Future<void> saveCredentials(String email, String password);
  Future<Map<String, String>?> getSavedCredentials();
  Future<void> clearCredentials();
  Future<bool> hasRememberedCredentials();
}