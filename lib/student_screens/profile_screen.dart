// lib/student_screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/notification_provider.dart';
import 'package:sams/provider/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadStudentProfile();
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user    = context.watch<UserProvider>();
    final headerH = MediaQuery.of(context).size.height * 0.20;

    if (user.isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
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
                  top: 50, left: 22,
                  child: Text('Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Profile card ─────────────────────────────────────────────
            Container(
              margin:  const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  _row('Uni ID',     user.uniId),
                  _row('Department', user.department),
                  _row('Level',
                      user.level > 0 ? 'Year ${user.level}' : '—'),
                  _row('Phone', user.phone),
                  _row('GPA',   user.gpa.toStringAsFixed(2)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Notifications ────────────────────────────────────────────
            Consumer<NotificationProvider>(
              builder: (ctx, notif, _) {
                if (notif.isLoading) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator());
                }
                if (notif.notifications.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No notifications.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text('Notifications',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ...notif.notifications.map((n) => Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          n.type == 'enrollment'
                              ? Icons.school
                              : Icons.notifications,
                          color: const Color.fromARGB(255, 6, 34, 78),
                        ),
                        title: Text(n.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(n.message),
                        trailing: n.isRead
                            ? null
                            : const Icon(Icons.circle,
                            color: Colors.red, size: 10),
                      ),
                    )),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Logout ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Log Out',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  // ✅ Capture navigator BEFORE the awaits
                  final navigator = Navigator.of(context);
                  final notifProv =
                  context.read<NotificationProvider>();
                  await user.logout();
                  notifProv.clear();
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
    child: Row(children: [
      Text('$title:',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 6, 34, 78))),
      const SizedBox(width: 10),
      Expanded(
          child: Text(value.isEmpty ? '—' : value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold))),
    ]),
  );
}