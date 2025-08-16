import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wheres_my_bus/util/firebase_options.dart';
import 'package:wheres_my_bus/models/routeManager.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'consts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route Admin',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RouteAdminScreen(),
    );
  }
}

class RouteAdminScreen extends StatefulWidget {
  const RouteAdminScreen({super.key});

  @override
  State<RouteAdminScreen> createState() => _RouteAdminScreenState();
}

class _RouteAdminScreenState extends State<RouteAdminScreen> {
  final _routeNumberController = TextEditingController();
  bool _isSaving = false;

  final RouteManager _routeManager = RouteManager();

  final List<Color> presetColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.teal,
  ];

  Color selectedColor = Colors.blue;
  // Stops: list of maps with keys: name, lat, lng
  List<Map<String, dynamic>> stops = [
    {"name": "", "lat": "", "lng": ""},
  ];

  void _addStop() {
    setState(() {
      stops.add({"name": "", "lat": "", "lng": ""});
    });
  }

  void _removeStop(int index) {
    setState(() {
      stops.removeAt(index);
    });
  }

  Future<void> _saveRoute() async {
    setState(() => _isSaving = true);

    try {
      Map<String, LatLng> parsedStops = {};
      for (var stop in stops) {
        final name = stop['name'].toString().trim();
        final lat = double.parse(stop['lat'].toString());
        final lng = double.parse(stop['lng'].toString());
        parsedStops[name] = LatLng(lat, lng);
      }

      // For polyline service, you'll need just the LatLng points
      List<LatLng> polylinePoints = await PolylineService.getRoute(parsedStops);

      final route = BusRoute(
        routeNumber: _routeNumberController.text.trim(),
        color: selectedColor,
        polylinePoints: polylinePoints,
        stops: parsedStops, // Now this matches Map<String, LatLng>
      );

      await _routeManager.create(route);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Route saved')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error parsing stops or saving route: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Admin Console')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            TextField(
              controller: _routeNumberController,
              decoration: const InputDecoration(labelText: 'Route Number'),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pick Route Color', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      presetColors.map((color) {
                        bool isSelected = color == selectedColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(width: 3, color: Colors.black) : null,
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Stops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Dynamic list of stop input fields
            ...stops.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> stop = entry.value;

              return Padding(
                key: ValueKey(index),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Name'),
                        onChanged: (val) => stop['name'] = val,
                        controller: TextEditingController(text: stop['name']),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Latitude'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) => stop['lat'] = val,
                        controller: TextEditingController(text: stop['lat']),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Longitude'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) => stop['lng'] = val,
                        controller: TextEditingController(text: stop['lng']),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: stops.length > 1 ? () => _removeStop(index) : null,
                    ),
                  ],
                ),
              );
            }).toList(),

            TextButton.icon(
              onPressed: _addStop,
              icon: const Icon(Icons.add),
              label: const Text('Add Stop'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isSaving ? null : _saveRoute,
              child: _isSaving ? const CircularProgressIndicator() : const Text('Save Route'),
            ),
          ],
        ),
      ),
    );
  }
}

class PolylineService {
  static Future<List<LatLng>> getRoute(Map<String, LatLng> stops) async {
  List<LatLng> stopPoints = stops.values.toList();
  print(stops);
  
  String waypoints = '';
  if (stopPoints.length > 2) {
    waypoints = '&waypoints=${stopPoints.sublist(1, stopPoints.length - 1)
        .map((point) => '${point.latitude},${point.longitude}').join('|')}';
  }

  LatLng origin = stopPoints.first;
  LatLng destination = stopPoints.last;

  final url =
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}$waypoints&mode=driving&key=$MAPS_KEY';

  try {
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
        return _decodePolyline(encodedPolyline);
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

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
