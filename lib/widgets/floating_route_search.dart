import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:wheres_my_bus/models/route.dart';
import 'package:wheres_my_bus/models/routeManager.dart';
import 'package:wheres_my_bus/widgets/search_item.dart';

class FloatingSearch extends StatefulWidget {
  const FloatingSearch({super.key, required this.hint});

  final String hint;

  @override
  State<FloatingSearch> createState() => _FloatingSearchState();
}

class _FloatingSearchState extends State<FloatingSearch> {
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
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return FloatingSearchBar(
      hint: widget.hint,
      hintStyle: textTheme.bodyLarge!.copyWith(color: Colors.grey[400]),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: double.infinity,
      debounceDelay: const Duration(milliseconds: 500),
      backgroundColor: colorScheme.primaryContainer,
      height: 60,
      margins: EdgeInsets.fromLTRB(10, 15, 10, 0),
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
      onQueryChanged: (query) {
        _filterRoutes(query);
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [FloatingSearchBarAction.searchToClear(showIfClosed: true)],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  routes.map((route) {
                    return InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped on route: ${route.routeNumber}')));
                      },
                      child: SearchItem(
                        title: route.routeNumber,
                        subtitle: route.stops.keys.toString(),
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}
