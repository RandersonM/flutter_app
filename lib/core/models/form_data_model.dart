import 'package:cloud_firestore/cloud_firestore.dart';

class FormDataModel {
  final String? id;
  final String? userId;
  final String name;
  final String email;
  final String? phone;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FormDataModel({
    this.id,
    this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Create from Firestore document
  factory FormDataModel.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return FormDataModel(
      id: documentId,
      userId: data['userId'] as String?,
      name: data['name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String?,
      description: data['description'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'description': description,
    };
  }

  FormDataModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FormDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FormDataModel(id: $id, userId: $userId, name: $name, email: $email, phone: $phone, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormDataModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        description.hashCode;
  }
}
