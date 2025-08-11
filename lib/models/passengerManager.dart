import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wheres_my_bus/models/passenger.dart';

class Passengermanager {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('passengers');

  Future<void> create(Passenger passenger) async {
    try {
      await _collection.doc(passenger.id).set({
        ...passenger.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create passenger: $e');
    }
  }

   Future<void> updateFavourites(String passengerId, List<String> favourites) async {
    try {
      await _collection.doc(passengerId).update({
        'favouriteRoutes': favourites,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update favourites: $e');
    }
  }
}
