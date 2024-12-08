import 'package:flutter/material.dart';
import 'dart:ui';


enum DrawingTool { rectangle, circle }

enum CanvasState { pan, draw, erase, addText, addSquare }

class DrawingPoint {
  final Offset position;
  final Color color;

  DrawingPoint({required this.position, required this.color});
}

class TextBox {
  String text;
  Offset position;

  TextBox(this.text, this.position);
}

class CanvasModel {
  final String name;
  final List<List<DrawingPoint>> drawingPoints;
  final List<TextBox> textBoxes;
  final List<Rect> squares;
  final String id;

  CanvasModel({
    required this.id,
    required this.name,
    required this.drawingPoints,
    required this.textBoxes,
    required this.squares,
  });
}
