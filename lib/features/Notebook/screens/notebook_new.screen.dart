import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Canvas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InfiniteCanvasPage(),
    );
  }
}

enum CanvasState { pan, draw, erase, addText }

class InfiniteCanvasPage extends StatefulWidget {
  @override
  _InfiniteCanvasPageState createState() => _InfiniteCanvasPageState();
}

class _InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  List<List<Offset>> allPoints = []; // Lista para almacenar todos los trazos
  List<Offset> currentPoints = []; // Puntos del trazo actual
  List<TextBox> textBoxes = []; // Lista de recuadros de texto
  CanvasState canvasState = CanvasState.draw; // Estado actual: dibujar, pan, borrar o agregar texto
  Offset offset = Offset(0, 0);
  TextEditingController textController = TextEditingController();
  TextBox? movingTextBox; // Recuerdos del recuadro de texto que se está moviendo
  Offset initialTouchOffset = Offset(0, 0); // Posición inicial del toque

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Infinite Canvas"),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón para cambiar entre los modos (Dibujar, Pan, Borrar, Agregar texto)
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (canvasState == CanvasState.draw) {
                  canvasState = CanvasState.pan;
                } else if (canvasState == CanvasState.pan) {
                  canvasState = CanvasState.erase;
                } else if (canvasState == CanvasState.erase) {
                  canvasState = CanvasState.addText;
                } else {
                  canvasState = CanvasState.draw;
                }
              });
            },
            child: Text(
              canvasState == CanvasState.draw
                  ? "Draw"
                  : canvasState == CanvasState.pan
                      ? "Pan"
                      : canvasState == CanvasState.erase
                          ? "Erase"
                          : "Text",
            ),
            backgroundColor: canvasState == CanvasState.draw
                ? Colors.red
                : canvasState == CanvasState.pan
                    ? Colors.blue
                    : canvasState == CanvasState.erase
                        ? Colors.green
                        : Colors.orange,
          ),
        ],
      ),
      body: GestureDetector(
        onPanDown: (details) {
          setState(() {
            if (canvasState == CanvasState.draw) {
              // Comienza un nuevo trazo
              currentPoints = [details.localPosition - offset];
            } else if (canvasState == CanvasState.erase) {
              _eraseLine(details.localPosition - offset);
            } else if (canvasState == CanvasState.addText) {
              _addTextBox(details.localPosition - offset);
            } else if (canvasState == CanvasState.pan) {
              // Comienza a mover un recuadro de texto
              movingTextBox = _getTextBoxAtPosition(details.localPosition - offset);
              if (movingTextBox != null) {
                initialTouchOffset = details.localPosition - movingTextBox!.position;
              }
            }
          });
        },
        onPanUpdate: (details) {
          setState(() {
            if (canvasState == CanvasState.pan) {
              if (movingTextBox != null) {
                // Mover el recuadro de texto
                movingTextBox!.position = details.localPosition - initialTouchOffset;
              } else {
                offset += details.delta; // Desplazar el canvas
              }
            } else if (canvasState == CanvasState.draw) {
              // Agregar puntos al trazo actual
              currentPoints.add(details.localPosition - offset);
            } else if (canvasState == CanvasState.erase) {
              _eraseLine(details.localPosition - offset);
            }
          });
        },
        onPanEnd: (details) {
          setState(() {
            if (canvasState == CanvasState.draw && currentPoints.isNotEmpty) {
              // Finaliza el trazo y lo agrega a la lista
              allPoints.add(List.from(currentPoints));
            }
            currentPoints.clear(); // Limpiar el trazo actual
            movingTextBox = null; // Deja de mover el recuadro de texto
          });
        },
        child: SizedBox.expand(
          child: ClipRRect(
            child: CustomPaint(
              painter: CanvasCustomPainter(
                  allPoints: allPoints, offset: offset, textBoxes: textBoxes),
            ),
          ),
        ),
      ),
    );
  }

  // Método para borrar líneas cerca de la posición del toque
  void _eraseLine(Offset position) {
    setState(() {
      allPoints.removeWhere((stroke) {
        return stroke.any((point) =>
            (point - position).distance < 20); // Radio de borrado
      });

      textBoxes.removeWhere((textBox) =>
          (textBox.position - position).distance < 30); // Radio de borrado de texto
    });
  }

  // Método para agregar un recuadro de texto en la posición del toque
  void _addTextBox(Offset position) async {
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter Text",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: "Enter your text here",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, textController.text);
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (text != null && text.isNotEmpty) {
      setState(() {
        textBoxes.add(TextBox(text, position));
      });
      textController.clear(); // Limpiar el campo de texto
    }
  }

  // Obtener el recuadro de texto en la posición dada
  TextBox? _getTextBoxAtPosition(Offset position) {
    for (var textBox in textBoxes) {
      final rect = Rect.fromLTWH(
        textBox.position.dx,
        textBox.position.dy,
        textBox.text.length * 10.0 + 20, // Estimación del tamaño del texto
        40, // Altura estimada del recuadro de texto
      );
      if (rect.contains(position)) {
        return textBox;
      }
    }
    return null;
  }
}

class CanvasCustomPainter extends CustomPainter {
  List<List<Offset>> allPoints;
  Offset offset;
  List<TextBox> textBoxes;

  CanvasCustomPainter({
    required this.allPoints,
    required this.offset,
    required this.textBoxes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Definir el color de fondo del canvas
    Paint background = Paint()..color = Colors.white;

    // Definir tamaño del canvas
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    // Definir las propiedades de pintura para los trazos
    Paint drawingPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.black
      ..strokeWidth = 2.0;

    // Dibujar cada trazo
    for (var stroke in allPoints) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i] + offset, stroke[i + 1] + offset, drawingPaint);
      }
    }

    // Dibujar los recuadros de texto
    for (var textBox in textBoxes) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: textBox.text,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final textOffset = textBox.position + offset;

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class TextBox {
  String text;
  Offset position;

  TextBox(this.text, this.position);
}
