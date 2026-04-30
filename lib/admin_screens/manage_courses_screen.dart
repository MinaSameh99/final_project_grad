// lib/admin_screens/manage_courses_screen.dart

import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';
import 'package:sams/admin_screens/create_course_screen.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  List<Map<String, dynamic>> _courses = [];
  bool   _isLoading = true;
  String _error     = '';
  String _search    = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error     = '';
    });
    try {
      final data = await ApiService.getAllCourses();
      if (!mounted) return;
      setState(() =>
      _courses = List<Map<String, dynamic>>.from(data));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCourse(Map<String, dynamic> course) async {
    // Capture before async gap
    final messenger = ScaffoldMessenger.of(context);
    final courseId  = course['course_id'] as int;
    final name      = course['course_name'] as String;

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Course'),
        content: Text(
          'Are you sure you want to delete "$name"?\n\n'
              'This cannot be undone. Courses with active enrollments cannot be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child:     const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dlgCtx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteCourse(courseId);
      messenger.showSnackBar(SnackBar(
        content:         Text('"$name" deleted successfully'),
        backgroundColor: Colors.green,
      ));
      if (mounted) _load();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(
        content:         Text(e.message),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ── Department chip colour ───────────────────────────────────────────────
  Color _deptColor(String dept) {
    switch (dept.toLowerCase()) {
      case 'mis':            return Colors.blue;
      case 'marketing':      return Colors.orange;
      case 'accounting':     return Colors.green;
      case 'hr':             return Colors.purple;
      case 'bank management':return Colors.teal;
      case 'finance':        return Colors.indigo;
      default:               return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _courses.where((c) {
      final name = (c['course_name'] as String? ?? '').toLowerCase();
      final code = (c['course_code'] as String? ?? '').toLowerCase();
      final q    = _search.toLowerCase();
      return name.contains(q) || code.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        foregroundColor: Colors.white,
        title: const Text('Manage Courses',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon:      const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),

      // ── FAB: Create course ───────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        icon:  const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Course',
            style: TextStyle(color: Colors.white)),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => const CreateCourseScreen()),
          );
          if (created == true && mounted) _load();
        },
      ),

      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText:   'Search by course name or code...',
                prefixIcon: const Icon(Icons.search),
                filled:     true,
                fillColor:  Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:   BorderSide.none),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ── Summary ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} course${filtered.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    color:    Colors.grey,
                    fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _load,
                      child: const Text('Retry')),
                ],
              ),
            )
                : filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_outlined,
                      size: 64,
                      color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No courses yet.\nTap + to create the first one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:    Colors.grey,
                        fontSize: 16),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 90),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final c    = filtered[i];
                  final dept = c['department'] as String? ?? '';

                  return Card(
                    margin:    const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // ── Name row ─────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c['course_name']
                                      ?.toString() ??
                                      '',
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    _deleteCourse(c),
                                tooltip: 'Delete course',
                              ),
                            ],
                          ),

                          // ── Code + department ─────────────
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets
                                    .symmetric(
                                    horizontal: 8,
                                    vertical:   3),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                      255, 6, 34, 78)
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                  BorderRadius.circular(
                                      6),
                                ),
                                child: Text(
                                  c['course_code']
                                      ?.toString() ??
                                      '',
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.w600,
                                      fontSize:   12,
                                      color: Color.fromARGB(
                                          255, 6, 34, 78)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (dept.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal: 8,
                                      vertical:   3),
                                  decoration: BoxDecoration(
                                    color: _deptColor(dept)
                                        .withValues(
                                        alpha: 0.1),
                                    borderRadius:
                                    BorderRadius.circular(
                                        6),
                                  ),
                                  child: Text(
                                    dept,
                                    style: TextStyle(
                                        color: _deptColor(
                                            dept),
                                        fontWeight:
                                        FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          // ── Details grid ──────────────────
                          Wrap(
                            spacing:    16,
                            runSpacing:  6,
                            children: [
                              _detail(Icons.star_border,
                                  '${c['credit_hours']} credits'),
                              _detail(Icons.layers_outlined,
                                  'Year ${c['level']}'),
                              _detail(Icons.calendar_month_outlined,
                                  '${c['semester']} ${c['year']}'),
                              _detail(Icons.people_outline,
                                  'Cap: ${c['capacity']}'),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ── Advisor ───────────────────────
                          Row(children: [
                            const Icon(
                                Icons.person_outline,
                                size:  15,
                                color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Advisor: ${(c['advisor_name'] as String?)?.isNotEmpty == true ? c['advisor_name'] : 'Unassigned'}',
                                style: const TextStyle(
                                    color:    Colors.grey,
                                    fontSize: 13),
                              ),
                            ),
                          ]),
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

  Widget _detail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}