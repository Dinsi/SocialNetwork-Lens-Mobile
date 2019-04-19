import 'package:flutter/material.dart';

TextStyle votesTextStyle([Color color]) {
  return TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.grey[600],
  );
}

String nFormatter(double num, int digits) {
  final List<Map<dynamic, dynamic>> si = const [
    {"value": 1, "symbol": ""},
    {"value": 1E3, "symbol": "k"},
    {"value": 1E6, "symbol": "M"},
    {"value": 1E9, "symbol": "G"},
    {"value": 1E12, "symbol": "T"},
    {"value": 1E15, "symbol": "P"},
    {"value": 1E18, "symbol": "E"}
  ];
  final rx = RegExp(r"\.0+$|(\.[0-9]*[1-9]*)0+$");
  var i;
  for (i = si.length - 1; i > 0; i--) {
    if (num >= si[i]["value"]) {
      break;
    }
  }

  return (num / si[i]["value"]).toStringAsFixed(digits).replaceAllMapped(rx,
          (match) {
        return match.group(1) ?? "";
      }) +
      si[i]["symbol"];
}