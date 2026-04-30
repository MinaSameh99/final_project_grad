// lib/student_screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/services/api.dart';
import 'package:sams/provider/notification_provider.dart';
import 'package:sams/provider/user_provider.dart';
import 'package:sams/student_screens/payment_page.dart';
import 'package:sams/student_screens/profile_screen.dart';
import 'package:sams/student_screens/schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  // ── Bottom nav index ────────────────────────────────────────────────────
  int _selectedIndex = 0;

  // ── Course data ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _eligibleCourses = [];
  List<Map<String, dynamic>> _lockedCourses   = [];
  String _searchQuery = '';
  bool   _isLoading   = true;
  String _error       = '';

  // ── Tab controller for Available / Locked ───────────────────────────────
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCourses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Fetch overview from API ─────────────────────────────────────────────
  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _error     = '';
    });
    try {
      final data = await ApiService.getCoursesOverview();
      if (!mounted) return;
      setState(() {
        _eligibleCourses =
        List<Map<String, dynamic>>.from(data['eligible'] ?? []);
        _lockedCourses   =
        List<Map<String, dynamic>>.from(data['locked']   ?? []);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Enroll action ────────────────────────────────────────────────────────
  Future<void> _enroll(Map<String, dynamic> course) async {
    // Capture messenger BEFORE await
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ApiService.enrollCourse(course['course_id'] as int);
      messenger.showSnackBar(SnackBar(
        content: Text(
            'Enrollment request sent for "${course['course_name']}"'),
        backgroundColor: Colors.green,
      ));
      if (mounted) {
        setState(() => _eligibleCourses
            .removeWhere((c) => c['course_id'] == course['course_id']));
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(
        content:         Text(e.message),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ── Header widget ────────────────────────────────────────────────────────
  Widget _buildHeader(UserProvider user) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 60, 22, 18),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 6, 34, 78),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${user.name.isEmpty ? 'Student' : user.name} 👋',
            style: const TextStyle(
                color:      Colors.white,
                fontSize:   22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'GPA: ${user.gpa.toStringAsFixed(2)}'
                '${user.level > 0 ? "  •  Year ${user.level}" : ""}'
                '${user.department.isNotEmpty ? "  •  ${user.department}" : ""}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText:   'Search courses...',
              hintStyle:  const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              filled:      true,
              fillColor:   Colors.white24,
              prefixIcon:  const Icon(Icons.search, color: Colors.white70),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 0),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── Available courses tab ────────────────────────────────────────────────
  Widget _buildAvailableTab() {
    final filtered = _eligibleCourses
        .where((c) =>
        (c['course_name'] as String? ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No available courses at the moment.\n'
                'Check back after your current enrollments are graded.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCourses,
      child: ListView.builder(
        padding:   const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) {
          final c = filtered[i];
          return Card(
            margin:    const EdgeInsets.only(bottom: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Icon box
                  Container(
                    width:  50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 6, 34, 78)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book,
                        color: Color.fromARGB(255, 6, 34, 78)),
                  ),
                  const SizedBox(width: 12),
                  // Course info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['course_name']?.toString() ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:   15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${c['credits']} credits'
                              '${(c['department'] as String?)?.isNotEmpty == true ? "  •  ${c['department']}" : ""}'
                              '${c['level'] != null ? "  •  Lvl ${c['level']}" : ""}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Enroll button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _enroll(c),
                    child: const Text(
                      'Enroll',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Locked courses tab ───────────────────────────────────────────────────
  Widget _buildLockedTab() {
    final filtered = _lockedCourses
        .where((c) =>
        (c['course_name'] as String? ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No locked courses!\nYou are eligible for everything available.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    return ListView.builder(
      padding:   const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final c       = filtered[i];
        final missing = List<String>.from(
            c['missing_prerequisites'] as List? ?? []);

        return Card(
          margin:    const EdgeInsets.only(bottom: 12),
          elevation: 2,
          color:     Colors.grey[50],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lock icon box
                Container(
                  width:  50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock,
                      color: Colors.redAccent, size: 22),
                ),
                const SizedBox(width: 12),
                // Course info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['course_name']?.toString() ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:   15,
                            color:      Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${c['credits']} credits'
                            '${c['level'] != null ? "  •  Level ${c['level']}" : ""}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                      if (missing.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Complete these first:',
                          style: TextStyle(
                              fontSize:   12,
                              fontWeight: FontWeight.w700,
                              color:      Colors.redAccent),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing:    6,
                          runSpacing: 4,
                          children: missing.map((name) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red
                                    .withValues(alpha: 0.08),
                                borderRadius:
                                BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.redAccent
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color:    Colors.redAccent),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Home tab wrapper ─────────────────────────────────────────────────────
  Widget _buildHomeTab(UserProvider user) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error,
                style:     const TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _fetchCourses,
                child:     const Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        _buildHeader(user),
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller:          _tabController,
            labelColor:          const Color.fromARGB(255, 6, 34, 78),
            unselectedLabelColor: Colors.grey,
            indicatorColor:      const Color.fromARGB(255, 6, 34, 78),
            indicatorWeight:     3,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 6),
                    Text('Available (${_eligibleCourses.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 18),
                    const SizedBox(width: 6),
                    Text('Locked (${_lockedCourses.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAvailableTab(),
              _buildLockedTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Main build ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    late Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = _buildHomeTab(user);
        break;
      case 1:
        currentScreen = const ScheduleScreen();
        break;
      case 2:
        currentScreen = const ProfileScreen();
        break;
      case 3:
        currentScreen = const PaymentPage();
        break;
      default:
        currentScreen = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:     Colors.grey[200],
        selectedItemColor:   const Color.fromARGB(255, 6, 34, 78),
        unselectedItemColor: Colors.grey[500],
        currentIndex: _selectedIndex,
        onTap: (v) => setState(() => _selectedIndex = v),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'My Enrollments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment), label: 'Payment'),
        ],
      ),
    );
  }
}