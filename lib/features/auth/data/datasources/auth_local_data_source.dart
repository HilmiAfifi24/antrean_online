import 'package:shared_preferences/shared_preferences.dart';
import 'auth_storage_keys.dart';

abstract class AuthLocalDataSource {
  Future<void> saveCredentials(String email, String password);
  Future<Map<String, String>?> getSavedCredentials();
  Future<void> clearCredentials();
  Future<bool> hasRememberedCredentials();
  Future<void> saveCurrentRole(String role);
  Future<String?> getCurrentRole();
  Future<void> clearCurrentRole();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> saveCredentials(String email, String password) async {
    try {
      await sharedPreferences.setString(AuthStorageKeys.rememberedEmail, email);
      await sharedPreferences.remove(AuthStorageKeys.rememberedPassword);
      await sharedPreferences.setBool(AuthStorageKeys.rememberMe, true);
    } catch (e) {
      throw Exception('Gagal menyimpan kredensial: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final rememberMe = sharedPreferences.getBool(AuthStorageKeys.rememberMe) ?? false;
      
      if (!rememberMe) {
        return null;
      }

      final email = sharedPreferences.getString(AuthStorageKeys.rememberedEmail);

      if (email == null) {
        return null;
      }

      return {
        'email': email,
        'password': '',
      };
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      await sharedPreferences.remove(AuthStorageKeys.rememberedEmail);
      await sharedPreferences.remove(AuthStorageKeys.rememberedPassword);
      await sharedPreferences.remove(AuthStorageKeys.rememberMe);
    } catch (e) {
      throw Exception('Gagal menghapus kredensial: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasRememberedCredentials() async {
    try {
      final rememberMe = sharedPreferences.getBool(AuthStorageKeys.rememberMe) ?? false;
      final email = sharedPreferences.getString(AuthStorageKeys.rememberedEmail);
      
      return rememberMe && email != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveCurrentRole(String role) async {
    try {
      await sharedPreferences.setString(AuthStorageKeys.currentUserRole, role);
    } catch (e) {
      throw Exception('Gagal menyimpan role sesi: ${e.toString()}');
    }
  }

  @override
  Future<String?> getCurrentRole() async {
    try {
      return sharedPreferences.getString(AuthStorageKeys.currentUserRole);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCurrentRole() async {
    try {
      await sharedPreferences.remove(AuthStorageKeys.currentUserRole);
    } catch (e) {
      throw Exception('Gagal menghapus role sesi: ${e.toString()}');
    }
  }
}
