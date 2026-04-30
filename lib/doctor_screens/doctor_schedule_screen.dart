// lib/doctor_screens/doctor_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/doctor_provider.dart';
import 'package:sams/services/api.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().loadMyLectures();
    });
  }

  // ── Date + time picker helper ────────────────────────────────────────────
  Future<DateTime?> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:   DateTime.now(),
      lastDate:    DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
  }

  // ── Create lecture dialog ────────────────────────────────────────────────
  void _createLectureDialog() {
    final courseCtrl = TextEditingController();
    final titleCtrl  = TextEditingController();
    final descCtrl   = TextEditingController();
    final roomCtrl   = TextEditingController();
    DateTime? selectedDt;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (dlgCtx2, setDlgState) => AlertDialog(
          title: const Text('Create Lecture'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: courseCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Course ID',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roomCtrl,
                decoration: const InputDecoration(
                    labelText: 'Room',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // ✅ _pickDateTime uses StatefulWidget's context (mounted)
                  final dt = await _pickDateTime();
                  if (dt != null) {
                    setDlgState(() => selectedDt = dt);
                  }
                },
                child: Text(
                  selectedDt == null
                      ? 'Pick Date & Time'
                      : selectedDt!.toLocal().toString().split('.').first,
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 6, 34, 78)),
              onPressed: () async {
                final cId = int.tryParse(courseCtrl.text.trim());
                if (cId == null || selectedDt == null) return;

                // ✅ Capture everything BEFORE the awaits
                final nav      = Navigator.of(dlgCtx);
                final messenger = ScaffoldMessenger.of(context);
                final prov     = context.read<DoctorProvider>();

                nav.pop(); // close dialog

                try {
                  await ApiService.createLecture(
                    courseId:        cId,
                    title:           titleCtrl.text.trim(),
                    description:     descCtrl.text.trim(),
                    room:            roomCtrl.text.trim(),
                    lectureDatetime: selectedDt!.toIso8601String(),
                  );
                  if (!mounted) return;
                  messenger.showSnackBar(const SnackBar(
                    content: Text('Lecture created!'),
                    backgroundColor: Colors.green,
                  ));
                  prov.loadMyLectures();
                } on ApiException catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(SnackBar(
                    content: Text(e.message),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: const Text('Create',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final prov    = context.watch<DoctorProvider>();
    final headerH = MediaQuery.of(context).size.height * 0.15;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        onPressed: _createLectureDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
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
                top: 80, left: 50,
                child: Text('My Lectures',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Expanded(
            child: prov.isLoading
                ? const Center(child: CircularProgressIndicator())
                : prov.myLectures.isEmpty
                ? const Center(
              child: Text(
                'No lectures yet.\nTap + to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prov.myLectures.length,
              itemBuilder: (ctx, i) {
                final l = prov.myLectures[i];
                return Card(
                  margin:    const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor:
                      Color.fromARGB(255, 6, 34, 78),
                      child:
                      Icon(Icons.book, color: Colors.white),
                    ),
                    title: Text(l['title']?.toString() ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Room: ${l['room'] ?? ''}'),
                        Text(
                            'Course ID: ${l['course_id'] ?? ''}'),
                        Text(
                          'Time: ${(l['lecture_datetime'] as String?)?.replaceAll('T', ' ') ?? ''}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}