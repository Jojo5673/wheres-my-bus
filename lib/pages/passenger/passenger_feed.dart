import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wheres_my_bus/models/passenger.dart';

class PassengerFeed extends StatefulWidget {
  final Passenger passenger;
  final int perQueryLimit;

  const PassengerFeed({
    super.key,
    required this.passenger,
    this.perQueryLimit = 50,
  });

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
    final favs = widget.passenger.favouriteRoutes;

    if (favs.isEmpty) {
      return const Center(child: Text("No favourite routes selected"));
    }

    // If 10 or fewer, simple query
    if (favs.length <= 10) {
      final stream = FirebaseFirestore.instance
          .collection('route_messages')
          .where('routeNumber', whereIn: favs)
          .orderBy('timestamp', descending: true)
          .limit(widget.perQueryLimit)
          .snapshots();

      return StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(child: Text("No messages yet"));
              }

              return _buildList(docs);
            },
        );
    }

    // >10 favourites: merge multiple queries
    return FutureBuilder<List<QuerySnapshot>>(
      future: Future.wait(_chunk(favs, 10).map((chunk) {
        return FirebaseFirestore.instance
            .collection('route_messages')
            .where('routeNumber', whereIn: chunk)
            .orderBy('timestamp', descending: true)
            .limit(widget.perQueryLimit)
            .get();
      })),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final allDocs = snapshot.data!
            .expand((qs) => qs.docs)
            .toList()
          ..sort((a, b) {
            final at = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bt = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bt.compareTo(at);
          });

        if (allDocs.isEmpty) return const Center(child: Text("No messages yet"));

        return _buildList(allDocs);
      },
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final routeNumber = doc['routeNumber'] as String? ?? '';
        final message = doc['message'] as String? ?? '';
        final ts = (doc['timestamp'] as Timestamp?)?.toDate();
        final timeText = ts != null
            ? "${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}"
            : "";

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

