import 'dart:convert';

class AppUserModel {
  const AppUserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.city,
    required this.age,
    required this.isGuest,
    required this.createdAt,
    required this.lastSyncAt,
    this.medicalNotes,
    this.preferences = const {},
  });

  final String id;
  final String email;
  final String name;
  final String city;
  final int age;
  final bool isGuest;
  final DateTime createdAt;
  final DateTime lastSyncAt;
  final String? medicalNotes;
  final Map<String, dynamic> preferences;

  AppUserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? city,
    int? age,
    bool? isGuest,
    DateTime? createdAt,
    DateTime? lastSyncAt,
    String? medicalNotes,
    Map<String, dynamic>? preferences,
  }) {
    return AppUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      city: city ?? this.city,
      age: age ?? this.age,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'city': city,
      'age': age,
      'isGuest': isGuest ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastSyncAt': lastSyncAt.toIso8601String(),
      'medicalNotes': medicalNotes,
      'preferences': jsonEncode(preferences),
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      city: map['city'] as String,
      age: map['age'] as int,
      isGuest: (map['isGuest'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastSyncAt: DateTime.parse(map['lastSyncAt'] as String),
      medicalNotes: map['medicalNotes'] as String?,
      preferences: Map<String, dynamic>.from(
        jsonDecode((map['preferences'] as String?) ?? '{}') as Map,
      ),
    );
  }
}
