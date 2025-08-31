import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wheres_my_bus/models/passenger.dart';
import 'package:wheres_my_bus/models/route.dart';

class PassengerFeed extends StatefulWidget {
  final List<String> routes;
  final int perQueryLimit;

  const PassengerFeed({super.key, required this.routes, this.perQueryLimit = 50});

  @override
  State<PassengerFeed> createState() => _PassengerFeedState();
}

class _PassengerFeedState extends State<PassengerFeed> {
  List<List<String>> _chunk(List<String> list, int size) {
    final chunks = <List<String>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }

  @override
Widget build(BuildContext context) {
  final favs = widget.routes;

  if (favs.isEmpty) {
    return const Center(child: Text("No favourite routes selected"));
  }

  if (favs.length <= 10) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('drivers')
          .where('isLive', isEqualTo: true)
          .snapshots(),
      builder: (context, driverSnapshot) {
        if (driverSnapshot.hasError) {
          return Center(child: Text("Error: ${driverSnapshot.error}"));
        }
        if (!driverSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final liveDriverIds = driverSnapshot.data!.docs.map((d) => d.id).toList();

        if (liveDriverIds.isEmpty) {
          return const Center(child: Text("No live drivers right now"));
        }

        final stream = FirebaseFirestore.instance
            .collection('route_messages')
            .where('routeNumber', whereIn: favs)
            .where('driverId', whereIn: liveDriverIds)
            .orderBy('timestamp', descending: true)
            .limit(widget.perQueryLimit)
            .snapshots();

        return StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text("No messages yet"));
            }

            return _buildList(docs); 
          },
        ); // <-- closes inner StreamBuilder
      },
    ); // <-- closes outer StreamBuilder
  }

  // For more than 10 favourites
  return const Center(child: Text("We currently do not support more than 10 favourites."));
}


Widget _buildList(List<QueryDocumentSnapshot> docs) {
  final recentDocs = docs.take(5).toList(); 
  
  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: recentDocs.length,
    itemBuilder: (context, index) {
      final doc = recentDocs[index];
      final routeNumber = doc['routeNumber'] as String? ?? '';
      final message = doc['message'] as String? ?? '';
      final ts = (doc['timestamp'] as Timestamp?)?.toDate();
      final timeText =
          ts != null ? "${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}" : "";

      final driverId = doc.data().toString().contains('driverId')
          ? doc['driverId'] as String?
          : null;
          
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.directions_bus),
          title: Text("Route $routeNumber", style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(message),
          trailing: Text(timeText, style: const TextStyle(fontSize: 12)),
        ),
      );
    },
  );
}

}
