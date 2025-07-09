class FightingStyleModel {
  final String? name;
  final String type; // obrigatório: espadachim, atirador, lutador, boxeador, etc.
  final List<String>? weapons; // opcional: lista de armas
  final List<String>? attacks; // opcional: lista de ataques

  FightingStyleModel({
    this.name,
    required this.type,
    this.weapons,
    this.attacks,
  });

  factory FightingStyleModel.fromMap(Map<String, dynamic> map) {
    return FightingStyleModel(
      name: map['name'] as String?,
      type: map['type'] as String,
      weapons: map['weapons'] != null 
          ? List<String>.from(map['weapons'] as List)
          : null,
      attacks: map['attacks'] != null 
          ? List<String>.from(map['attacks'] as List)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'weapons': weapons,
      'attacks': attacks,
    };
  }

  FightingStyleModel copyWith({
    String? name,
    String? type,
    List<String>? weapons,
    List<String>? attacks,
  }) {
    return FightingStyleModel(
      name: name ?? this.name,
      type: type ?? this.type,
      weapons: weapons ?? this.weapons,
      attacks: attacks ?? this.attacks,
    );
  }

  @override
  String toString() {
    return 'FightingStyleModel(name: $name, type: $type, weapons: $weapons, attacks: $attacks)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FightingStyleModel &&
        other.name == name &&
        other.type == type &&
        other.weapons == weapons &&
        other.attacks == attacks;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        type.hashCode ^
        weapons.hashCode ^
        attacks.hashCode;
  }
} 