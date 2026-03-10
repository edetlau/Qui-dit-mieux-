import 'dart:math';
import 'package:flutter/material.dart';

class RandomLetterWidget extends StatelessWidget {
  final _letter = String.fromCharCode(Random().nextInt(26) + 65);

  RandomLetterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Lettre : $_letter",
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
  }
}

class RandomNumberWidget extends StatelessWidget {
  final int max;
  RandomNumberWidget({super.key, required this.max});

  final int number = Random().nextInt(20) + 1;

  @override
  Widget build(BuildContext context) {
    return Text(
      "Nombre : $number",
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
  }
}