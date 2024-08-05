class Airplane {
  int? id;
  String type;
  int numberOfPassengers;
  int maxSpeed;
  int range;

  Airplane({
    this.id,
    required this.type,
    required this.numberOfPassengers,
    required this.maxSpeed,
    required this.range,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'numberOfPassengers': numberOfPassengers,
      'maxSpeed': maxSpeed,
      'range': range,
    };
  }

  factory Airplane.fromMap(Map<String, dynamic> map) {
    return Airplane(
      id: map['id'],
      type: map['type'],
      numberOfPassengers: map['numberOfPassengers'],
      maxSpeed: map['maxSpeed'],
      range: map['range'],
    );
  }

  Airplane copyWith({
    int? id,
    String? type,
    int? numberOfPassengers,
    int? maxSpeed,
    int? range,
  }) {
    return Airplane(
      id: id ?? this.id,
      type: type ?? this.type,
      numberOfPassengers: numberOfPassengers ?? this.numberOfPassengers,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      range: range ?? this.range,
    );
  }
}
