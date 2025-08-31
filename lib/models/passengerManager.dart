import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wheres_my_bus/models/passenger.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/models/routeManager.dart';

class Passengermanager {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('passengers');
  final RouteManager _routeManager = RouteManager();
  
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

    Future<List<BusRoute>> getFavourites(String passengerId) async {
    try {
      DocumentSnapshot doc = await _collection.doc(passengerId).get();
      
      if (!doc.exists) {
        throw Exception('Passenger not found');
      }
      
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      List<dynamic> favouriteRouteNumbers = data?['favouriteRoutes'] ?? [];
      
      // Convert to List<String>
      List<String> routeNumbers = favouriteRouteNumbers.cast<String>();
      
      if (routeNumbers.isEmpty) {
        return [];
      }
      
      // Get all routes from RouteManager
      List<BusRoute> allRoutes = await _routeManager.getAll();
      
      // Filter to only include favorite routes
      List<BusRoute> favouriteRoutes = allRoutes
          .where((route) => routeNumbers.contains(route.routeNumber))
          .toList();
      
      return favouriteRoutes;
    } catch (e) {
      throw Exception('Failed to get favourite routes: $e');
    }
  }


   Future<void> updateFavourites(String passengerId, List<BusRoute> favourites) async {
    try {
      await _collection.doc(passengerId).update({
        'favouriteRoutes': favourites.map((route) => route.routeNumber).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update favourites: $e');
    }
  }

}
