// lib/admin_screens/create_course_screen.dart

import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _codeCtrl    = TextEditingController();
  final _creditsCtrl = TextEditingController();
  final _capacityCtrl= TextEditingController();
  final _yearCtrl    = TextEditingController(
      text: DateTime.now().year.toString());

  String? _selectedDepartment;
  int?    _selectedLevel;
  String? _selectedSemester;
  int?    _selectedAdvisorId;

  List<Map<String, dynamic>> _advisors = [];
  bool   _advisorsLoading = true;
  bool   _isSubmitting    = false;
  String _error           = '';

  static const _departments = [
    'MIS', 'Marketing', 'Accounting',
    'HR', 'Bank Management', 'Finance',
  ];
  static const _semesters = ['Fall', 'Spring', 'Summer'];
  static const _levels    = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    _loadAdvisors();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _creditsCtrl.dispose();
    _capacityCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAdvisors() async {
    try {
      final data = await ApiService.getAdvisors();
      if (!mounted) return;
      setState(() {
        _advisors        = List<Map<String, dynamic>>.from(data);
        _advisorsLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error           = 'Could not load advisors: ${e.message}';
        _advisorsLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartment == null ||
        _selectedLevel      == null ||
        _selectedSemester   == null ||
        _selectedAdvisorId  == null) {
      setState(() =>
      _error = 'Please fill all dropdown fields');
      return;
    }

    final year = int.tryParse(_yearCtrl.text.trim());
    if (year == null) {
      setState(() => _error = 'Invalid year');
      return;
    }

    setState(() { _isSubmitting = true; _error = ''; });

    // Capture before async gap
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ApiService.createCourse(
        courseName:  _nameCtrl.text.trim(),
        courseCode:  _codeCtrl.text.trim().toUpperCase(),
        creditHours: int.parse(_creditsCtrl.text.trim()),
        department:  _selectedDepartment!,
        level:       _selectedLevel!,
        semester:    _selectedSemester!,
        year:        year,
        advisorId:   _selectedAdvisorId!,
        capacity:    int.parse(_capacityCtrl.text.trim()),
      );

      messenger.showSnackBar(const SnackBar(
        content:         Text('Course created successfully!'),
        backgroundColor: Colors.green,
      ));

      // Return true so ManageCoursesScreen knows to refresh
      navigator.pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        foregroundColor: Colors.white,
        title: const Text('Create New Course',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _advisorsLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Course Name ────────────────────────────────────
              _label('Course Name'),
              const SizedBox(height: 6),
              _field(_nameCtrl, 'e.g. Introduction to AI'),

              const SizedBox(height: 16),

              // ── Course Code ────────────────────────────────────
              _label('Course Code'),
              const SizedBox(height: 6),
              _field(
                _codeCtrl,
                'e.g. CS401',
                extra: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 3) return 'Too short';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ── Credit Hours + Capacity row ────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Credit Hours'),
                        const SizedBox(height: 6),
                        _field(
                          _creditsCtrl,
                          '1 – 6',
                          numeric: true,
                          extra: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 1 || n > 6) {
                              return '1–6';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Capacity'),
                        const SizedBox(height: 6),
                        _field(
                          _capacityCtrl,
                          'e.g. 50',
                          numeric: true,
                          extra: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 1) return 'Min 1';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Department ─────────────────────────────────────
              _label('Department'),
              const SizedBox(height: 6),
              _dropdown<String>(
                hint:  'Select department',
                value: _selectedDepartment,
                items: _departments,
                labelOf: (d) => d,
                valueOf: (d) => d,
                onChanged: (v) =>
                    setState(() => _selectedDepartment = v),
              ),

              const SizedBox(height: 16),

              // ── Level + Semester row ───────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Year Level'),
                        const SizedBox(height: 6),
                        _dropdown<int>(
                          hint:     'Year',
                          value:    _selectedLevel,
                          items:    _levels,
                          labelOf:  (l) => 'Year $l',
                          valueOf:  (l) => l,
                          onChanged:(v) =>
                              setState(() => _selectedLevel = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Semester'),
                        const SizedBox(height: 6),
                        _dropdown<String>(
                          hint:     'Semester',
                          value:    _selectedSemester,
                          items:    _semesters,
                          labelOf:  (s) => s,
                          valueOf:  (s) => s,
                          onChanged:(v) =>
                              setState(() => _selectedSemester = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Academic Year ──────────────────────────────────
              _label('Academic Year'),
              const SizedBox(height: 6),
              _field(
                _yearCtrl,
                'e.g. 2025',
                numeric: true,
                extra: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 2000 || n > 2100) {
                    return 'Enter valid year';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ── Advisor ────────────────────────────────────────
              _label('Assign Advisor'),
              const SizedBox(height: 6),
              if (_advisors.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:        Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.orange
                            .withValues(alpha: 0.4)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.warning_amber_outlined,
                        color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No advisors found. Register and approve an advisor account first.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ]),
                )
              else
                DropdownButtonFormField<int>(
                  initialValue:    _selectedAdvisorId,
                  hint:     const Text('Select advisor'),
                  decoration: _inputDec(),
                  items: _advisors.map((a) {
                    final id   = a['advisor_id'] as int;
                    final name = a['name']       as String? ?? 'Unknown';
                    final dept = a['department']  as String? ?? '';
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(
                          dept.isNotEmpty ? '$name ($dept)' : name),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => _selectedAdvisorId = v),
                  validator: (v) =>
                  v == null ? 'Please select an advisor' : null,
                ),

              const SizedBox(height: 16),

              // ── Error ──────────────────────────────────────────
              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin:  const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:        Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error,
                          style: const TextStyle(
                              color: Colors.red)),
                    ),
                  ]),
                ),

              // ── Submit ─────────────────────────────────────────
              const SizedBox(height: 8),
              SizedBox(
                width:  double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color.fromARGB(255, 6, 34, 78),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed:
                  (_isSubmitting || _advisors.isEmpty)
                      ? null
                      : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                    width:  24,
                    height: 24,
                    child:  CircularProgressIndicator(
                        color:       Colors.white,
                        strokeWidth: 2),
                  )
                      : const Text(
                    'Create Course',
                    style: TextStyle(
                        color:      Colors.white,
                        fontSize:   18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
        color:      Color.fromARGB(255, 19, 53, 105),
        fontSize:   15,
        fontWeight: FontWeight.w700),
  );

  InputDecoration _inputDec([String hint = '']) => InputDecoration(
    hintText:  hint,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12)),
    filled:    true,
    fillColor: const Color(0xFFF5F7FB),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  Widget _field(
      TextEditingController ctrl,
      String hint, {
        bool numeric = false,
        String? Function(String?)? extra,
      }) {
    return TextFormField(
      controller:   ctrl,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration:   _inputDec(hint),
      validator: extra ??
              (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _dropdown<T>({
    required String hint,
    required T?     value,
    required List<T> items,
    required String Function(T)  labelOf,
    required T      Function(T)  valueOf,
    required void   Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue:      value,
      hint:       Text(hint),
      decoration: _inputDec(),
      items: items
          .map((item) => DropdownMenuItem<T>(
        value: valueOf(item),
        child: Text(labelOf(item)),
      ))
          .toList(),
      onChanged:  onChanged,
      validator:  (v) => v == null ? 'Required' : null,
    );
  }
}