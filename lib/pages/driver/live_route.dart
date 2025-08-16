import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wheres_my_bus/models/route.dart';

class LiveRoute extends StatelessWidget {
  const LiveRoute({super.key, required this.route});
  final BusRoute route;

  void _stopLive() {
    //TODO: handle firebase stuff
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Route ${route.routeNumber}"),
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
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green.shade700,
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
                    onPressed: () {
                      context.pop();
                      _stopLive;
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
    );
  }
}
