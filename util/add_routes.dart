import 'dart:convert';
import 'dart:io';

import 'consts.dart';

// Simple LatLng class since we don't have Flutter here
class LatLng {
  final double latitude;
  final double longitude;
  
  LatLng(this.latitude, this.longitude);
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

// Your API key - replace with your actual key
const String apiKey = MAPS_KEY;

Future<List<LatLng>> getRouteDirectHTTP(List<Map<String, LatLng>> stops) async {
  // Build waypoints string
  String waypoints = '';
  if (stops.length > 2) {
    List<String> waypointStrings = [];
    for (int i = 1; i < stops.length - 1; i++) {
      LatLng stop = stops[i].values.first;
      waypointStrings.add('${stop.latitude},${stop.longitude}');
    }
    waypoints = '&waypoints=${waypointStrings.join('|')}';
  }
  
  LatLng origin = stops.first.values.first;
  LatLng destination = stops.last.values.first;
  
  String url = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=transit'
      '&key=$apiKey';
  
  print('Making request to: ${url.replaceAll(apiKey, 'HIDDEN_KEY')}');
  
  try {
    // Using dart:io HttpClient instead of http package
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    
    String responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = json.decode(responseBody);
      
      print('API Status: ${data['status']}');
      
      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
        print('Encoded polyline received, length: ${encodedPolyline.length}');
        return decodePolyline(encodedPolyline);
      } else {
        print('API Error: ${data['error_message'] ?? data['status']}');
      }
    } else {
      print('HTTP Error ${response.statusCode}: $responseBody');
    }
    
    client.close();
    return [];
  } catch (e) {
    print('Request Error: $e');
    return [];
  }
}

// Decode Google's encoded polyline
List<LatLng> decodePolyline(String encoded) {
  List<LatLng> points = [];
  int index = 0;
  int len = encoded.length;
  int lat = 0;
  int lng = 0;

  while (index < len) {
    int shift = 0;
    int result = 0;
    int b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }

  return points;
}

Future<void> writePointsToFile(List<LatLng> points, String filename) async {
  try {
    // Also save as CSV for easy viewing
    File csvFile = File(filename.replaceAll('.json', '.csv'));
    StringBuffer csv = StringBuffer();
    
    for (int i = 0; i < points.length; i++) {
      csv.writeln('${points[i].longitude},${points[i].latitude}');
    }
    
    await csvFile.writeAsString(csv.toString());
    print('📊 CSV saved to: ${csvFile.absolute.path}');
    
  } catch (e) {
    print('❌ Error writing to file: $e');
  }
}

Future<void> main() async {
  print('Starting polyline generation...');
  
  // Your bus stops
  List<Map<String, LatLng>> stops = [
    {"Papine": LatLng(18.015712012390487, -76.74199385681973)},
    {"Half-Way-Tree": LatLng(18.012423122990608, -76.79794965287095)},
    {"Six Miles": LatLng(18.02341162226285, -76.87735609676983)},
  ];
  
  print('Stops:');
  for (var stop in stops) {
    print('  ${stop.keys.first}: ${stop.values.first}');
  }
  
  List<LatLng> polylinePoints = await getRouteDirectHTTP(stops);
  
  if (polylinePoints.isNotEmpty) {
    print('\n Success! Generated ${polylinePoints.length} polyline points');
    print('\nFirst 5 points:');
    for (int i = 0; i < 5 && i < polylinePoints.length; i++) {
      print('  Point $i: ${polylinePoints[i]}');
    }
    
    print('\nLast 5 points:');
    int start = polylinePoints.length > 5 ? polylinePoints.length - 5 : 0;
    for (int i = start; i < polylinePoints.length; i++) {
      print('  Point $i: ${polylinePoints[i]}');
    }
    
    // Write points to file
    String filename = 'route_75_polyline.json';
    await writePointsToFile(polylinePoints, filename);
    
  } else {
    print('\n Failed to generate polyline points');
    print('Check your API key and make sure Directions API is enabled');
  }
}