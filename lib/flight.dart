class Flight {
  int? id;
  String departureCity;
  String destinationCity;
  String departureTime;
  String arrivalTime;

  Flight({
    this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departureCity': departureCity,
      'destinationCity': destinationCity,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
    };
  }

  factory Flight.fromMap(Map<String, dynamic> map) {
    return Flight(
      id: map['id'],
      departureCity: map['departureCity'],
      destinationCity: map['destinationCity'],
      departureTime: map['departureTime'],
      arrivalTime: map['arrivalTime'],
    );
  }

  Flight copyWith({
    int? id,
    String? departureCity,
    String? destinationCity,
    String? departureTime,
    String? arrivalTime,
  }) {
    return Flight(
      id: id ?? this.id,
      departureCity: departureCity ?? this.departureCity,
      destinationCity: destinationCity ?? this.destinationCity,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }
}