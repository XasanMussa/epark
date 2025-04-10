import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      // Convert dynamic values to the correct types
      final id = map['id']?.toString() ?? '';
      final name = map['name']?.toString() ?? '';
      final email = map['email']?.toString() ?? '';
      final phoneNumber = map['phoneNumber']?.toString() ?? '';

      // Handle Timestamp conversion
      Timestamp createdAt;
      if (map['createdAt'] is Timestamp) {
        createdAt = map['createdAt'] as Timestamp;
      } else if (map['createdAt'] is DateTime) {
        createdAt = Timestamp.fromDate(map['createdAt'] as DateTime);
      } else {
        createdAt = Timestamp.now();
      }

      Timestamp updatedAt;
      if (map['updatedAt'] is Timestamp) {
        updatedAt = map['updatedAt'] as Timestamp;
      } else if (map['updatedAt'] is DateTime) {
        updatedAt = Timestamp.fromDate(map['updatedAt'] as DateTime);
      } else {
        updatedAt = Timestamp.now();
      }

      return UserModel(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e, stackTrace) {
      print('Error creating UserModel: $e');
      print('Stack trace: $stackTrace');
      print('Map data: $map');
      throw Exception('Failed to create UserModel: $e');
    }
  }
}
