import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Controllers/admin_controller.dart';
import 'Controllers/auth_controller.dart';
import 'Controllers/cart_controller.dart';
import 'Controllers/password_controller.dart';
import 'Controllers/product_controller.dart';
import 'Screens/Admin/admin_dashboard_screen.dart';
import 'Screens/Admin/admin_orders_screen.dart';
import 'Screens/Admin/admin_products_screen.dart';
import 'Screens/Admin/admin_users_screen.dart';
import 'Screens/Authentication/Views/splash_screen.dart';
import 'Screens/Authentication/login_screen.dart';
import 'Screens/Authentication/signup_screen.dart';
import 'Screens/Home/main_navigation_screen.dart';
import 'Utils/app_theme.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        ChangeNotifierProvider(create: (_) => PasswordController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => CartController()),
      ],
      child: MaterialApp(
        title: 'BabyShop',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => SignupScreen(),
          '/user-home': (_) => const MainNavigationScreen(),
          '/admin-dashboard': (_) => const AdminDashboardScreen(),
          '/admin-products': (_) => const AdminProductsScreen(),
          '/admin-orders': (_) => const AdminOrdersScreen(),
          '/admin-users': (_) => const AdminUsersScreen(),
        },
      ),
    );
  }
}
