import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  _PassengerHomeState createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _favoriteRoutes = [];

  void _addRouteToFavorites(String route) {
    if (route.isNotEmpty && !_favoriteRoutes.contains(route)) {
      setState(() {
        _favoriteRoutes.add(route);
      });
    }
    _searchController.clear();
  }

  void _removeRoute(String route) {
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
        title: Text("Passenger Dashboard"),
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
            Text(
              "Welcome, Passenger!",
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: "Search bus routes...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          _addRouteToFavorites(_searchController.text.trim());
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Text(
              "Favourite Routes:",
              style: textTheme.bodyMedium,
            ),
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
                              title: Text(
                                route,
                                style: textTheme.bodyMedium,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
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
          // TODO: Navigate to maps page
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Maps tapped!')));
        },
        backgroundColor: colorScheme.secondary,
        child: Icon(Icons.map, color: colorScheme.onSecondary),
      ),
    );
  }
}
