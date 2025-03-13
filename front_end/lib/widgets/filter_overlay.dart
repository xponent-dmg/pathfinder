import 'package:flutter/material.dart';

class FilterOverlay extends StatefulWidget {
  const FilterOverlay({super.key});

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.7,
        snapSizes: [0.2, 0.4, 0.7],
        builder: (context, scrollController) {
          return filterBox();
        });
  }
}

Widget filterBox() {
  return Container(
    color: Colors.red,
    padding: EdgeInsets.all(10),
  );
}
