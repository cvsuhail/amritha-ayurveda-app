class Treatment {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final int? duration; // in minutes
  final bool isActive;
  
  // For local tracking in the register form
  int maleCount;
  int femaleCount;

  Treatment({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.duration,
    this.isActive = true,
    this.maleCount = 0,
    this.femaleCount = 0,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: _parsePrice(json['price']),
      duration: _parseDuration(json['duration']),
      isActive: json['is_active'] ?? true,
      maleCount: json['male_count'] ?? 0,
      femaleCount: json['female_count'] ?? 0,
    );
  }

  static double? _parsePrice(dynamic price) {
    if (price == null) return null;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price);
    }
    return null;
  }

  static int? _parseDuration(dynamic duration) {
    if (duration == null) return null;
    if (duration is int) return duration;
    if (duration is String) {
      // Try to extract numbers from strings like "15 minutes"
      final match = RegExp(r'\d+').firstMatch(duration);
      return match != null ? int.tryParse(match.group(0)!) : null;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'is_active': isActive,
      'male_count': maleCount,
      'female_count': femaleCount,
    };
  }

  // Create a copy with updated counts
  Treatment copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? duration,
    bool? isActive,
    int? maleCount,
    int? femaleCount,
  }) {
    return Treatment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      maleCount: maleCount ?? this.maleCount,
      femaleCount: femaleCount ?? this.femaleCount,
    );
  }

  @override
  String toString() {
    return 'Treatment{id: $id, name: $name, maleCount: $maleCount, femaleCount: $femaleCount}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Treatment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
