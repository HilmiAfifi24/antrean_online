import 'package:antrean_online/features/admin/doctor_view/doctor_admin_binding.dart';
import 'package:antrean_online/features/admin/doctor_view/presentation/pages/doctor_admin_page.dart';
import 'package:antrean_online/features/admin/schedule_view/schedule_admin_binding.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/pages/schedule_admin_page.dart';
import 'package:antrean_online/features/admin/home/home_admin_binding.dart';
import 'package:get/get.dart';
import 'package:antrean_online/core/routes/app_routes.dart';

// Pages
import 'package:antrean_online/features/auth/presentation/pages/login_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/register_page.dart';
import 'package:antrean_online/features/admin/home/presentation/pages/home_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/admin_page.dart';

// Bindings
import 'package:antrean_online/features/auth/auth_binding.dart';

class AppPages {
  static final routes = <GetPage>[
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
    GetPage(name: AppRoutes.pasien, page: () => const PasienDashboard()),
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
  ];
}
