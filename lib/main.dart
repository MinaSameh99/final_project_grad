// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/admin_screens/admin_homepage.dart';
import 'package:sams/admin_screens/admin_profile.dart';
import 'package:sams/admin_screens/admin_student_approval.dart';
import 'package:sams/admin_screens/manage_courses_screen.dart';
import 'package:sams/admin_screens/students_manage.dart';
import 'package:sams/services/api.dart';
import 'package:sams/doctor_screens/docotor_home_screen.dart';
import 'package:sams/doctor_screens/doctor_info_screen.dart';
import 'package:sams/doctor_screens/doctor_profile_screen.dart';
import 'package:sams/doctor_screens/doctor_schedule_screen.dart';
import 'package:sams/doctor_screens/doctor_students_screen.dart';
import 'package:sams/login_screen.dart';
import 'package:sams/logo_screen.dart';
import 'package:sams/provider/admin_doctors_provider.dart';
import 'package:sams/provider/admin_provider.dart';
import 'package:sams/provider/admin_students_provider.dart';
import 'package:sams/provider/doctor_provider.dart';
import 'package:sams/provider/notification_provider.dart';
import 'package:sams/provider/user_provider.dart';
import 'package:sams/signup_screen.dart';
import 'package:sams/student_screens/card_payment.dart';
import 'package:sams/student_screens/home_screen.dart';
import 'package:sams/student_screens/profile_screen.dart';
import 'package:sams/student_screens/schedule_screen.dart';
import 'package:sams/student_screens/student_info_screen.dart';
import 'package:sams/student_screens/wallet_payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String initialRoute = '/logo';

  if (await ApiService.isLoggedIn()) {
    final role = await ApiService.getRole();
    switch (role) {
      case 'student': initialRoute = '/home';     break;
      case 'advisor': initialRoute = '/dochome';  break;
      case 'admin':   initialRoute = '/adminhome'; break;
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AdminStudentsProvider()),
        ChangeNotifierProvider(create: (_) => AdminDoctorsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/logo':        (_) => const LogoScreen(),
        '/login':       (_) => const LoginScreen(),
        '/signup':      (_) => const SignupScreen(),

        // ── Student ──────────────────────────────────────────────────────
        '/studentinfo':  (_) => const StudentInfoScreen(),
        '/home':         (_) => const HomeScreen(),
        '/schedule':     (_) => const ScheduleScreen(),
        '/profile':      (_) => const ProfileScreen(),
        '/cardpayment':  (_) => const CardPaymentPage(),
        '/walletpayment':(_) => const WalletPaymentPage(),

        // ── Doctor / Advisor ─────────────────────────────────────────────
        '/docinfo':      (_) => const DoctorInfoScreen(),
        '/dochome':      (_) => const DocotorHomeScreen(),
        '/docschedule':  (_) => const DoctorScheduleScreen(),
        '/docprofile':   (_) => const DoctorProfileScreen(),
        '/docstudents':  (_) => const DoctorStudentsScreen(),

        // ── Admin ────────────────────────────────────────────────────────
        '/adminhome':        (_) => const AdminHomePage(),
        '/adminprofile':     (_) => const AdminProfileScreen(),
        '/manageStudents':   (_) => const StudentsManageScreen(),
        '/approveStudents':  (_) => const AdminStudentApprovalScreen(),
        '/manageCourses':    (_) => const ManageCoursesScreen(),
      },
    );
  }
}