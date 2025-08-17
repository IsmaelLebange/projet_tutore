import 'package:flutter/material.dart';

class SectionTendance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text('Tendance en ce moment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(5, (index) {
              return Container(
                margin: EdgeInsets.all(8),
                width: 150,
                height: 100,
                color: Colors.orange.shade200,
                child: Center(child: Text('Tendance ${index+1}')),
              );
            }),
          ),
        ),
      ],
    );
  }
}
