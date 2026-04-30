// lib/doctor_screens/doctor_students_screen.dart

import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';

class DoctorStudentsScreen extends StatefulWidget {
  const DoctorStudentsScreen({super.key});

  @override
  State<DoctorStudentsScreen> createState() =>
      _DoctorStudentsScreenState();
}

class _DoctorStudentsScreenState extends State<DoctorStudentsScreen> {
  List<Map<String, dynamic>> _students = [];
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
      final data = await ApiService.getMyStudents();
      if (!mounted) return;
      setState(() =>
      _students = List<Map<String, dynamic>>.from(data));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Grade assignment dialog ──────────────────────────────────────────────
  void _showGradeDialog(int enrollmentId, String studentName) {
    String selected = 'A';

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (dlgCtx2, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Grade — $studentName',
            style: const TextStyle(fontSize: 16),
          ),
          content: DropdownButtonFormField<String>(
            initialValue: selected,
            decoration: const InputDecoration(
                labelText: 'Select Grade',
                border:    OutlineInputBorder()),
            items: [
              'A', 'A-', 'B+', 'B', 'B-',
              'C+', 'C', 'C-', 'D', 'F',
            ]
                .map((g) =>
                DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setDlg(() => selected = v ?? 'A'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child:     const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 6, 34, 78)),
              onPressed: () async {
                // Capture BEFORE await
                final nav       = Navigator.of(dlgCtx);
                final messenger = ScaffoldMessenger.of(context);

                nav.pop(); // close dialog first

                try {
                  await ApiService.assignGrade(
                    enrollmentId: enrollmentId,
                    grade:        selected,
                  );
                  messenger.showSnackBar(SnackBar(
                    content: Text(
                        'Grade "$selected" saved for $studentName'),
                    backgroundColor: Colors.green,
                  ));
                  if (mounted) _load();
                } on ApiException catch (e) {
                  messenger.showSnackBar(SnackBar(
                    content:         Text(e.message),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grade badge color ────────────────────────────────────────────────────
  Color _gradeColor(String? grade) {
    if (grade == null || grade.isEmpty) return Colors.grey;
    if (grade == 'F')              return Colors.red;
    if (grade.startsWith('A'))     return Colors.green;
    if (grade.startsWith('B'))     return Colors.blue;
    return Colors.orange;
  }

  // ── Status chip color ────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'passed':     return Colors.green;
      case 'failed':     return Colors.red;
      case 'registered': return Colors.blue;
      default:           return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerH = MediaQuery.of(context).size.height * 0.18;

    final filtered = _students.where((s) {
      final name   = (s['student_name'] as String? ?? '').toLowerCase();
      final course = (s['course']       as String? ?? '').toLowerCase();
      final q      = _search.toLowerCase();
      return name.contains(q) || course.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
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
                top:  55,
                left: 20,
                child: Text(
                  'My Students',
                  style: TextStyle(
                      color:      Colors.white,
                      fontSize:   26,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top:   55,
                right: 16,
                child: IconButton(
                  icon:      const Icon(Icons.refresh,
                      color: Colors.white, size: 28),
                  onPressed: _load,
                ),
              ),
            ],
          ),

          // ── Search bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText:   'Search by name or course...',
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

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(_error,
                      style: const TextStyle(
                          color: Colors.red),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _load,
                      child: const Text('Retry')),
                ],
              ),
            )
                : filtered.isEmpty
                ? const Center(
              child: Text(
                'No enrolled students yet.',
                style: TextStyle(
                    color:    Colors.grey,
                    fontSize: 16),
              ),
            )
                : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final s = filtered[i];

                  final enrollId    = s['enrollment_id'] as int?    ?? 0;
                  final studentName = s['student_name']  as String? ?? 'Unknown';
                  final uniId       = s['uni_id']        as String? ?? '';
                  final course      = s['course']        as String? ?? '';
                  final grade       = s['grade']         as String?;
                  final status      = s['status']        as String? ?? 'registered';

                  return Card(
                    margin:    const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14)),
                    child: Padding(
                      padding:
                      const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // ── Name row ───────────────────
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                const Color
                                    .fromARGB(
                                    255,
                                    6,
                                    34,
                                    78),
                                child: Text(
                                  studentName
                                      .isNotEmpty
                                      ? studentName[0]
                                      .toUpperCase()
                                      : '?',
                                  style:
                                  const TextStyle(
                                      color: Colors
                                          .white,
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight
                                          .bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      studentName,
                                      style: const TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize: 16),
                                    ),
                                    if (uniId.isNotEmpty)
                                      Text(
                                        'ID: $uniId',
                                        style: const TextStyle(
                                            color: Colors
                                                .grey,
                                            fontSize:
                                            12),
                                      ),
                                  ],
                                ),
                              ),
                              // Grade badge
                              if (grade != null &&
                                  grade.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal: 10,
                                      vertical:   4),
                                  decoration:
                                  BoxDecoration(
                                    color: _gradeColor(
                                        grade)
                                        .withValues(
                                        alpha: 0.15),
                                    borderRadius:
                                    BorderRadius
                                        .circular(8),
                                    border: Border.all(
                                        color:
                                        _gradeColor(
                                            grade)),
                                  ),
                                  child: Text(
                                    grade,
                                    style: TextStyle(
                                        color: _gradeColor(
                                            grade),
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                        fontSize: 14),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          // ── Course name ────────────────
                          Row(
                            children: [
                              const Icon(
                                  Icons.book_outlined,
                                  size:  16,
                                  color: Color.fromARGB(
                                      255, 6, 34, 78)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  course,
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // ── Status + assign button ─────
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets
                                    .symmetric(
                                    horizontal: 10,
                                    vertical:   3),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                      status)
                                      .withValues(
                                      alpha: 0.1),
                                  borderRadius:
                                  BorderRadius
                                      .circular(6),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                      color: _statusColor(
                                          status),
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 11),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _showGradeDialog(
                                        enrollId,
                                        studentName),
                                icon: const Icon(
                                    Icons.edit_note,
                                    size: 18),
                                label: const Text(
                                    'Assign Grade'),
                                style:
                                TextButton.styleFrom(
                                  foregroundColor:
                                  const Color
                                      .fromARGB(255,
                                      6, 34, 78),
                                ),
                              ),
                            ],
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