import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/widgets/route_search.dart';

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  final List<BusRoute> _favoriteRoutes = [];

  void _addRouteToFavorites(BusRoute route) {
    if (!_favoriteRoutes.contains(route)) {
      setState(() {
        _favoriteRoutes.add(route);
      });
    }
  }

  void _removeRoute(BusRoute route) {
    setState(() {
      _favoriteRoutes.remove(route);
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, Passenger!", style: textTheme.titleMedium),
            const SizedBox(height: 20),
            RouteSearch(selectedHandler: _addRouteToFavorites),
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
