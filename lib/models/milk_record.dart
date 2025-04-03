class MilkRecord {
  final String id;
  final DateTime milkingDate;
  final String milkType; // 'Whole Farm' or 'Individual Cow'
  final String? cattleId; // Only used if milkType is 'Individual Cow'
  final double totalMilk; // In liters
  final String? notes;

  MilkRecord({
    required this.id,
    required this.milkingDate,
    required this.milkType,
    this.cattleId,
    required this.totalMilk,
    this.notes,
  });

  // Convert MilkRecord object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'milkingDate': milkingDate.toIso8601String(),
      'milkType': milkType,
      'cattleId': cattleId,
      'totalMilk': totalMilk,
      'notes': notes,
    };
  }

  // Create a MilkRecord object from a JSON map
  factory MilkRecord.fromJson(Map<String, dynamic> json) {
    return MilkRecord(
      id: json['id'],
      milkingDate: DateTime.parse(json['milkingDate']),
      milkType: json['milkType'],
      cattleId: json['cattleId'],
      totalMilk: json['totalMilk'].toDouble(),
      notes: json['notes'],
    );
  }
} 