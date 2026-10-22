import 'package:cloud_firestore/cloud_firestore.dart';

/// Role keys arrive as `viceCaptain`, `vice-captain` or `vice captain`.
String _roleKey(String? role) =>
    (role ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

bool isSameCrewRole(String? a, String? b) =>
    _roleKey(a).isNotEmpty && _roleKey(a) == _roleKey(b);

class CrewMember {
  final String characterId;
  final String name;
  final String? nickname;
  final String? role;
  final String bounty;

  CrewMember({
    required this.characterId,
    required this.name,
    this.nickname,
    this.role,
    required this.bounty,
  });

  bool get isCaptain => _roleKey(role) == 'captain';
  bool get isViceCaptain => _roleKey(role) == 'vicecaptain';
  bool holdsRole(String role) =>
      _roleKey(role).isNotEmpty && _roleKey(this.role) == _roleKey(role);

  Map<String, dynamic> toMap() {
    return {
      'characterId': characterId,
      'name': name,
      'nickname': nickname,
      'role': role,
      'bounty': bounty,
    };
  }

  factory CrewMember.fromMap(Map<String, dynamic> map) {
    return CrewMember(
      characterId: map['characterId'] ?? '',
      name: map['name'] ?? '',
      nickname: map['nickname'],
      role: map['role'],
      bounty: map['bounty'] ?? '',
    );
  }

  CrewMember copyWith({
    String? characterId,
    String? name,
    String? nickname,
    String? role,
    String? bounty,
  }) {
    return CrewMember(
      characterId: characterId ?? this.characterId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      bounty: bounty ?? this.bounty,
    );
  }
}

class CrewModel {
  final String? id;
  final String name;
  final String userId;
  final String? captain;
  final String? viceCaptain;
  final List<String> rolesFilled;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? jollyRogerUrl;
  final String? boatImageUrl;
  final String? boatName;
  final String? description;
  final List<CrewMember> members;
  final List<String> tags;

  CrewModel({
    this.id,
    required this.name,
    required this.userId,
    this.captain,
    this.viceCaptain,
    this.rolesFilled = const [],
    this.createdAt,
    this.updatedAt,
    this.jollyRogerUrl,
    this.boatImageUrl,
    this.boatName,
    this.description,
    this.members = const [],
    this.tags = const [],
  });

  /// Each role can be held once; legacy spellings count as the role they name.
  /// Only a member holds a role: older crews keep roles in [rolesFilled] whose
  /// holder already left, and trusting it would lock that role for good.
  bool isRoleFilled(String role) =>
      members.any((member) => member.holdsRole(role));

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'captain': captain,
      'viceCaptain': viceCaptain,
      'rolesFilled': rolesFilled,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'jollyRogerUrl': jollyRogerUrl,
      'boatImageUrl': boatImageUrl,
      'boatName': boatName,
      'description': description,
      'members': members.map((member) => member.toMap()).toList(),
      'tags': tags,
    };
  }

  factory CrewModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return CrewModel(
      id: documentId,
      name: data['name'] ?? '',
      userId: data['userId'] ?? data['ownerId'] ?? '',
      captain: data['captain'],
      viceCaptain: data['viceCaptain'],
      rolesFilled: List<String>.from(data['rolesFilled'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      jollyRogerUrl: data['jollyRogerUrl'],
      boatImageUrl: data['boatImageUrl'],
      boatName: data['boatName'],
      description: data['description'],
      members: (data['members'] as List<dynamic>? ?? [])
          .map((member) => CrewMember.fromMap(member))
          .toList(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  CrewModel copyWith({
    String? id,
    String? name,
    String? userId,
    String? captain,
    String? viceCaptain,
    List<String>? rolesFilled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? jollyRogerUrl,
    String? boatImageUrl,
    String? boatName,
    String? description,
    List<CrewMember>? members,
    List<String>? tags,
  }) {
    return CrewModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      captain: captain ?? this.captain,
      viceCaptain: viceCaptain ?? this.viceCaptain,
      rolesFilled: rolesFilled ?? this.rolesFilled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      jollyRogerUrl: jollyRogerUrl ?? this.jollyRogerUrl,
      boatImageUrl: boatImageUrl ?? this.boatImageUrl,
      boatName: boatName ?? this.boatName,
      description: description ?? this.description,
      members: members ?? this.members,
      tags: tags ?? this.tags,
    );
  }
}
