import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_eproject/Controllers/auth_controller.dart';
import 'package:flutter_eproject/Utils/app_theme.dart';
import 'lib/Screens/Authentication/Views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Uncomment when Firebase is set up
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController()..checkAuthStatus(),
        ),
        // Add AdminController here when needed
        // ChangeNotifierProvider(create: (_) => AdminController()),
      ],
      child: MaterialApp(
        title: 'BabyShop',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
