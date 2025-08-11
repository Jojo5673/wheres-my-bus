import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wheres_my_bus/widgets/search_bar.dart';
import 'package:geolocator/geolocator.dart';

class LiveMap extends StatefulWidget {
  const LiveMap({super.key});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  late GoogleMapController mapController;
  String? _errorMessage;
  bool _permissionsChecked = false;
  Stream<Position>? _positionStream;
  List<LatLng> polylineCoords = [];
  CameraPosition? _lastCameraPosition;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _lastCameraPosition = position;
  }

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStartStream();
  }

  Future<void> _goToCurrentLocation() async {
    // Get current location

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    );

    final tilt = _lastCameraPosition?.tilt ?? 0;
    final zoom = _lastCameraPosition?.zoom ?? 17;
    final bearing = _lastCameraPosition?.bearing ?? 0;

    // Move camera to current location
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: zoom,
          tilt: tilt,
          bearing: bearing,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            child:
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
                            myLocationEnabled: true,
                            trafficEnabled: true,
                            myLocationButtonEnabled: true,
                            compassEnabled: false,
                            zoomControlsEnabled: false,
                            onCameraMove: (position) => _onCameraMove(position),
                            markers: <Marker>{
                              Marker(
                                markerId: const MarkerId('user_location'),
                                position: LatLng(position.latitude, position.longitude),
                                icon: BitmapDescriptor.defaultMarker,
                              ),
                            },
                            polylines: {
                              Polyline(
                                // Polyline id must be unique.
                                polylineId: PolylineId('titanic route'),
                                points: [
                                  LatLng(50.90, -1.41), // Southampton
                                  LatLng(49.65, -1.60), // Cherbourg
                                  LatLng(49.77, -6.71),
                                  LatLng(51.83, -8.28), // Cobh
                                  LatLng(50.96, -8.58),
                                  LatLng(41.75, -49.90), // Wreck
                                ],
                                width: 5,
                                color: Colors.red,
                                geodesic: true,
                                // Custom caps and joint types aren't supported on all platforms.
                                startCap: Cap.roundCap,
                                endCap: Cap.roundCap,
                                jointType: JointType.round,
                                consumeTapEvents: true,
                                onTap: () => debugPrint('clicked route'),
                              ),
                            },
                          );
                        }

                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
          ),

          const FloatingSearch(),
          Positioned(
            bottom: 70, // Custom position
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _goToCurrentLocation,
              child: Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
