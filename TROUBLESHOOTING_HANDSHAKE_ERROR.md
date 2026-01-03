# 🔧 Troubleshooting: HandshakeException pada Notifikasi WhatsApp

## ❌ Error Message
```
HandshakeException: Connection terminated during handshake
```

## 📋 Penyebab Error

Error ini terjadi saat aplikasi mencoba berkomunikasi dengan API Fonnte melalui HTTPS, tetapi proses SSL/TLS handshake gagal. Beberapa penyebab umum:

1. **Masalah Koneksi Internet**
   - Koneksi tidak stabil
   - Firewall memblokir koneksi HTTPS
   - Proxy tidak dikonfigurasi dengan benar

2. **Masalah SSL Certificate**
   - Certificate chain tidak lengkap
   - Certificate expired atau tidak valid
   - Bad certificate callback tidak dikonfigurasi

3. **Timeout**
   - Request terlalu lama tanpa response
   - Server tidak merespons dalam waktu yang ditentukan

4. **Platform/Device Issues**
   - Emulator Android dengan proxy settings
   - Device dengan sistem waktu yang salah
   - Network security config yang ketat

## ✅ Solusi yang Telah Diterapkan

### 1. **Enhanced Error Handling**
Menambahkan try-catch yang lebih spesifik di `notification_remote_datasource.dart`:

```dart
try {
  // Send request
} on SocketException catch (e) {
  throw Exception('Tidak dapat terhubung ke server Fonnte: ${e.message}');
} on HandshakeException catch (e) {
  throw Exception('SSL Handshake gagal: ${e.message}. Periksa koneksi internet atau gunakan jaringan berbeda');
} on http.ClientException catch (e) {
  throw Exception('HTTP Client error: ${e.message}');
}
```

### 2. **Request Timeout**
Menambahkan timeout 30 detik untuk mencegah request hang:

```dart
final response = await client.post(url, ...).timeout(
  const Duration(seconds: 30),
  onTimeout: () {
    throw Exception('Request timeout: Server tidak merespons dalam 30 detik');
  },
);
```

### 3. **Custom HTTP Client dengan SSL Handling**
Mengkonfigurasi `IOClient` dengan bad certificate callback di `notification_binding.dart`:

```dart
final httpClient = HttpClient()
  ..connectionTimeout = const Duration(seconds: 30)
  ..badCertificateCallback = (X509Certificate cert, String host, int port) {
    // Only accept certificates from fonnte.com
    return host == 'api.fonnte.com';
  };

final client = IOClient(httpClient);
```

## 🔍 Cara Debugging

### 1. **Cek Koneksi Internet**
```dart
// Test koneksi ke Google
try {
  final result = await InternetAddress.lookup('google.com');
  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    print('✅ Internet connected');
  }
} catch (e) {
  print('❌ No internet connection');
}
```

### 2. **Test API Fonnte Manual**
```bash
curl -X POST https://api.fonnte.com/send \
  -H "Authorization: YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "target": "628123456789",
    "message": "Test message"
  }'
```

### 3. **Cek Firestore Logs**
Lihat collection `notifications` di Firebase Console untuk melihat error_message yang tersimpan.

## 🛠️ Solusi Alternatif Jika Masih Error

### Opsi 1: Gunakan Jaringan Berbeda
- Switch dari WiFi ke Mobile Data atau sebaliknya
- Coba gunakan VPN jika ada blocking dari ISP
- Test di device fisik daripada emulator

### Opsi 2: Update AndroidManifest.xml
Tambahkan permission dan network config di `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
  
  <application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config">
    ...
  </application>
</manifest>
```

Buat file `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">api.fonnte.com</domain>
    </domain-config>
</network-security-config>
```

### Opsi 3: Disable SSL Verification (HANYA UNTUK DEVELOPMENT)

**⚠️ PERINGATAN: Jangan gunakan di production!**

```dart
final httpClient = HttpClient()
  ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
```

### Opsi 4: Retry Mechanism
Tambahkan retry logic untuk request yang gagal:

```dart
Future<void> sendWithRetry(String phone, String message, {int maxRetries = 3}) async {
  int attempt = 0;
  while (attempt < maxRetries) {
    try {
      await sendWhatsAppMessage(phone, message);
      return; // Success
    } catch (e) {
      attempt++;
      if (attempt >= maxRetries) rethrow;
      await Future.delayed(Duration(seconds: 2 * attempt)); // Exponential backoff
    }
  }
}
```

## 📊 Monitoring & Logs

### Cek Status Notifikasi di Firestore:
```dart
// Get all failed notifications
final failedNotifications = await firestore
    .collection('notifications')
    .where('is_sent', isEqualTo: false)
    .where('error_message', isNotEqualTo: null)
    .get();

for (var doc in failedNotifications.docs) {
  print('Failed: ${doc.data()['error_message']}');
}
```

### Enable Debug Logging:
Uncomment print statements di `notification_remote_datasource.dart`:
```dart
print('Sending WhatsApp to: $formattedPhone');
print('Fonnte Response: ${response.statusCode} - ${response.body}');
```

## 🎯 Best Practices

1. ✅ Selalu handle timeout dengan duration yang wajar (30s)
2. ✅ Catch specific exceptions (HandshakeException, SocketException)
3. ✅ Save error messages ke Firestore untuk monitoring
4. ✅ Implementasi retry mechanism untuk network failures
5. ✅ Test di berbagai network conditions (WiFi, 4G, 5G)
6. ✅ Log semua error untuk debugging
7. ✅ Validasi phone number format sebelum kirim

## 🔗 Resources

- [Fonnte API Documentation](https://fonnte.com/api)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [Dart IO Documentation](https://api.dart.dev/stable/dart-io/dart-io-library.html)
- [SSL Certificate Pinning](https://docs.flutter.dev/development/data-and-backend/networking#ssl-certificate-verification)

## 📝 Changelog

### v1.1 (20 Dec 2025)
- ✅ Added specific exception handling (HandshakeException, SocketException)
- ✅ Added request timeout (30 seconds)
- ✅ Configured custom IOClient with SSL handling
- ✅ Added badCertificateCallback for api.fonnte.com
- ✅ Improved error messages untuk user
