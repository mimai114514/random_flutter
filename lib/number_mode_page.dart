import 'package:flutter/material.dart';

class NumberModePage extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final bool isChoosing;
  final int? chosenNumber;
  final Function(String) onMinChanged;
  final Function(String) onMaxChanged;
  final VoidCallback onButtonPressed;

  NumberModePage({
    required this.minController,
    required this.maxController,
    required this.isChoosing,
    required this.chosenNumber,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    switch (isChoosing) {
      case true:
        return Text(
          chosenNumber.toString(),
          style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        );
      case false:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              decoration: InputDecoration(
                labelText: '最小值',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: onMinChanged,
            ),
            SizedBox(height: 12),
            TextField(
              controller: maxController,
              decoration: InputDecoration(
                labelText: '最大值',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: onMaxChanged,
            ),
          ],
        );
    }
  }
}
