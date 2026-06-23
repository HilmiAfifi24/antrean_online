# antrean_online

A new Flutter project.

## Firebase Seed

Seed data untuk `Authentication`, `users`, `doctors`, `doctors_public`, dan `schedules` ada di folder `functions/`.

Jalankan dari folder `functions`:

```bash
npm run seed
```

Script ini memakai Firebase Admin SDK. Pastikan salah satu ini sudah tersedia:

- `GOOGLE_APPLICATION_CREDENTIALS` mengarah ke service account JSON
- atau Anda sudah menjalankan `gcloud auth application-default login`
- atau set `FIREBASE_SERVICE_ACCOUNT_KEY` berisi isi JSON service account

Project ID diambil dari `.firebaserc` atau env `FIREBASE_PROJECT_ID`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
