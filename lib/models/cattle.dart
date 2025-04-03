class Cattle {
  final String id;
  final String tagNumber;
  final String breed;
  final DateTime dateOfBirth;
  final String gender;
  final double weight;
  final String? notes;
  final String? imageUrl;

  Cattle({
    required this.id,
    required this.tagNumber,
    required this.breed,
    required this.dateOfBirth,
    required this.gender,
    required this.weight,
    this.notes,
    this.imageUrl,
  });

  // Convert Cattle object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagNumber': tagNumber,
      'breed': breed,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  // Create a Cattle object from a JSON map
  factory Cattle.fromJson(Map<String, dynamic> json) {
    return Cattle(
      id: json['id'],
      tagNumber: json['tagNumber'],
      breed: json['breed'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      weight: json['weight'].toDouble(),
      notes: json['notes'],
      imageUrl: json['imageUrl'],
    );
  }
} 