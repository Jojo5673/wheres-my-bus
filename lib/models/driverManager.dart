import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'driver.dart';

class Drivermanager {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('drivers');

  Future<void> create(Driver driver) async {
    try {
      await _collection.doc(driver.id).set({
        ...driver.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create driver: $e');
    }
  }

  Future<Driver?> getById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Driver.fromMap(
          doc.data() as Map<String, dynamic>,
          documentId: doc.id, // Use document ID
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get driver: $e');
    }
  }

  Future<void> update(Driver driver) async {
    try {
      await _collection.doc(driver.id).update({
        ...driver.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update driver: $e');
    }
  }

  Future<void> updateLocation(String driverId, LatLng location) async {
    try {
      await _collection.doc(driverId).update({
        'location': {'latitude': location.latitude, 'longitude': location.longitude},
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update driver location: $e');
    }
  }

  //change to watch a list of routes
  Stream<List<Driver>> watchActive() {
    return _collection
        .where('activeRoute', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Driver.fromMap(
                      doc.data() as Map<String, dynamic>,
                      documentId: doc.id, // Use document ID
                    ),
                  )
                  .toList(),
        );
  }

  //TODO: watch for location
}
