import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/auth_controller.dart';
import 'package:gradution_project/app/views/instructor_login_view.dart';
import 'package:gradution_project/app/views/register_view.dart';
import 'package:gradution_project/app/views/student_login_view.dart';

import 'package:supabase_flutter/supabase_flutter.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fnquuvxprieyvpmlyfzb.supabase.co',
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZucXV1dnhwcmlleXZwbWx5ZnpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMDQ5MzMsImV4cCI6MjA3NTg4MDkzM30.5t0KAiiY_QhH4wdcAYf52BxqWflIfy7jRcRuWnZCbHE',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      
      
      initialRoute: '/login',      
      
      getPages: [
        GetPage(
          name: '/login',
          page: () => const StudentLoginView(),
          binding: BindingsBuilder(() {
            Get.put(AuthController()); // Loads controller for everyone
          }),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterView(),
          binding: BindingsBuilder(() {
            Get.put(AuthController()); // Loads controller for everyone
          }),
        ),
        GetPage(
          name: '/instructor-login',
          page: () => const InstructorLoginView(),
          binding: BindingsBuilder(() {
            Get.put(AuthController()); // Loads controller for everyone
          }),
        ),
      ],

         
    );
  }
}