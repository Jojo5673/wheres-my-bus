import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class FloatingSearch extends StatelessWidget {
  const FloatingSearch({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return FloatingSearchBar(
      hint: hint,
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
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction.searchToClear(showIfClosed: true),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  Colors.accents.map((color) {
                    return Container(height: 60, color: color);
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}
