import 'package:flutter/material.dart';

class CityFilterBar extends StatelessWidget {
  const CityFilterBar({super.key, required this.city, required this.onClear});

  final String city;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Align(
      alignment: Alignment.centerLeft,
      child: InputChip(
        avatar: const Icon(Icons.location_city, size: 18),
        label: Text(city),
        onDeleted: onClear,
      ),
    ),
  );
}
