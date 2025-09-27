class AppRoutes {
  // static const initial = login;

  // Auth
  static const login = '/login';
  static const register = '/register';

  // Admin
  static const admin = '/admin';
  static const adminDoctors = '/admin/doctors';
  static const adminSchedules = '/admin/schedules';

  // Dokter
  static const dokter = '/dokter';

  // Pasien
  static const pasien = '/pasien';

  // splash routes for each roles
  static const adminSplash = '/admin/splash';
  static const doctorSplash = '/doctor/splash';
  static const patientSplash = '/patient/splash';
  static const roleSelection = '/role-selection';
}
