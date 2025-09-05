import 'package:antrean_online/features/admin/home/presentation/pages/home_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/admin_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/login_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/register_page.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/register', page: () => const RegisterPage()),
    GetPage(name: '/admin', page: () => const AdminHomePage()),
    GetPage(name: '/dokter', page: () => const DokterDashboard()),
    GetPage(name: '/pasien', page: () => const PasienDashboard()), 
  ];
}
