
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/widgets/route_search.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  BusRoute? selectedRoute;
  bool isLive = false;
  List<BusRoute> assignedRoutes = [];

  void _handleRouteSelect(BusRoute route) {
    setState(() {
      selectedRoute = selectedRoute == route? null: route;
      isLive = false; // Reset live status when changing routes
    });
  }

  void addRoute(BusRoute route) {
    if (!assignedRoutes.contains(route)) {
      setState(() {
        assignedRoutes.add(route);
      });
    }
  }

  void removeRoute(BusRoute route) {
    setState(() {
      assignedRoutes.remove(route);
      selectedRoute = selectedRoute == route? null: route;
      isLive = false;
    });
  }

  void _goLive() {
    if (selectedRoute != null) {
      setState(() {
        isLive = true;
      });
      //TODO: implement going live
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚌 Now live on ${selectedRoute!.routeNumber}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _stopLive() {
    setState(() {
      isLive = false;
    });
    //TODO: implement stopping live inside to live page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🛑 Stopped live tracking'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: Drawer(backgroundColor: Theme.of(context).scaffoldBackgroundColor),
      appBar: AppBar(
        title: Text("Your Routes"),
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
      body: SafeArea(
        child: Column(
          children: [
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
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.green : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: isSelected ? const Color.fromARGB(255, 189, 202, 212) : Colors.grey[300],
                          ),
                          child: Stack(
                            children: [
                              // Route info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        route.routeNumber,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.blue.shade700 : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${route.stops.length} stops',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    route.stops.keys.toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          isSelected
                                              ? Colors.blue.shade600
                                              : Colors.grey.shade600,
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
              child: SafeArea(
                child:
                    !isLive
                        ? ElevatedButton(
                          onPressed: selectedRoute != null ? _goLive : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                selectedRoute != null ? Colors.green : Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: selectedRoute != null ? 4 : 0,
                          ),
                          child: Text(
                            selectedRoute != null ? 'Go Live' : 'Select a Route First',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                        : Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 1000),
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'LIVE - ${selectedRoute!.routeNumber}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _stopLive,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                '🛑 Stop Live Tracking',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
