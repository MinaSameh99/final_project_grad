// lib/doctor_screens/docotor_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/doctor_provider.dart';
import 'package:sams/doctor_screens/doctor_profile_screen.dart';
import 'package:sams/doctor_screens/doctor_schedule_screen.dart';

class DocotorHomeScreen extends StatefulWidget {
  const DocotorHomeScreen({super.key});

  @override
  State<DocotorHomeScreen> createState() => _DocotorHomeScreenState();
}

class _DocotorHomeScreenState extends State<DocotorHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().loadAdvisorProfile();
    });
  }

  // ── Home tab ─────────────────────────────────────────────────────────────
  Widget _buildHomeTab(DoctorProvider prov) {
    final headerH = MediaQuery.of(context).size.height * 0.20;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width:  double.infinity,
                height: headerH,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 6, 34, 78),
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(15),
                    bottomRight: Radius.circular(250),
                  ),
                ),
              ),
              Positioned(
                top:  60,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Dr. ${prov.name.isEmpty ? '...' : prov.name}',
                      style: const TextStyle(
                          color:      Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize:   22),
                    ),
                    if (prov.department.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${prov.department} Department',
                          style: const TextStyle(
                              color:    Colors.white70,
                              fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Quick-access cards ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Access',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:   18,
                      color:      Colors.black87),
                ),
                const SizedBox(height: 14),

                _actionCard(
                  icon:     Icons.people_alt_outlined,
                  title:    'My Students',
                  subtitle: 'View enrolled students and assign grades',
                  onTap:    () =>
                      Navigator.pushNamed(context, '/docstudents'),
                ),
                const SizedBox(height: 12),

                _actionCard(
                  icon:     Icons.calendar_today_outlined,
                  title:    'My Lectures',
                  subtitle: 'View and create lecture sessions',
                  onTap:    () =>
                      setState(() => _selectedIndex = 1),
                ),
                const SizedBox(height: 28),

                // ── Assigned courses ────────────────────────────────────
                const Text(
                  'My Assigned Courses',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:   18,
                      color:      Colors.black87),
                ),
                const SizedBox(height: 12),

                prov.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : prov.courses.isEmpty
                    ? const Text(
                  'No courses assigned yet.',
                  style: TextStyle(color: Colors.grey),
                )
                    : Wrap(
                  spacing:    10,
                  runSpacing: 10,
                  children: prov.courses.map((c) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 6, 34, 78)
                            .withValues(alpha: 0.1),
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(
                              255, 6, 34, 78)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        c,
                        style: const TextStyle(
                            color: Color.fromARGB(
                                255, 6, 34, 78),
                            fontWeight: FontWeight.w600,
                            fontSize:   13),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable action card ──────────────────────────────────────────────────
  Widget _actionCard({
    required IconData     icon,
    required String       title,
    required String       subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color:  Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3)),
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
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ── Main build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DoctorProvider>();

    late Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = _buildHomeTab(prov);
        break;
      case 1:
        currentScreen = const DoctorScheduleScreen();
        break;
      case 2:
        currentScreen = const DoctorProfileScreen();
        break;
      default:
        currentScreen = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:            currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:     Colors.grey[200],
        selectedItemColor:   const Color.fromARGB(255, 6, 34, 78),
        unselectedItemColor: Colors.grey[500],
        currentIndex: _selectedIndex,
        onTap: (v) => setState(() => _selectedIndex = v),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.table_chart_outlined), label: 'Lectures'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}