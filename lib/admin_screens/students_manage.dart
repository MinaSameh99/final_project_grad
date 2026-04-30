// lib/admin_screens/students_manage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/admin_doctors_provider.dart';

class StudentsManageScreen extends StatefulWidget {
  const StudentsManageScreen({super.key});

  @override
  State<StudentsManageScreen> createState() => _StudentsManageScreenState();
}

class _StudentsManageScreenState extends State<StudentsManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDoctorsProvider>().loadPendingEnrollments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        title: const Text('Enrollment Requests',
            style: TextStyle(color: Colors.white)),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AdminDoctorsProvider>().loadPendingEnrollments(),
          ),
        ],
      ),
      body: Consumer<AdminDoctorsProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(provider.errorMessage,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: provider.loadPendingEnrollments,
                    child: const Text('Retry')),
              ]),
            );
          }

          if (provider.enrollments.isEmpty) {
            return const Center(
              child: Text('No pending enrollment requests.',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadPendingEnrollments,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.enrollments.length,
              itemBuilder: (ctx, i) {
                final e = provider.enrollments[i];

                return Card(
                  margin:    const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enrollment #${e.enrollmentId}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Student ID: ${e.studentId}'),
                        Text('Course ID:  ${e.courseId}'),
                        Text('Status: ${e.status}'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // ── Approve ──────────────────────────────────
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text('Approve',
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () async {
                                // ✅ Capture BEFORE await
                                final messenger =
                                ScaffoldMessenger.of(context);
                                final ok = await provider
                                    .approveEnrollment(e.enrollmentId);
                                messenger.showSnackBar(SnackBar(
                                  content: Text(ok
                                      ? 'Enrollment approved!'
                                      : provider.errorMessage),
                                  backgroundColor:
                                  ok ? Colors.green : Colors.red,
                                ));
                              },
                            ),
                            const SizedBox(width: 8),
                            // ── Reject ────────────────────────────────────
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              icon: const Icon(Icons.close, color: Colors.white),
                              label: const Text('Reject',
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () async {
                                // ✅ Capture BEFORE await
                                final messenger =
                                ScaffoldMessenger.of(context);
                                final ok = await provider
                                    .rejectEnrollment(e.enrollmentId);
                                messenger.showSnackBar(SnackBar(
                                  content: Text(ok
                                      ? 'Enrollment rejected.'
                                      : provider.errorMessage),
                                  backgroundColor:
                                  ok ? Colors.orange : Colors.red,
                                ));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}