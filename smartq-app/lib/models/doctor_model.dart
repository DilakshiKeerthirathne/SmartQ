class DoctorModel {
  final String id;
  final String name;
  final String department;
  final String status;
  final String prefix;
  final int avgTime;
  final String? timeSlot;

  DoctorModel({
    required this.id,
    required this.name,
    required this.department,
    required this.status,
    required this.prefix,
    required this.avgTime,
    this.timeSlot,
  });

  factory DoctorModel.fromMap(String id, Map<String, dynamic> data) {
    return DoctorModel(
      id: id,
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      status: data['status'] ?? 'Available',
      prefix: data['prefix'] ?? '',
      avgTime: data['avgTime'] ?? 5,
      timeSlot: data['timeSlot'],
    );
  }
}