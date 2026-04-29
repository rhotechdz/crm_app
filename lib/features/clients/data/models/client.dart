import 'package:uuid/uuid.dart';

class Client {
  final String id;
  final String name;
  final String phone;
  final String? instagramHandle;
  final String wilaya;
  final String? notes;
  final int returnCount;
  final DateTime createdAt;

  Client({
    String? id,
    required this.name,
    required this.phone,
    this.instagramHandle,
    required this.wilaya,
    this.notes,
    this.returnCount = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'instagramHandle': instagramHandle,
      'wilaya': wilaya,
      'notes': notes,
      'returnCount': returnCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      instagramHandle: map['instagramHandle'],
      wilaya: map['wilaya'],
      notes: map['notes'],
      returnCount: map['returnCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
