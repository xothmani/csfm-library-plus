import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role; // 'Logé', 'Externe', 'Bibliothécaire', 'Administrateur'
  final bool isLodged;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isLodged,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Externe',
      isLodged: map['isLodged'] ?? false,
      phone: map['phone'],
      avatarUrl: map['avatarUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'isLodged': isLodged,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? role,
    bool? isLodged,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      isLodged: isLodged ?? this.isLodged,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
