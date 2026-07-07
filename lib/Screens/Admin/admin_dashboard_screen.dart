import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/admin_controller.dart';
import '../../Controllers/auth_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminController>().loadAllAdminData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF3B6FF6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirm(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<AdminController>(
        builder: (context, adminController, _) {
          final stats = adminController.dashboardStats;

          if (stats == null && adminController.error == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async => adminController.loadAllAdminData(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHero(context, adminController),
                if (adminController.error != null)
                  _buildErrorBanner(adminController.error!),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 720;
                          return GridView.count(
                            crossAxisCount: isWide ? 4 : 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: isWide ? 1.45 : 1.12,
                            children: [
                              _buildStatCard('Users', '${stats?.totalUsers ?? 0}',
                                  Icons.people_alt, const Color(0xFF3B6FF6)),
                              _buildStatCard('Orders', '${stats?.totalOrders ?? 0}',
                                  Icons.receipt_long, const Color(0xFF11A36A)),
                              _buildStatCard('Products',
                                  '${stats?.totalProducts ?? 0}',
                                  Icons.inventory_2,
                                  const Color(0xFFF59E0B)),
                              _buildStatCard(
                                  'Revenue',
                                  '\$${(stats?.revenue ?? 0).toStringAsFixed(2)}',
                                  Icons.payments,
                                  const Color(0xFF8B5CF6)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Today at a glance',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniMetric(
                                'Pending',
                                '${stats?.pendingOrders ?? 0}',
                                Icons.pending_actions,
                                Colors.deepOrange),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMiniMetric(
                                'Active products',
                                '${stats?.activeProducts ?? 0}',
                                Icons.verified,
                                Colors.teal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Management',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      _buildManagementTile(
                        context,
                        title: 'Manage Products',
                        subtitle: 'Add, edit, delete, and monitor inventory',
                        icon: Icons.shopping_bag_outlined,
                        color: const Color(0xFF3B6FF6),
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin-products'),
                      ),
                      _buildManagementTile(
                        context,
                        title: 'Manage Orders',
                        subtitle: 'Track fulfillment, statuses, and shipping',
                        icon: Icons.local_shipping_outlined,
                        color: const Color(0xFF11A36A),
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin-orders'),
                      ),
                      _buildManagementTile(
                        context,
                        title: 'Manage Users',
                        subtitle: 'Review customers and account access',
                        icon: Icons.admin_panel_settings_outlined,
                        color: const Color(0xFFF59E0B),
                        onTap: () => Navigator.pushNamed(context, '/admin-users'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthController>().logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, AdminController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B6FF6), Color(0xFF6EA8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text(
                  'Your dashboard listens to live database updates.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: controller.loadAllAdminData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh admin data',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.shade100)),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red.shade800)),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(.12),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.12),
            foregroundColor: color,
            child: Icon(icon),
          ),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(title,
              style:
              TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _buildManagementTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(.12),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey.shade500),
      ),
    );
  }
}
