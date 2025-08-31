import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException;
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/models/routeManager.dart';
import 'dart:async';
import 'driver.dart';
import "package:wheres_my_bus/util/exceptions.dart"
    show LocationPermissionException, LocationServiceDisabledException;

class Drivermanager {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('drivers');
  StreamSubscription<Position>? _locationSubscription;
  final RouteManager _routeManager = RouteManager();

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

  Future<List<BusRoute>> getAssigned(String driverId) async {
    try {
      DocumentSnapshot doc = await _collection.doc(driverId).get();

      if (!doc.exists) {
        throw Exception('Driver not found');
      }

      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      List<dynamic> assignedRouteNumbers = data?['assignedRoutes'] ?? [];

      // Convert to List<String>
      List<String> routeNumbers = assignedRouteNumbers.cast<String>();

      if (routeNumbers.isEmpty) {
        return [];
      }

      // Get all routes from RouteManager
      List<BusRoute> allRoutes = await _routeManager.getAll();

      // Filter to only include favorite routes
      List<BusRoute> assignedRoutes =
          allRoutes.where((route) => routeNumbers.contains(route.routeNumber)).toList();

      return assignedRoutes;
    } catch (e) {
      throw Exception('Failed to get favourite routes: $e');
    }
  }

  Future<void> updateAssigned(String driverId, List<BusRoute> routes) async {
    try {
      await _collection.doc(driverId).update({
        'assignedRoutes': routes.map((route) => route.routeNumber).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update favourites: $e');
    }
  }

  Future<void> setActiveRoute(String driverId, String routeNumber) async {
    try {
      await _collection.doc(driverId).update({
        'activeRoute': routeNumber,
        'isLive': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to set active route: $e');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException(
          'Location services are disabled. Please enable location services in your device settings.',
        );
      }

      // Check current permission status
      permission = await Geolocator.checkPermission();

      // Handle different permission states
      switch (permission) {
        case LocationPermission.denied:
          // Request permission
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw LocationPermissionException(
              'Location permission was denied. Please allow location access to use live tracking.',
            );
          }
          break;

        case LocationPermission.deniedForever:
          throw LocationPermissionException(
            'Location permissions are permanently denied. Please enable location permission in your device settings.',
          );

        case LocationPermission.whileInUse:
        case LocationPermission.always:
          // Permission is granted, continue
          break;

        case LocationPermission.unableToDetermine:
          throw LocationPermissionException('Unable to determine location permission status.');
      }
      return true;
    } catch (e) {
      if (e is LocationServiceDisabledException || e is LocationPermissionException) {
        rethrow; // Re-throw our custom exceptions
      }
      // Handle any unexpected errors
      throw LocationPermissionException('Failed to check location permissions: ${e.toString()}');
    }
  }

  Future<void> startLocationStreaming(String driverId, String routeNumber) async {
    try {
      await _handleLocationPermission();
      await setActiveRoute(driverId, routeNumber);

      const LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high);

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          final location = LatLng(position.latitude, position.longitude);
          updateLocation(driverId, location);
        },
        onError: (error) {
          print('Location stream error: $error');
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  //TODO: will be used for chatrooms I think
  Stream<Driver?> getDriverStream(String driverId) {
    return _collection.doc(driverId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Driver.fromMap(doc.data() as Map<String, dynamic>, documentId: doc.id);
    });
  }

  Future<void> stopLiveTracking(String driverId) async {
    try {
      await _collection.doc(driverId).update({
        'activeRoute': null,
        'isLive': false,
        'location': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      _locationSubscription?.cancel();
    } catch (e) {
      throw Exception('Failed to stop live tracking: $e');
    }
  }

  Stream<List<Driver>> getLiveDriversForRoute(String routeNumber) {
    return _collection
        .where('activeRoute', isEqualTo: routeNumber)
        .where('isLive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Driver.fromMap(doc.data() as Map<String, dynamic>, documentId: doc.id),
                  )
                  .toList(),
        );
  }

  Stream<List<Driver>> getLiveDriversForRoutes(List<String> routeNumbers) {
    if (routeNumbers.isEmpty) {
      return Stream.value([]);
    }

    // If only one route, use the single route method
    if (routeNumbers.length == 1) {
      return getLiveDriversForRoute(routeNumbers.first);
    }

    return _collection
        .where('activeRoute', whereIn: routeNumbers)
        .where('isLive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Driver.fromMap(doc.data() as Map<String, dynamic>, documentId: doc.id),
                  )
                  .toList(),
        );
  }
}
