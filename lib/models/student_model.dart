// lib/models/student_model.dart

class Student {
  final String uniId;      // renamed from uni_id
  final String fullName;   // renamed from full_name
  final int year;
  final List<String> subjects;
  final String? phone;
  final String? department;
  final String? status;

  Student({
    required this.uniId,
    required this.fullName,
    required this.year,
    required this.subjects,
    this.phone,
    this.department,
    required this.status,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      uniId:    json['uni_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      year: int.tryParse(
        json['level']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
      ) ?? 0,
      subjects: List<String>.from(json['subjects'] ?? []),
      phone:      json['phone']?.toString(),
      department: json['department']?.toString(),
      status:     json['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uni_id':   uniId,
      'full_name': fullName,
      'year':     year.toString(),
      'phone':    phone,
      'department': department,
      'status':   status,
    };
  }
}