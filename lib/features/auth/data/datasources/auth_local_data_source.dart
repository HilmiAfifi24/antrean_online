import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> saveCredentials(String email, String password);
  Future<Map<String, String>?> getSavedCredentials();
  Future<void> clearCredentials();
  Future<bool> hasRememberedCredentials();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _keyEmail = 'remembered_email';
  static const String _keyPassword = 'remembered_password';
  static const String _keyRememberMe = 'remember_me';
  
  // Simple encryption key (in production, use more secure method)
  static const String _encryptionKey = 'klinik_pens_2024_secret_key';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  /// Encrypt password menggunakan simple XOR encryption dengan base64
  /// Untuk production, gunakan package seperti flutter_secure_storage atau encrypt
  String _encryptPassword(String password) {
    final key = _encryptionKey;
    final encrypted = <int>[];
    
    for (int i = 0; i < password.length; i++) {
      final char = password.codeUnitAt(i);
      final keyChar = key.codeUnitAt(i % key.length);
      encrypted.add(char ^ keyChar);
    }
    
    return base64.encode(encrypted);
  }

  /// Decrypt password dari XOR encryption
  String _decryptPassword(String encrypted) {
    try {
      final decoded = base64.decode(encrypted);
      final key = _encryptionKey;
      final decrypted = <int>[];
      
      for (int i = 0; i < decoded.length; i++) {
        final byte = decoded[i];
        final keyChar = key.codeUnitAt(i % key.length);
        decrypted.add(byte ^ keyChar);
      }
      
      return String.fromCharCodes(decrypted);
    } catch (e) {
      return '';
    }
  }

  @override
  Future<void> saveCredentials(String email, String password) async {
    try {
      // Enkripsi password sebelum disimpan
      final encryptedPassword = _encryptPassword(password);
      
      await sharedPreferences.setString(_keyEmail, email);
      await sharedPreferences.setString(_keyPassword, encryptedPassword);
      await sharedPreferences.setBool(_keyRememberMe, true);
    } catch (e) {
      throw Exception('Gagal menyimpan kredensial: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final rememberMe = sharedPreferences.getBool(_keyRememberMe) ?? false;
      
      if (!rememberMe) {
        return null;
      }

      final email = sharedPreferences.getString(_keyEmail);
      final encryptedPassword = sharedPreferences.getString(_keyPassword);

      if (email == null || encryptedPassword == null) {
        return null;
      }

      // Decrypt password untuk digunakan login
      final decryptedPassword = _decryptPassword(encryptedPassword);

      return {
        'email': email,
        'password': decryptedPassword,
      };
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      await sharedPreferences.remove(_keyEmail);
      await sharedPreferences.remove(_keyPassword);
      await sharedPreferences.remove(_keyRememberMe);
    } catch (e) {
      throw Exception('Gagal menghapus kredensial: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasRememberedCredentials() async {
    try {
      final rememberMe = sharedPreferences.getBool(_keyRememberMe) ?? false;
      final email = sharedPreferences.getString(_keyEmail);
      final password = sharedPreferences.getString(_keyPassword);
      
      return rememberMe && email != null && password != null;
    } catch (e) {
      return false;
    }
  }
}
