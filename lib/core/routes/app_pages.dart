import 'package:antrean_online/core/bindings/initial_binding.dart';
import 'package:antrean_online/features/admin/doctor_view/doctor_admin_binding.dart';
import 'package:antrean_online/features/admin/doctor_view/presentation/pages/doctor_admin_page.dart';
import 'package:antrean_online/features/admin/patient_view/presentation/pages/patient_admin_page.dart';
import 'package:antrean_online/features/admin/patient_view/patient_admin_binding.dart';
import 'package:antrean_online/features/admin/schedule_view/schedule_admin_binding.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/pages/schedule_admin_page.dart';
import 'package:antrean_online/features/admin/home/home_admin_binding.dart';
import 'package:antrean_online/features/auth/presentation/pages/admin_splash_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/doctor_splash_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/patient_splash_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/role_selection_page.dart';
import 'package:get/get.dart';
import 'package:antrean_online/core/routes/app_routes.dart';

// Pages
import 'package:antrean_online/features/auth/presentation/pages/login_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/register_page.dart';
import 'package:antrean_online/features/admin/home/presentation/pages/home_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/admin_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/patient_home_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/doctor_list_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/queue_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/select_schedule_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/booking_form_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/profile_page.dart';
import 'package:antrean_online/features/doctor/presentation/pages/doctor_home_page.dart';

// Bindings
import 'package:antrean_online/features/auth/auth_binding.dart';
import 'package:antrean_online/features/patient/patient_binding.dart';
import 'package:antrean_online/features/patient/doctor_list_binding.dart';
import 'package:antrean_online/features/patient/presentation/bindings/queue_binding.dart';
import 'package:antrean_online/features/doctor/doctor_binding.dart' as doctor_binding;

class AppPages {
  static const initial = AppRoutes.roleSelection;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => RoleSelectionPage(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.patientSplash,
      page: () => PatientSplashPage(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.doctorSplash,
      page: () => DoctorSplashPage(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.adminSplash,
      page: () => AdminSplashPage(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminHomePage(),
      binding: AdminBinding(),
    ),
    GetPage(name: AppRoutes.dokter, page: () => const DokterDashboard()),
    GetPage(
      name: AppRoutes.doctorHome,
      page: () => const DoctorHomePage(),
      binding: doctor_binding.DoctorBinding(),
    ),
    GetPage(
      name: AppRoutes.pasien,
      page: () => const PatientHomePage(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDoctors,
      page: () => const DoctorsPage(),
      binding: DoctorBinding(),
    ),
    GetPage(
      name: AppRoutes.adminSchedules,
      page: () => const SchedulesPage(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: AppRoutes.adminPatients,
      page: () => const PatientAdminPage(),
      binding: PatientAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.doctorList,
      page: () => const DoctorListPage(),
      binding: DoctorListBinding(),
    ),
    GetPage(
      name: AppRoutes.queue,
      page: () => const QueuePage(),
      binding: QueueBinding(),
    ),
    GetPage(
      name: AppRoutes.selectSchedule,
      page: () => const SelectSchedulePage(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingFormPage(),
      binding: QueueBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: PatientBinding(),
    ),
  ];
}
