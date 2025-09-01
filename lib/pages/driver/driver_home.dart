import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/models/driverManager.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/widgets/route_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //for messages abt route

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  BusRoute? selectedRoute;
  List<BusRoute> assignedRoutes = [];
  final Drivermanager _drivermanager = Drivermanager();
  final driverId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _getRoutes();
  }

  Future<void> _getRoutes() async {
    final newRoutes = await _drivermanager.getAssigned(driverId);
    setState(() {
      assignedRoutes = newRoutes;
    });
  }

  void _handleRouteSelect(BusRoute route) {
    setState(() {
      selectedRoute =
          selectedRoute == route ? null : route; // Reset live status when changing routes
    });
  }

  void addRoute(BusRoute route) {
    if (!assignedRoutes.any((assignedRoute) => assignedRoute.routeNumber == route.routeNumber)) {
      setState(() {
        assignedRoutes.add(route);
      });
      _drivermanager.updateAssigned(driverId, assignedRoutes);
    }
  }

  void removeRoute(BusRoute route) {
    setState(() {
      assignedRoutes.remove(route);
      selectedRoute = selectedRoute == route ? null : route;
    });
    _drivermanager.updateAssigned(driverId, assignedRoutes);
  }

  Future<void> _goLive() async {
    if (selectedRoute != null) {
      // Add Firestore "driver went live" message
      await FirebaseFirestore.instance.collection('route_messages').add({
        'routeNumber': selectedRoute!.routeNumber,
        'message': 'Driver is now live on route ${selectedRoute!.routeNumber}',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Navigate to live map screen
      context.push("/driver/live", extra: selectedRoute);

      setState(() {
        selectedRoute = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Your Routes"),
          backgroundColor: colorScheme.primary,
           leading: IconButton(
        icon: const Icon(Icons.info_outline, color: Colors.white),
        onPressed: () {
          context.push('/info');
          },
         ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                context.push('/profile');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Welcome, Driver!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RouteSearch(selectedHandler: addRoute),
              ),
              // Route List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: assignedRoutes.length,
                  itemBuilder: (context, index) {
                    final route = assignedRoutes[index];
                    final isSelected = selectedRoute?.routeNumber == route.routeNumber;
      
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        elevation: isSelected ? 8 : 2,
                        shadowColor: isSelected ? Colors.blue.withOpacity(0.3) : Colors.black12,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _handleRouteSelect(route),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.green : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color:
                                  isSelected
                                      ? const Color.fromARGB(255, 189, 202, 212)
                                      : Colors.grey[300],
                            ),
                            child: Stack(
                              children: [
                                // Route info
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      route.routeNumber,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.blue.shade700 : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '${route.stops.length} stops',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                    Text(
                                      route.stops.keys.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
      
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 24,
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => removeRoute(route),
                                      style: IconButton.styleFrom(
                                        foregroundColor: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      
              // Action Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child:
                    selectedRoute != null
                        ? ElevatedButton(
                          onPressed: _goLive,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          child: Text(
                            'Go Live',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
