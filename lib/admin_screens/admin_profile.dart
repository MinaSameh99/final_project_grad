// lib/admin_screens/admin_profile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/admin_provider.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adm     = context.watch<AdminProvider>();
    final headerH = MediaQuery.of(context).size.height * 0.20;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
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
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
              ),
              const Positioned(
                top: 50, left: 22,
                child: Text('Profile',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // ── Info card ─────────────────────────────────────────────────
          Container(
            margin:  const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              children: [
                _row('Name',    adm.name),
                const SizedBox(height: 10),
                _row('Email',   adm.email),
                const SizedBox(height: 10),
                _row('User ID', adm.userId.toString()),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // ── Logout button ─────────────────────────────────────────────
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                // ✅ Capture navigator BEFORE the await
                final navigator = Navigator.of(context);
                await adm.logout();
                navigator.pushNamedAndRemoveUntil('/signup', (route) => false);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Log Out',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text('$title:',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 6, 34, 78))),
      const SizedBox(width: 10),
      Expanded(
          child: Text(value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
    ]),
  );
}