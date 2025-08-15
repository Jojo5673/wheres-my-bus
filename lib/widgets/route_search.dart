import 'package:flutter/material.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/models/routeManager.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:wheres_my_bus/widgets/search_item.dart';


class RouteSearch extends StatefulWidget {
  const RouteSearch({super.key, required this.selectedHandler});

  final Function(BusRoute) selectedHandler;

  @override
  State<RouteSearch> createState() => _RouteSearchState();
}

class _RouteSearchState extends State<RouteSearch> {
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

  List<BusRoute> _filterRoutes(String query) {
    return routes.where((route) {
      bool inrouteNumber = route.routeNumber.contains(query.toLowerCase());
      bool inStops = route.stops.keys.any((key) => key.toLowerCase().contains(query.toLowerCase()));
      return inrouteNumber || inStops;
    }).toList();
  }

  @override
  Widget build(context) {
    return TypeAheadField<BusRoute>(
      suggestionsCallback: (search) => _filterRoutes(search),
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Search Routes'),
        );
      },
      itemBuilder: (context, route) {
        return SearchItem(title: route.routeNumber, subtitle: route.stops.keys.toString());
      },
      onSelected: (route) {
        widget.selectedHandler(route);
      },
      loadingBuilder: (context) => SearchItem(title:'Loading...'),
      errorBuilder: (context, error) => SearchItem(title:'Error!'),
      emptyBuilder: (context) => SearchItem(title:'No routes found!'),
    );
  }
}
