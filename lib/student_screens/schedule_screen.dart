import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> _enrollments = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await ApiService.getMyEnrollments();
      setState(() => _enrollments = List<Map<String, dynamic>>.from(data));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String approval) {
    switch (approval) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default:         return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerH = MediaQuery.of(context).size.height * 0.20;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: headerH,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 6, 34, 78),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(200)),
                ),
              ),
              const Positioned(
                top: 80,
                left: 50,
                child: Text('My Enrollments',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Text(_error,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: _load,
                              child: const Text('Retry')),
                        ]))
                    : _enrollments.isEmpty
                        ? const Center(
                            child: Text('No enrollments yet.',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _enrollments.length,
                              itemBuilder: (ctx, i) {
                                final e = _enrollments[i];
                                final approval =
                                    e['approval']?.toString() ?? 'pending';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          _statusColor(approval),
                                      child: Text(
                                          e['course_id'].toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ),
                                    title: Text(
                                        'Course ID: ${e['course_id']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Status: ${e['status'] ?? '-'}'),
                                        Text(
                                          'Approval: $approval',
                                          style: TextStyle(
                                              color: _statusColor(approval),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}