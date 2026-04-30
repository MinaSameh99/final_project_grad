// lib/admin_screens/admin_homepage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/admin_provider.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 6, 34, 78),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${admin.name.isEmpty ? 'Admin' : admin.name}',
                    style: const TextStyle(
                        color:      Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize:   22),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Welcome to your dashboard',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Cards ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Management',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:   18,
                        color:      Colors.black87),
                  ),
                  const SizedBox(height: 14),

                  _card(
                    context,
                    title:    'Approve Registrations',
                    subtitle: 'Review and approve pending user registrations',
                    icon:     Icons.person_add_outlined,
                    route:    '/approveStudents',
                  ),
                  const SizedBox(height: 12),

                  _card(
                    context,
                    title:    'Enrollment Requests',
                    subtitle: 'Approve or reject course enrollment requests',
                    icon:     Icons.school_outlined,
                    route:    '/manageStudents',
                  ),
                  const SizedBox(height: 12),

                  _card(
                    context,
                    title:    'Manage Courses',
                    subtitle: 'Create, view and delete courses',
                    icon:     Icons.menu_book_outlined,
                    route:    '/manageCourses',
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:     Colors.grey[200],
        selectedItemColor:   const Color.fromARGB(255, 6, 34, 78),
        unselectedItemColor: Colors.grey[500],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),   label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/adminprofile');
        },
      ),
    );
  }

  Widget _card(
      BuildContext context, {
        required String   title,
        required String   subtitle,
        required IconData icon,
        required String   route,
      }) {
    return InkWell(
      onTap:        () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color:     Colors.black12,
                blurRadius: 6,
                offset:    Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width:  50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 6, 34, 78)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: const Color.fromARGB(255, 6, 34, 78),
                  size:  26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 15, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}