class Branch {
  final int id;
  final String name;
  final String? location;
  final String? phone;
  final String? email;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    this.location,
    this.phone,
    this.email,
    this.isActive = true,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'],
      phone: json['phone'],
      email: json['email'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'phone': phone,
      'email': email,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'Branch{id: $id, name: $name, location: $location}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Branch &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
