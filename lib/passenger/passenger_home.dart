import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/models/routeManager.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  _PassengerHomeState createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  final TextEditingController _searchController = TextEditingController();
  final List<BusRoute> _favoriteRoutes = [];
  List<BusRoute> routes = [];
  final RouteManager _routeManager = RouteManager();

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    final newRoutes = await _routeManager.getAll();
    setState(() {
      routes = newRoutes;
    });
  }

  void _addRouteToFavorites(BusRoute route) {
    if (!_favoriteRoutes.contains(route)) {
      setState(() {
        _favoriteRoutes.add(route);
      });
    }
    _searchController.clear();
  }

  void _removeRoute(BusRoute route) {
    setState(() {
      _favoriteRoutes.remove(route);
    });
  }

  List<BusRoute> _filterRoutes (query){
     return routes.where((route) {
          bool inrouteNumber = route.routeNumber.contains(query.toLowerCase());
          bool inStops = route.stops.keys.any((key) => key.contains('user'));
          return inrouteNumber || inStops;
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Routes"),
        centerTitle: true,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, Passenger!", style: textTheme.titleMedium),
            const SizedBox(height: 20),

            // // Search bar
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: _searchController,
            //         style: textTheme.bodyMedium,
            //         decoration: InputDecoration(
            //           hintText: "Search bus routes...",
            //           hintStyle: TextStyle(color: Colors.grey[400]),
            //           filled: true,
            //           fillColor: Theme.of(context).scaffoldBackgroundColor,
            //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            //           suffixIcon: IconButton(
            //             icon: const Icon(Icons.search, color: Colors.white),
            //             onPressed: () {
            //               _addRouteToFavorites(_searchController.text.trim());
            //             },
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
TypeAheadField<BusRoute>(
  suggestionsCallback: (search) => _filterRoutes(search),
  builder: (context, controller, focusNode) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'City',
      )
    );
  },
  itemBuilder: (context, route) {
    return ListTile(
      title: Text(route.routeNumber),
    );
  },
  onSelected: (route) {
    _addRouteToFavorites(route);
  }
),

            const SizedBox(height: 30),
            Text("Favourite Routes:", style: textTheme.bodyMedium),
            const SizedBox(height: 10),

            Expanded(
              child:
                  _favoriteRoutes.isEmpty
                      ? Center(
                        child: Text(
                          "No favourite routes yet.",
                          style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _favoriteRoutes.length,
                        itemBuilder: (context, index) {
                          final route = _favoriteRoutes[index];
                          return Card(
                            color: Colors.green[900],
                            child: ListTile(
                              title: Text(route.routeNumber, style: textTheme.bodyMedium),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () => _removeRoute(route),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),

      // Settings floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push("/passenger/map");
        },
        backgroundColor: colorScheme.secondary,
        child: Icon(Icons.map, color: colorScheme.onSecondary),
      ),
    );
  }
}
