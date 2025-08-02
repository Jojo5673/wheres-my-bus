import 'package:flutter/material.dart';

class PassengerPage extends StatefulWidget {
  const PassengerPage({Key? key}) : super(key: key);

  @override
  _PassengerPageState createState() => _PassengerPageState();
}

class _PassengerPageState extends State<PassengerPage> {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Passenger Dashboard"),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Passenger!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search bus routes...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[900],
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

            const Text(
              "Favourite Routes:",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 10),

            Expanded(
              child:
                  _favoriteRoutes.isEmpty
                      ? const Center(
                        child: Text(
                          "No favourite routes yet.",
                          style: TextStyle(color: Colors.grey),
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
                                style: const TextStyle(color: Colors.white),
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
          // TODO: Navigate to settings page
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Settings tapped!')));
        },
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.settings, color: Colors.black),
      ),
    );
  }
}
