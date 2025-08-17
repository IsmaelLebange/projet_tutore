import 'package:flutter/material.dart';

class BarreCategories extends StatelessWidget {
  final List categories;

  BarreCategories({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Chip(
              label: Text(categories[index]),
              backgroundColor: Colors.blue.shade100,
            ),
          );
        },
      ),
    );
  }
}
