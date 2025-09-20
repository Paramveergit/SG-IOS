// Profile Screen - User account management and order history

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../utils/app-constant.dart';
import '../auth-ui/welcome-screen.dart';
import 'all-orders-screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: AppConstant.appTextColor),
        ),
        backgroundColor: AppConstant.appMainColor,
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        elevation: 2.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),
              
              const SizedBox(height: 24.0),
              
              // Profile Options
              _buildProfileOptions(),
              
              const SizedBox(height: 24.0),
              
              // Account Actions
              _buildAccountActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: AppConstant.appMainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 40.0,
              color: AppConstant.appMainColor,
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // User Name
          Text(
            user?.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4.0),
          
          // User Email
          Text(
            user?.email ?? 'No email',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // User ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              'ID: ${user?.uid.substring(0, 8)}...',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileOption(
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'View order history',
            onTap: () => Get.to(() => const AllOrdersScreen()),
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.location_on_outlined,
            title: 'Delivery Address',
            subtitle: 'Manage addresses',
            onTap: () => _showComingSoon('Delivery Address'),
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage payment options',
            onTap: () => _showComingSoon('Payment Methods'),
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () => _showComingSoon('Notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppConstant.appMainColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(
          icon,
          color: AppConstant.appMainColor,
          size: 20.0,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1.0,
      color: Colors.grey.shade200,
      indent: 56.0,
    );
  }

  Widget _buildAccountActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get assistance',
            onTap: () => _showSupportOptions(),
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and info',
            onTap: () => _showAboutDialog(),
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature feature will be available soon!',
      backgroundColor: AppConstant.appMainColor,
      colorText: AppConstant.appTextColor,
      duration: const Duration(seconds: 2),
    );
  }

  void _showSupportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            
            const SizedBox(height: 20.0),
            
            // Title
            const Text(
              'Help & Support',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20.0),
            
            // Support Options
            _buildSupportOption(
              icon: Icons.phone,
              title: 'Call Us',
              subtitle: '+91 9830464031',
              onTap: () {
                Get.back();
                // Add phone call functionality
              },
            ),
            
            _buildSupportOption(
              icon: Icons.message,
              title: 'WhatsApp',
              subtitle: 'Chat with us',
              onTap: () {
                Get.back();
                // Add WhatsApp functionality
              },
            ),
            
            _buildSupportOption(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@sundergarments.com',
              onTap: () {
                Get.back();
                // Add email functionality
              },
            ),
            
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppConstant.appMainColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(
          icon,
          color: AppConstant.appMainColor,
          size: 20.0,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Sunder Garments'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8.0),
            Text('Sunder Garments - Your trusted clothing partner'),
            SizedBox(height: 8.0),
            Text('© 2024 Sunder Garments. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => WelcomeScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
