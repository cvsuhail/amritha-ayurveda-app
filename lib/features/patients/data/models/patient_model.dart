class PatientModel {
  final String id;
  final String name;
  final String packageDescription;
  final DateTime date;
  final String assignedPerson;
  final bool isCompleted;
  final String? patientdetailsSet;
  final String? address;
  final String? phone;
  final String? whatsapp;
  final String? totalAmount;
  final String? discountAmount;
  final String? advanceAmount;
  final String? balanceAmount;

  const PatientModel({
    required this.id,
    required this.name,
    required this.packageDescription,
    required this.date,
    required this.assignedPerson,
    this.isCompleted = false,
    this.patientdetailsSet,
    this.address,
    this.phone,
    this.whatsapp,
    this.totalAmount,
    this.discountAmount,
    this.advanceAmount,
    this.balanceAmount,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse the date from various possible formats
      DateTime parsedDate;
      if (json['date_nd_time'] != null) {
        try {
          parsedDate = DateTime.parse(json['date_nd_time'].toString());
        } catch (e) {
          // If parsing fails, use current date
          parsedDate = DateTime.now();
        }
      } else if (json['date'] != null) {
        try {
          parsedDate = DateTime.parse(json['date'].toString());
        } catch (e) {
          parsedDate = DateTime.now();
        }
      } else {
        parsedDate = DateTime.now();
      }

      // Extract treatment name from patientdetails_set
      String treatmentName = '';
      if (json['patientdetails_set'] != null && json['patientdetails_set'] is List && 
          (json['patientdetails_set'] as List).isNotEmpty) {
        final firstTreatment = (json['patientdetails_set'] as List).first;
        if (firstTreatment is Map<String, dynamic>) {
          treatmentName = firstTreatment['treatment_name']?.toString() ?? '';
        }
      }

      return PatientModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        packageDescription: treatmentName.isNotEmpty ? treatmentName : 
                           json['treatment']?.toString() ?? 
                           json['package_description']?.toString() ?? '',
        date: parsedDate,
        assignedPerson: json['assigned_person']?.toString() ?? 
                       json['user']?.toString() ?? 'Unassigned',
        isCompleted: json['is_completed'] ?? false,
        patientdetailsSet: json['patientdetails_set']?.toString(),
        address: json['address']?.toString(),
        phone: json['phone']?.toString(),
        whatsapp: json['whatsapp']?.toString(),
        totalAmount: json['total_amount']?.toString(),
        discountAmount: json['discount_amount']?.toString(),
        advanceAmount: json['advance_amount']?.toString(),
        balanceAmount: json['balance_amount']?.toString(),
      );
    } catch (e) {
      // Return a default patient if parsing completely fails
      return PatientModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown Patient',
        packageDescription: 'Unknown Treatment',
        date: DateTime.now(),
        assignedPerson: 'Unassigned',
      );
    }
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
    String? patientdetailsSet,
    String? address,
    String? phone,
    String? whatsapp,
    String? totalAmount,
    String? discountAmount,
    String? advanceAmount,
    String? balanceAmount,
  }) {
    return PatientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      packageDescription: packageDescription ?? this.packageDescription,
      date: date ?? this.date,
      assignedPerson: assignedPerson ?? this.assignedPerson,
      isCompleted: isCompleted ?? this.isCompleted,
      patientdetailsSet: patientdetailsSet ?? this.patientdetailsSet,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
    );
  }
}
