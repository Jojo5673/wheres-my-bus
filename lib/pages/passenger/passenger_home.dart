import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/models/passengerManager.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/widgets/route_search.dart';
import 'package:wheres_my_bus/models/passenger.dart'; // For Passenger class
import 'package:wheres_my_bus/pages/passenger/passenger_feed.dart'; // For PassengerFeed widget

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  List<BusRoute> _favoriteRoutes = [];
  final Passengermanager _passengermanager = Passengermanager();
  final passengerId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _getRoutes();
  }

  Future<void> _getRoutes() async {
    final newRoutes = await _passengermanager.getFavourites(passengerId);
    setState(() {
      _favoriteRoutes = newRoutes;
    });
  }

  void _addRouteToFavorites(BusRoute route) {
    if (!_favoriteRoutes.contains(route)) {
      setState(() {
        _favoriteRoutes.add(route);
      });
      _passengermanager.updateFavourites(passengerId, _favoriteRoutes);
    }
  }

  void _removeRoute(BusRoute route) {
    setState(() {
      _favoriteRoutes.remove(route);
    });
    _passengermanager.updateFavourites(passengerId, _favoriteRoutes);
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

            const SizedBox(height: 20),


        Row(
            children: [
              const Expanded(child: Divider(thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Driver Messages",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Expanded(child: Divider(thickness: 1)),
            ],
          ),

          const SizedBox(height: 10),

        
          Expanded(
            flex: 2,
            child: PassengerFeed(
              routes: _favoriteRoutes.map((r) => r.routeNumber).toList(),
            ),
          ),
        ],
      ),
    ),

      

      // Settings floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push("/passenger/map", extra: _favoriteRoutes);
        },
        backgroundColor: colorScheme.secondary,
        child: Icon(Icons.map, color: colorScheme.onSecondary),
      ),
    );
  }
}
