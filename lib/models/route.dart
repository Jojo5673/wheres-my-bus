import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusRoute {
  String routeNumber;
  Color color;
  List<LatLng> polylinePoints;
  Map<String, LatLng> stops;
  List<String> liveDrivers;

  BusRoute({
    required this.routeNumber,
    required this.color,
    required this.polylinePoints,
    required this.stops,
    required this.liveDrivers,
  });

  Map<String, dynamic> toMap() {
    return {
      'color': color.value, // Store as integer value
      'polylinePoints':
          polylinePoints
              .map((point) => {'latitude': point.latitude, 'longitude': point.longitude})
              .toList(),
      'stops': stops.map(
        (key, latLng) =>
            MapEntry(key, {'latitude': latLng.latitude, 'longitude': latLng.longitude}),
      ),
      'liveDrivers': liveDrivers,
    };
  }

  factory BusRoute.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return BusRoute(
      routeNumber: documentId ?? map['routeNumber'] ?? '',
      color: Color(map['color'] ?? 0xFF000000), // Default to black if null
      polylinePoints:
          (map['polylinePoints'] as List<dynamic>?)
              ?.map((point) => LatLng(point['latitude'] as double, point['longitude'] as double))
              .toList() ??
          [],
      stops:
          (map['stops'] as Map<String, dynamic>?)?.map((key, value) {
            if (value is Map<String, dynamic>) {
              return MapEntry(
                key,
                LatLng(value['latitude'] as double, value['longitude'] as double),
              );
            }
            return MapEntry(key, LatLng(0.0, 0.0)); // fallback
          }) ??
          {},
      liveDrivers: List<String>.from(map['liveDrivers'] ?? []),
    );
  }
}
