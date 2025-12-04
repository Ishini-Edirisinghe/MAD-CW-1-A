class HealthRecord {
  int? id;
  String date;
  int steps;
  int calories;
  int water;

  HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  // Convert model → Map (for database insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'steps': steps,
      'calories': calories,
      'water': water,
    };
  }

  // Convert Map → Model (for reading from database)
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      date: map['date'],
      steps: map['steps'],
      calories: map['calories'],
      water: map['water'],
    );
  }
}
