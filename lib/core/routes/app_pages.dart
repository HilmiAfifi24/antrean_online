import 'package:antrean_online/core/bindings/initial_binding.dart';
import 'package:antrean_online/core/middleware/admin_route_middleware.dart';
import 'package:antrean_online/core/middleware/doctor_route_middleware.dart';
import 'package:antrean_online/core/middleware/patient_route_middleware.dart';
import 'package:antrean_online/features/admin/doctor_view/doctor_admin_binding.dart';
import 'package:antrean_online/features/admin/doctor_view/presentation/pages/doctor_admin_page.dart';
import 'package:antrean_online/features/admin/patient_view/presentation/pages/patient_admin_page.dart';
import 'package:antrean_online/features/admin/patient_view/patient_admin_binding.dart';
import 'package:antrean_online/features/admin/schedule_view/schedule_admin_binding.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/pages/schedule_admin_page.dart';
import 'package:antrean_online/features/admin/home/home_admin_binding.dart';
import 'package:antrean_online/features/admin/queue_view/queue_view_binding.dart';
import 'package:antrean_online/features/admin/queue_view/presentation/pages/queue_view_page.dart';
import 'package:antrean_online/features/admin/patient_list_view/presentation/bindings/patient_list_view_binding.dart';
import 'package:antrean_online/features/admin/patient_list_view/presentation/pages/patient_list_view_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/admin_splash_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/doctor_splash_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/patient_splash_page.dart';
import 'package:antrean_online/features/auth/presentation/pages/role_selection_page.dart';
import 'package:antrean_online/features/doctor/presentation/bindings/doctor_history_binding.dart';
import 'package:antrean_online/features/doctor/presentation/bindings/schedule_change_binding.dart';
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
import 'package:antrean_online/features/patient/presentation/pages/queue_detail_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/queue_history_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/patient_reschedule_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/select_schedule_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/booking_form_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/profile_page.dart';
import 'package:antrean_online/features/doctor/presentation/pages/doctor_home_page.dart';
import 'package:antrean_online/features/doctor/presentation/pages/doctor_history_page.dart';
import 'package:antrean_online/features/doctor/presentation/pages/doctor_session_cancellation_page.dart';
import 'package:antrean_online/features/doctor/presentation/pages/schedule_change_request_page.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/pages/admin_schedule_change_request_page.dart';

// Bindings
import 'package:antrean_online/features/auth/auth_binding.dart';
import 'package:antrean_online/features/patient/patient_binding.dart';
import 'package:antrean_online/features/patient/doctor_list_binding.dart';
import 'package:antrean_online/features/patient/doctor_detail_binding.dart';
import 'package:antrean_online/features/doctor/doctor_binding.dart'
    as doctor_binding;
import 'package:antrean_online/features/patient/presentation/bindings/queue_history_binding.dart';
import 'package:antrean_online/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:antrean_online/features/patient/presentation/pages/doctor_detail_page.dart';

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
      middlewares: [AdminRouteMiddleware()],
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
      name: '/forgot-password',
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminHomePage(),
      binding: AdminBinding(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dokter,
      page: () => const DokterDashboard(),
      binding: doctor_binding.DoctorBinding(),
      middlewares: [DoctorRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.doctorHome,
      page: () => const DoctorHomePage(),
      binding: doctor_binding.DoctorBinding(),
      middlewares: [DoctorRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.doctorHistory,
      page: () => const DoctorHistoryPage(),
      binding: DoctorHistoryBinding(),
      middlewares: [DoctorRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.doctorScheduleChange,
      page: () => const ScheduleChangeRequestPage(),
      binding: ScheduleChangeBinding(),
      middlewares: [DoctorRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.doctorSessionCancellation,
      page: () => const DoctorSessionCancellationPage(),
      binding: doctor_binding.DoctorBinding(),
      middlewares: [DoctorRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.pasien,
      page: () => const PatientHomePage(),
      binding: PatientBinding(),
      middlewares: [PatientRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminDoctors,
      page: () => const DoctorsPage(),
      binding: DoctorBinding(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminSchedules,
      page: () => const SchedulesPage(),
      binding: ScheduleBinding(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminPatients,
      page: () => const PatientAdminPage(),
      binding: PatientAdminBinding(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminQueues,
      page: () => const QueueViewPage(),
      binding: QueueViewBinding(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminPatientList,
      page: () => const PatientListViewPage(),
      binding: PatientListViewBinding(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminScheduleChangeRequests,
      page: () => const AdminScheduleChangeRequestPage(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.doctorList,
      page: () => const DoctorListPage(),
      binding: DoctorListBinding(),
    ),
    GetPage(
      name: AppRoutes.doctorDetail,
      page: () => const DoctorDetailPage(),
      binding: DoctorDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.queue,
      page: () => const QueuePage(),
      middlewares: [PatientRouteMiddleware()],
      // Inherits QueueController from PatientBinding globally
    ),
    GetPage(
      name: AppRoutes.queueDetail,
      page: () => const QueueDetailPage(),
      middlewares: [PatientRouteMiddleware()],
      // Inherits QueueController & PatientQueueRepository from PatientBinding globally
    ),
    GetPage(
      name: AppRoutes.queueHistory,
      page: () => const QueueHistoryPage(),
      binding: QueueHistoryBinding(),
      middlewares: [PatientRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.patientReschedule,
      page: () => const PatientReschedulePage(),
      middlewares: [PatientRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.selectSchedule,
      page: () => const SelectSchedulePage(),
      binding: PatientBinding(),
      middlewares: [PatientRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingFormPage(),
      middlewares: [PatientRouteMiddleware()],
      // Inherits QueueController from PatientBinding globally
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: PatientBinding(),
      middlewares: [PatientRouteMiddleware()],
    ),
  ];
}
