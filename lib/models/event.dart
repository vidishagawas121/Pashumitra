class Event {
  final String id;
  final String cattleId;
  final DateTime eventDate;
  final String eventType; // 'Vaccination', 'Heat Cycle', 'Pregnancy'
  final String? notes;

  Event({
    required this.id,
    required this.cattleId,
    required this.eventDate,
    required this.eventType,
    this.notes,
  });

  // Convert Event object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cattleId': cattleId,
      'eventDate': eventDate.toIso8601String(),
      'eventType': eventType,
      'notes': notes,
    };
  }

  // Create an Event object from a JSON map
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      cattleId: json['cattleId'],
      eventDate: DateTime.parse(json['eventDate']),
      eventType: json['eventType'],
      notes: json['notes'],
    );
  }
} 