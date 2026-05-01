import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String ticketNumber;
  final String status;
  final String userId;
  final String doctor;
  final String department;
  final bool isEmergency;
  final Timestamp createdAt;

  TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.status,
    required this.userId,
    required this.doctor,
    required this.department,
    required this.isEmergency,
    required this.createdAt,
  });

  factory TicketModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return TicketModel(
      id: id,
      ticketNumber: data['ticketNumber'] ?? '',
      status: data['status'] ?? 'Waiting',
      userId: data['userId'] ?? '',
      doctor: data['doctor'] ?? '',
      department: data['department'] ?? '',
      isEmergency: data['isEmergency'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}