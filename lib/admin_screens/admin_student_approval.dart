// lib/admin_screens/admin_student_approval.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/admin_students_provider.dart';

class AdminStudentApprovalScreen extends StatefulWidget {
  const AdminStudentApprovalScreen({super.key});

  @override
  State<AdminStudentApprovalScreen> createState() =>
      _AdminStudentApprovalScreenState();
}

class _AdminStudentApprovalScreenState
    extends State<AdminStudentApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStudentsProvider>().loadPendingUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AdminStudentsProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(provider.errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: provider.loadPendingUsers,
                    child: const Text('Retry')),
              ]),
            );
          }

          if (provider.pendingUsers.isEmpty) {
            return const Center(
              child: Text('No pending registrations.',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadPendingUsers,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.pendingUsers.length,
              itemBuilder: (ctx, i) {
                final user = provider.pendingUsers[i];

                final roleIcon = user.role == 'student'
                    ? Icons.school
                    : user.role == 'advisor'
                    ? Icons.medical_services
                    : Icons.admin_panel_settings;

                return Card(
                  margin:    const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                        child: Icon(roleIcon, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(user.email,
                                style: const TextStyle(color: Colors.grey)),
                            Text('Role: ${user.role}',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 6, 34, 78),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () async {
                          // ✅ Capture messenger BEFORE the await
                          final messenger = ScaffoldMessenger.of(context);
                          final ok = await provider.approveUser(user.userId);
                          messenger.showSnackBar(SnackBar(
                            content: Text(ok
                                ? '${user.name} approved!'
                                : provider.errorMessage),
                            backgroundColor: ok ? Colors.green : Colors.red,
                          ));
                        },
                        child: const Text('Approve',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ]),
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