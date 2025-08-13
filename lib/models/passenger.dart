
class Passenger {
  String id;
  List<String> favouriteRoutes; // Route numbers

  Passenger({required this.id, required this.favouriteRoutes});

  Map<String, dynamic> toMap() {
    return {'favouriteRoutes': favouriteRoutes};
  }

  factory Passenger.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Passenger(
      id: documentId ?? map['id'] ?? '',
      favouriteRoutes: List<String>.from(map['favouriteRoutes'] ?? []),
    );
  }
}
