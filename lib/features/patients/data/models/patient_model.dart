class PatientModel {
  final String id;
  final String name;
  final String packageDescription;
  final DateTime date;
  final String assignedPerson;
  final bool isCompleted;

  const PatientModel({
    required this.id,
    required this.name,
    required this.packageDescription,
    required this.date,
    required this.assignedPerson,
    this.isCompleted = false,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      packageDescription: json['package_description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      assignedPerson: json['assigned_person'] ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'package_description': packageDescription,
      'date': date.toIso8601String(),
      'assigned_person': assignedPerson,
      'is_completed': isCompleted,
    };
  }

  PatientModel copyWith({
    String? id,
    String? name,
    String? packageDescription,
    DateTime? date,
    String? assignedPerson,
    bool? isCompleted,
  }) {
    return PatientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      packageDescription: packageDescription ?? this.packageDescription,
      date: date ?? this.date,
      assignedPerson: assignedPerson ?? this.assignedPerson,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
