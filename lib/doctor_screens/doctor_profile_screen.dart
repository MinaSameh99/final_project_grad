// lib/doctor_screens/doctor_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/doctor_provider.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doc     = context.watch<DoctorProvider>();
    final headerH = MediaQuery.of(context).size.height * 0.20;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: doc.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width:  double.infinity,
                  height: headerH,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 6, 34, 78),
                    borderRadius: BorderRadius.only(
                      bottomLeft:  Radius.circular(10),
                      bottomRight: Radius.circular(200),
                    ),
                  ),
                ),
                const Positioned(
                  top:  50,
                  left: 22,
                  child: Text(
                    'Profile',
                    style: TextStyle(
                        color:      Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize:   24),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left:    0,
                  right:   180,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor:
                      const Color.fromARGB(255, 6, 34, 78),
                      child: Text(
                        doc.name.isNotEmpty
                            ? doc.name[0].toUpperCase()
                            : 'D',
                        style: const TextStyle(
                            color:    Colors.white,
                            fontSize: 32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // ── Info card ─────────────────────────────────────────
            Container(
              margin:  const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color:     Colors.black12,
                      blurRadius: 6,
                      offset:    Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  _row('Name',       doc.name),
                  _row('Phone',      doc.phone),
                  _row('Department', doc.department),
                  _row('Advisor ID', doc.advisorId.toString()),
                  _row('Courses',    doc.courses.join(', ')),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ── Logout button ─────────────────────────────────────
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout,
                    color: Colors.white, size: 20),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                      color:      Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize:   18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color.fromARGB(255, 6, 34, 78),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  // Capture navigator BEFORE the await
                  final navigator = Navigator.of(context);
                  await doc.logout();
                  navigator.pushNamedAndRemoveUntil(
                      '/signup', (r) => false);
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Text(
          '$title:',
          style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w500,
              color:      Color.fromARGB(255, 6, 34, 78)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}