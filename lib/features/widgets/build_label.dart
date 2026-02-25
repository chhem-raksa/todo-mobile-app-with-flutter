import 'package:flutter/material.dart';

Widget buildLabel(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}
