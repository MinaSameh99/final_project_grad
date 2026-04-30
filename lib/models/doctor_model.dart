
// lib/models/doctor_model.dart

class Doctor {
  final String uniId;      // renamed from uni_id
  final String fullName;   // renamed from full_name
  final int year;
  final List<String> subjects;
  final String? department;
  final String? phone;

  Doctor({
    required this.uniId,
    required this.fullName,
    required this.year,
    required this.subjects,
    this.department,
    this.phone,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      uniId:    json['uni_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      year: int.tryParse(
        json['year']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
      ) ?? 0,
      subjects: List<String>.from(json['subjects'] ?? []),
      department: json['department']?.toString(),
      phone:      json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uni_id':   uniId,
      'full_name': fullName,
      'year':     year,
      'subjects': subjects,
      if (department != null) 'department': department,
      if (phone != null) 'phone': phone,
    };
  }
}
