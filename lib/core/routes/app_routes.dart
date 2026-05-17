class AppRoutes {
  // static const initial = login;

  // Auth
  static const login = '/login';
  static const register = '/register';

  // Admin
  static const admin = '/admin';
  static const adminDoctors = '/admin/doctors';
  static const adminSchedules = '/admin/schedules';
  static const adminPatients = '/admin/patients';
  static const adminQueues = '/admin/queues';
  static const adminPatientList = '/admin/patient-list';
  static const adminScheduleChangeRequests = '/admin/schedule-change-requests';

  // Dokter
  static const dokter = '/dokter';
  static const doctorHome = '/doctor/home';
  static const doctorHistory = '/doctor/history';
  static const doctorScheduleChange = '/doctor/schedule-change';
  static const doctorSessionCancellation = '/doctor/session-cancellation';

  // Pasien
  static const pasien = '/pasien';
  static const doctorList = '/patient/doctors';
  static const doctorDetail = '/patient/doctor-detail';
  static const queue = '/patient/queue';
  static const queueDetail = '/patient/queue-detail';
  static const queueHistory = '/patient/queue-history';
  static const patientReschedule = '/patient/reschedule';
  static const selectSchedule = '/patient/select-schedule';
  static const booking = '/patient/booking';
  static const profile = '/patient/profile';

  // splash routes for each roles
  static const adminSplash = '/admin/splash';
  static const doctorSplash = '/doctor/splash';
  static const patientSplash = '/patient/splash';
  static const roleSelection = '/role-selection';
}
