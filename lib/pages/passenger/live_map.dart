import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wheres_my_bus/models/driver.dart';
import 'package:wheres_my_bus/models/driverManager.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/models/routeManager.dart';
import 'package:wheres_my_bus/widgets/floating_route_search.dart';
import 'package:geolocator/geolocator.dart';

class LiveMap extends StatefulWidget {
  const LiveMap({super.key});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  GoogleMapController? mapController; // Made nullable
  String? _errorMessage;
  bool _permissionsChecked = false;
  Stream<Position>? _positionStream;
  List<LatLng> polylineCoords = [];
  CameraPosition? _lastCameraPosition;
  Map<String, int> _routeBusIndex = {}; // Track current bus index for each route

  final Set<Marker> _driverMarkers = {};
  final Drivermanager _driverManager = Drivermanager();
  StreamSubscription<List<Driver>>? _driversSubscription;
  final RouteManager _routeManager = RouteManager();
  List<BusRoute> routes = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStartStream();
    _fetchRoutes();
  }

  @override
  void dispose() {
    _driversSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchRoutes() async {
    final newRoutes = await _routeManager.getAll();
    updateRoutes(newRoutes);
  }

  void updateRoutes(List<BusRoute> newRoutes) {
    setState(() {
      routes = newRoutes;
    });
    _listenToLiveDrivers(); // Restart stream with new routes
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _lastCameraPosition = position;
  }

  Future<void> _goToCurrentLocation() async {
    if (mapController == null) return; // Guard clause

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
      );

      final tilt = _lastCameraPosition?.tilt ?? 0;
      final zoom = _lastCameraPosition?.zoom ?? 17;
      final bearing = _lastCameraPosition?.bearing ?? 0;

      // Move camera to current location
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: zoom,
            tilt: tilt,
            bearing: bearing,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Route saved')));
      }
    }
  }

  Future<void> _checkPermissionsAndStartStream() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable location services.';
          _permissionsChecked = true;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied. Please grant location access.';
            _permissionsChecked = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied. Please enable them in app settings.';
          _permissionsChecked = true;
        });
        return;
      }

      // Permissions granted, start location stream
      setState(() {
        _positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Update every 10 meters
          ),
        );
        _permissionsChecked = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking permissions: $e';
        _permissionsChecked = true;
      });
    }
  }

  void _listenToLiveDrivers() {
    _driversSubscription?.cancel();

    if (routes.isEmpty) return; // Don't start if no routes

    _driversSubscription = _driverManager
        .getLiveDriversForRoutes(routes.map((route) => route.routeNumber).toList())
        .listen(
          (drivers) {
            _updateDriverMarkers(drivers);
          },
          onError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error tracking buses: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
  }

  void _updateDriverMarkers(List<Driver> drivers) {
    // Clear existing driver markers
    _driverMarkers.clear();

    // Add new driver markers
    for (Driver driver in drivers) {
      if (driver.location != null) {
        final driverMarker = Marker(
          markerId: MarkerId('driver_${driver.id}'),
          position: driver.location!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Route ${driver.activeRoute}',
            snippet: 'Live Bus Location',
          ),
        );

        _driverMarkers.add(driverMarker);
      }
    }

    setState(() {}); // Trigger rebuild to show updated markers
  }

  Set<Polyline> generatePolylinesFromRoutes() {
    Set<Polyline> polylines = {};

    for (BusRoute route in routes) {
      if (route.polylinePoints.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('route_${route.routeNumber}'),
            points: route.polylinePoints,
            width: 5,
            color: route.color,
            geodesic: true,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
            consumeTapEvents: true,
            onTap: () => debugPrint('Tapped ${route.routeNumber}'),
          ),
        );
      }
    }

    return polylines;
  }

  Set<Marker> _generateStopMarkers() {
    Set<Marker> markers = {};

    for (BusRoute route in routes) {
      route.stops.forEach((stopName, stopLocation) {
        HSVColor hsvColor = HSVColor.fromColor(route.color);
        markers.add(
          Marker(
            markerId: MarkerId('${route.routeNumber}_$stopName'),
            position: stopLocation,
            infoWindow: InfoWindow(title: stopName, snippet: 'Route ${route.routeNumber}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(hsvColor.hue),
          ),
        );
      });
    }

    return markers;
  }

  // Combine all markers (stops + drivers)
  Set<Marker> _getAllMarkers() {
    final Set<Marker> allMarkers = {};
    allMarkers.addAll(_generateStopMarkers());
    allMarkers.addAll(_driverMarkers);
    return allMarkers;
  }

  bool _routeHasActiveBuses(String routeNumber) {
    return _driverMarkers.any(
      (marker) => marker.infoWindow.title?.contains('Route $routeNumber') ?? false,
    );
  }

  List<Marker> _getBusesForRoute(String routeNumber) {
    return _driverMarkers
        .where((marker) => marker.infoWindow.title?.contains('Route $routeNumber') ?? false)
        .toList();
  }

  Future<void> _cycleToBusOnRoute(String routeNumber) async {
    if (mapController == null) return;

    final routeBuses = _getBusesForRoute(routeNumber);
    if (routeBuses.isEmpty) return;

    // Get or initialize the current index for this route
    int currentIndex = _routeBusIndex[routeNumber] ?? 0;

    // Cycle to next bus (wrap around if at end)
    currentIndex = (currentIndex + 1) % routeBuses.length;
    _routeBusIndex[routeNumber] = currentIndex;

    final targetBus = routeBuses[currentIndex];
    final busPosition = targetBus.position;

    try {
      final tilt = _lastCameraPosition?.tilt ?? 0;
      final zoom = _lastCameraPosition?.zoom ?? 17;
      final bearing = _lastCameraPosition?.bearing ?? 0;

      // Move camera to selected bus
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: busPosition, zoom: zoom, tilt: tilt, bearing: bearing),
        ),
      );

      // Show which bus we're viewing
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Viewing bus ${currentIndex + 1} of ${routeBuses.length} on Route $routeNumber',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error centering on bus: $e')));
      }
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _permissionsChecked = false;
                });
                _checkPermissionsAndStartStream();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Route',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Route list
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      final hasActiveBuses = _routeHasActiveBuses(route.routeNumber);
                      final busCount = _getBusesForRoute(route.routeNumber).length;

                      return ListTile(
                        enabled: hasActiveBuses,
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: hasActiveBuses ? route.color : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          'Route ${route.routeNumber}',
                          style: TextStyle(
                            color: hasActiveBuses ? null : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          hasActiveBuses
                              ? '$busCount active bus${busCount == 1 ? '' : 'es'}'
                              : 'No active buses',
                          style: TextStyle(color: hasActiveBuses ? null : Colors.grey),
                        ),
                        trailing:
                            hasActiveBuses
                                ? Icon(Icons.directions_bus, color: route.color)
                                : Icon(Icons.directions_bus_outlined, color: Colors.grey),
                        onTap:
                            hasActiveBuses
                                ? () {
                                  Navigator.of(context).pop();
                                  _cycleToBusOnRoute(route.routeNumber);
                                }
                                : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            _errorMessage != null
                ? _buildErrorWidget()
                : !_permissionsChecked
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<Position>(
                  stream: _positionStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.hasData) {
                      final position = snapshot.data!;
                      return GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(position.latitude, position.longitude),
                          zoom: 17.0,
                          tilt: 60.0,
                        ),
                        cameraTargetBounds: CameraTargetBounds(
                          LatLngBounds(
                            northeast: LatLng(18.9065602210206, -75.41288402413825),
                            southwest: LatLng(17.44059194404681, -79.25960397396844),
                          ),
                        ),
                        minMaxZoomPreference: MinMaxZoomPreference(9, 20),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        onCameraMove: (position) => _onCameraMove(position),
                        polylines: generatePolylinesFromRoutes(),
                        markers: _getAllMarkers(), // ← Fixed: Now includes driver markers
                      );
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),

            const FloatingSearch(hint: "Add Routes ..."),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: "routeList", // Add unique hero tag
                    backgroundColor: colorScheme.primary,
                    onPressed: _showRouteList,
                    child: Icon(Icons.list, color: colorScheme.onPrimary),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: "location", // Add unique hero tag
                    backgroundColor: colorScheme.secondary,
                    onPressed: _goToCurrentLocation,
                    child: Icon(
                      Icons.my_location,
                      color: colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
