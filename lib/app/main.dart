import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/routes/screens/login.dart';
import 'package:gradution_project/app/routes/screens/splash.dart';
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
      
      
      initialRoute: '/splash_screen',      
      
      getPages: [ 
          GetPage(name: '/splash_screen', page: () => SplashScreen()),
          GetPage(name: '/login_screen', page: () => LoginScreen()),

      ]   
    );
  }
}