  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:flutter_eproject/Controllers/auth_controller.dart';
  import 'Controllers/admin_controller.dart';
import 'Utils/app_navigator.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()..checkAuthStatus()),
          ChangeNotifierProvider(create: (_) => AdminController()),
        ],
        child: MaterialApp(
          title: 'BabyShop',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const RoleBasedNavigator(),
          onGenerateRoute: AppNavigator.generateRoute,
        ),
      );
    }
  }
