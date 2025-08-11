import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Driver {
  String id;
  List<String> assignedRoutes; // Route numbers
  LatLng? location;
  String? activeRoute;

  Driver({required this.id, required this.assignedRoutes, this.location, this.activeRoute});

  Map<String, dynamic> toMap() {
    return {
      'assignedRoutes': assignedRoutes,
      'location':
          location != null
              ? {'latitude': location!.latitude, 'longitude': location!.longitude}
              : null,
      'activeRoute': activeRoute,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Driver(
      id: documentId ?? map['id'] ?? '',
      assignedRoutes: List<String>.from(map['assignedRoutes'] ?? []),
      location:
          map['location'] != null
              ? LatLng(
                map['location']['latitude'] as double,
                map['location']['longitude'] as double,
              )
              : null,
      activeRoute: map['activeRoute'] as String?,
    );
  }
}
