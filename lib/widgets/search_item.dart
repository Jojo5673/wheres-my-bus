import 'package:flutter/material.dart';

class SearchItem extends StatelessWidget {
  const SearchItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      tileColor: Theme.of(context).colorScheme.primaryContainer,
      subtitle: subtitle != null? Text(subtitle!) : null,
      leading: leading,
    );
  }
}