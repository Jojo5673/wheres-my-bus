import 'package:cloud_firestore/cloud_firestore.dart';
import 'route.dart';

class RouteManager {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('routes');

  Future<void> create(BusRoute route) async {
    try {
      await _collection.doc(route.routeNumber).set({
        ...route.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create route: $e');
    }
  }

  Future<List<BusRoute>> getAll() async {
    try {
      final querySnapshot = await _collection.get();
      return querySnapshot.docs
          .map(
            (doc) => BusRoute.fromMap(
              doc.data() as Map<String, dynamic>,
              documentId: doc.id, // Use document ID
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get all routes: $e');
    }
  }
}
