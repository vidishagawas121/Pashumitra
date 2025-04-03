class FeedCost {
  final String id;
  final DateTime date;
  final String feedType;
  final double quantity;
  final String quantityUnit; // 'kg', 'bags', etc.
  final double costPerUnit;
  final double totalCost;
  final String? notes;

  FeedCost({
    required this.id,
    required this.date,
    required this.feedType,
    required this.quantity,
    required this.quantityUnit,
    required this.costPerUnit,
    required this.totalCost,
    this.notes,
  });

  // Convert FeedCost object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'feedType': feedType,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'costPerUnit': costPerUnit,
      'totalCost': totalCost,
      'notes': notes,
    };
  }

  // Create a FeedCost object from a JSON map
  factory FeedCost.fromJson(Map<String, dynamic> json) {
    return FeedCost(
      id: json['id'],
      date: DateTime.parse(json['date']),
      feedType: json['feedType'],
      quantity: json['quantity'].toDouble(),
      quantityUnit: json['quantityUnit'],
      costPerUnit: json['costPerUnit'].toDouble(),
      totalCost: json['totalCost'].toDouble(),
      notes: json['notes'],
    );
  }
} 