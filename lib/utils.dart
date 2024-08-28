import "package:flutter/material.dart";

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

const TextStyle pixelCode = TextStyle(fontFamily: "PixelCode", fontSize: 14, height: 1.2);
