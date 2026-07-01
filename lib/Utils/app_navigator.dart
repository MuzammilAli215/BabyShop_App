import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/auth_controller.dart';
import '../Screens/Admin/admin_dashboard_screen.dart';
import '../Screens/Admin/admin_products_screen.dart';
import '../Screens/Admin/admin_orders_screen.dart';
import '../Screens/Admin/admin_users_screen.dart';

class AppNavigator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case '/admin-products':
        return MaterialPageRoute(builder: (_) => const AdminProductsScreen());
      case '/admin-orders':
        return MaterialPageRoute(builder: (_) => const AdminOrdersScreen());
      case '/admin-users':
        return MaterialPageRoute(builder: (_) => const AdminUsersScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}

class RoleBasedNavigator extends StatelessWidget {
  const RoleBasedNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        // Check if user is logged in
        if (authController.user == null) {
          // User not logged in - navigate to login screen
          return const LoginPlaceholder();
        }

        // Check if user is disabled
        return FutureBuilder<bool>(
          future: authController.isUserDisabled(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.data == true) {
              // User is disabled
              return const DisabledUserScreen();
            }

            // User is logged in and not disabled
            if (authController.isAdmin) {
              // Admin user - show admin dashboard
              return AdminDashboardScreen();
            } else {
              // Regular user - show user home screen
              return const UserPlaceholder();
            }
          },
        );
      },
    );
  }
}

// Placeholder for login screen (replace with your actual login screen)
class LoginPlaceholder extends StatelessWidget {
  const LoginPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to login screen
            // Navigator.pushNamed(context, '/login');
          },
          child: const Text('Go to Login'),
        ),
      ),
    );
  }
}

// Placeholder for user home screen (replace with your actual user home screen)
class UserPlaceholder extends StatelessWidget {
  const UserPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to User Home'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthController>().logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// Disabled user screen
class DisabledUserScreen extends StatelessWidget {
  const DisabledUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 20),
            Text(
              'Account Disabled',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your account has been disabled by the administrator.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () {
                context.read<AuthController>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
