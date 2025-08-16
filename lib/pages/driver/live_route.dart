import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException;
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/models/driverManager.dart';
import 'package:wheres_my_bus/models/route.dart';
import "package:wheres_my_bus/util/exceptions.dart"
    show LocationPermissionException, LocationServiceDisabledException;

class LiveRoute extends StatefulWidget {
  const LiveRoute({super.key, required this.route});
  final BusRoute route;

  @override
  State<LiveRoute> createState() => _LiveRouteState();
}

class _LiveRouteState extends State<LiveRoute> {
  final Drivermanager _driverManager = Drivermanager();
  bool _isStreaming = false;
  final String driverId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  @override
  void dispose() {
    _stopLiveTracking();
    super.dispose();
  }

  Future<void> _startLiveTracking() async {
    try {
      setState(() => _isStreaming = true);
      await _driverManager.startLocationStreaming(driverId, widget.route.routeNumber);
    } on LocationServiceDisabledException catch (e) {
      if (mounted) {
        setState(() => _isStreaming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                Geolocator.openLocationSettings();
                context.pop();
              },
            ),
          ),
        );
      }
    } on LocationPermissionException catch (e) {
      if (mounted) {
        setState(() => _isStreaming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            action:
                e.isPermanentlyDenied
                    ? SnackBarAction(
                      label: 'Settings',
                      onPressed: () {
                        Geolocator.openLocationSettings();
                        context.pop();
                      },
                    )
                    : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isStreaming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start live tracking: $e'), backgroundColor: Colors.red),
        );
        context.pop();
      }
    }
  }

  Future<void> _stopLiveTracking() async {
    try {
      await _driverManager.stopLiveTracking(driverId);
      setState(() => _isStreaming = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isStreaming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop live tracking: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: const Text('End Live Location?'),
                content: const Text(
                  'Are you sure you want to stop sharing your live location? Passengers will no longer see updates.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('End Live'),
                  ),
                ],
              ),
        ) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false, // Prevent immediate pop
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return; // If already popped, don't show dialog

        final shouldPop = await _showExitDialog(context);
        if (shouldPop && context.mounted) {
          _stopLiveTracking();
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Route ${widget.route.routeNumber}"),
          backgroundColor: colorScheme.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                context.push('/profile');
              },
            ),
          ],
        ),
        drawer: Drawer(backgroundColor: Theme.of(context).scaffoldBackgroundColor),
        body: SafeArea(
          child: Column(
            children: [
              // Fixed header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(9),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isStreaming ? Colors.green.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isStreaming ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isStreaming ? 'LIVE' : 'CONNECTING...',
                      style: TextStyle(
                        color: _isStreaming ? Colors.green.shade700 : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Talk to your passengers",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Expandable grid section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
                        onPressed: () {},
                        child: const Text(
                          "Depart",
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[500]),
                        onPressed: () {},
                        child: const Text(
                          "Full Bus",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                        onPressed: () {},
                        child: const Text(
                          "Report Road Closure",
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        onPressed: () {},
                        child: const Text(
                          "Settings",
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed bottom section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final shouldStop = await _showExitDialog(context);
                        if (shouldStop && context.mounted) {
                          _stopLiveTracking();
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stop, size: 28),
                          const SizedBox(width: 5),
                          const Text(
                            'End Live Location',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
