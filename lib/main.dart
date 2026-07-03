import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/employee_viewmodel.dart';
import 'viewmodels/feedback_viewmodel.dart';
import 'viewmodels/recognition_viewmodel.dart';

import 'views/login_screen.dart';
import 'views/dashboard_screen.dart';
import 'views/employee_list_screen.dart';
import 'views/employee_profile_screen.dart';
import 'views/employee_form_screen.dart';
import 'views/feedback_screen.dart';
import 'views/recognitions_screen.dart';
import 'views/departments_screen.dart';

void main() {
  runApp(const RhApp());
}

class RhApp extends StatelessWidget {
  const RhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => EmployeeViewModel()),
        ChangeNotifierProvider(create: (_) => FeedbackViewModel()),
        ChangeNotifierProvider(create: (_) => RecognitionViewModel()),
      ],
      child: MaterialApp(
        title: 'RH App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
          ),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/employees': (_) => const EmployeeListScreen(),
          '/employee-profile': (_) => const EmployeeProfileScreen(),
          '/employee-form': (_) => const EmployeeFormScreen(),
          '/feedbacks': (_) => const FeedbackScreen(),
          '/recognitions': (_) => const RecognitionsScreen(),
          '/departments': (_) => const DepartmentsScreen(),
        },
      ),
    );
  }
}
