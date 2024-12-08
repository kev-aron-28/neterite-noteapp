import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:neterite/features/Notebook/models/canva_model.dart';
import 'package:neterite/features/Notebook/repo/notebook_repo.dart';

class InfiniteCanvasUpdatePage extends StatefulWidget {

  final String canvasId;

  const InfiniteCanvasUpdatePage({ Key? key, required this.canvasId });

  @override
  _InfiniteCanvasPageState createState() => _InfiniteCanvasPageState();
}

class _InfiniteCanvasPageState extends State<InfiniteCanvasUpdatePage> {
  final InMemoryCanvasRepository canvas = InMemoryCanvasRepository();
  
  List<List<DrawingPoint>> allPoints = [];
  List<DrawingPoint> currentPoints = [];
  List<TextBox> textBoxes = [];
  List<Rect> allSquares = [];
  Rect? currentSquare;
  Offset? squareStart;

  CanvasState canvasState = CanvasState.draw;
  Offset offset = const Offset(0, 0);
  TextEditingController textController = TextEditingController();

  TextBox? movingTextBox;

  Rect? movingSquare;

  Offset initialTouchOffset = Offset(0, 0);

  Color selectedColor = Colors.black;

  String canvasName = "Apunte sin nombre";

  InMemoryCanvasRepository repository = InMemoryCanvasRepository();

  void _loadCanvas() {
    final canvas = repository.getCanvas(widget.canvasId);

    if(canvas == null) {
      throw Exception('Canvas not found');
    }

    allPoints = canvas.drawingPoints;
    canvasName = canvas.name;
    textBoxes = canvas.textBoxes;
    allSquares = canvas.squares;
  }

  @override
  void initState() {
    super.initState();

    _loadCanvas();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCanvasNameDialog();
    });
  }

  void _showCanvasNameDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Nombre del Canvas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: "Ingresa el nombre del canvas",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, textController.text);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (name != null && name.isNotEmpty) {
      setState(() {
        canvasName = name; // Guarda el nombre del canvas
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(canvasName),
        actions: [
          IconButton(onPressed: () {
            repository.updateCanvas(widget.canvasId, CanvasModel(
              id: widget.canvasId, 
              name: canvasName, 
              drawingPoints: allPoints, 
              textBoxes: textBoxes, 
              squares: allSquares
            ));
          }, icon: const Icon(Icons.save))
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (canvasState == CanvasState.draw) {
                  canvasState = CanvasState.pan;
                } else if (canvasState == CanvasState.pan) {
                  canvasState = CanvasState.erase;
                } else if (canvasState == CanvasState.erase) {
                  canvasState = CanvasState.addText;
                } else if (canvasState == CanvasState.addText) {
                  canvasState = CanvasState.addSquare;
                } else {
                  canvasState = CanvasState.draw;
                }
              });
            },
            backgroundColor: canvasState == CanvasState.draw
                ? Colors.red
                : canvasState == CanvasState.pan
                    ? Colors.blue
                    : canvasState == CanvasState.erase
                        ? Colors.green
                        : Colors.purple,
            child: Text(
              () {
                switch (canvasState) {
                  case CanvasState.pan:
                    return "Pan";
                  case CanvasState.draw:
                    return "Dibujo";
                  case CanvasState.erase:
                    return "Borrar";
                  case CanvasState.addText:
                    return "Texto";
                  case CanvasState.addSquare:
                    return "Cuadro";
                  default:
                    return "Unknown";
                }
              }(),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: () => _showColorPicker(context),
            backgroundColor: selectedColor,
            child: Icon(Icons.color_lens), // Icono para el selector de color
          )
        ],
      ),
      body: GestureDetector(
        onPanDown: (details) {
          setState(() {
            if (canvasState == CanvasState.addSquare) {
              squareStart = details.localPosition - offset;

              currentSquare = null;
            } else if (canvasState == CanvasState.draw) {
              // Comienza un nuevo trazo
              currentPoints = [
                DrawingPoint(
                    position: details.localPosition - offset,
                    color:
                        selectedColor) // Asegúrate de tener el color seleccionado
              ];
            } else if (canvasState == CanvasState.erase) {
              _eraseLine(details.localPosition - offset);
            } else if (canvasState == CanvasState.addText) {
              _addTextBox(details.localPosition - offset);
            } else if (canvasState == CanvasState.pan) {
              // Comienza a mover un recuadro de texto
              movingTextBox =
                  _getTextBoxAtPosition(details.localPosition - offset);

              movingSquare =
                  _getSquareAtPosition(details.localPosition - offset);

              if (movingSquare != null) {
                initialTouchOffset =
                    details.localPosition - movingSquare!.topLeft;
              }

              if (movingTextBox != null) {
                initialTouchOffset =
                    details.localPosition - movingTextBox!.position;
              }
            }
          });
        },
        onPanUpdate: (details) {
          setState(() {
            if (canvasState == CanvasState.addSquare && squareStart != null) {
              final currentPosition = details.localPosition - offset;

              currentSquare = Rect.fromPoints(squareStart!, currentPosition);
            } else if (canvasState == CanvasState.pan) {
              if (movingTextBox != null) {
                // Mover el recuadro de texto
                movingTextBox!.position =
                    details.localPosition - initialTouchOffset;
              } else {
                offset += details.delta; // Desplazar el canvas
              }
            } else if (canvasState == CanvasState.draw) {
              // Agregar puntos al trazo actual
              currentPoints.add(DrawingPoint(
                  position: details.localPosition - offset,
                  color: selectedColor));
            } else if (canvasState == CanvasState.erase) {
              _eraseLine(details.localPosition - offset);
            }
          });
        },
        onPanEnd: (details) {
          setState(() {
            if (canvasState == CanvasState.addSquare && currentSquare != null) {
              allSquares.add(Rect.fromPoints(
                squareStart!,
                details.localPosition - offset,
              ));
              currentSquare = null;
              squareStart = null;
            } else if (canvasState == CanvasState.draw &&
                currentPoints.isNotEmpty) {
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
                  currentPoints: currentPoints,
                  allPoints: allPoints,
                  offset: offset,
                  textBoxes: textBoxes,
                  allSquares: allSquares,
                  currentSquare: currentSquare),
            ),
          ),
        ),
      ),
      
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: Colors.primaries.length,
            itemBuilder: (context, index) {
              Color color = Colors.primaries[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color; // Cambiar color seleccionado
                  });
                  Navigator.pop(context); // Cerrar el modal
                },
                child: Container(margin: EdgeInsets.all(8), color: color),
              );
            },
          ),
        );
      },
    );
  }

  // Método para borrar líneas cerca de la posición del toque
  void _eraseLine(Offset position) {
    setState(() {
      allPoints.removeWhere((stroke) {
        return stroke.any((point) =>
            (point.position - position).distance < 20); // Radio de borrado
      });

      textBoxes.removeWhere((textBox) =>
          (textBox.position - position).distance <
          30); // Radio de borrado de texto

      allSquares.removeWhere((square) {
        return square.contains(position);
      });
    });
  }

  // Método para agregar un recuadro de texto en la posición del toque
  void _addTextBox(Offset position) async {
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Ingresa el texto",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: "Ingresa el texto aqui",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
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

  Rect? _getSquareAtPosition(Offset position) {
    for (var square in allSquares) {
      final rect =
          Rect.fromLTWH(square.left, square.top, square.width, square.height);

      if (rect.contains(position)) {
        return square;
      }
    }

    return null;
  }
}

class CanvasCustomPainter extends CustomPainter {
  List<List<DrawingPoint>> allPoints;
  List<Rect> allSquares;
  Rect? currentSquare;
  Offset offset;
  List<TextBox> textBoxes;
  List<DrawingPoint> currentPoints;
  CanvasCustomPainter(
      {required this.currentPoints,
      required this.allPoints,
      required this.offset,
      required this.textBoxes,
      required this.allSquares,
      required this.currentSquare});

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
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true
      ..color = Colors.black
      ..strokeWidth = 2.0;

    for (var points in allPoints) {
      for (var point in points) {
        Paint paint = Paint()
          ..color = point.color; // Usa el color del DrawingPoint
        canvas.drawCircle(point.position + offset, 5,
            paint); // Dibuja un círculo en cada punto
      }
    }

    for (var point in currentPoints) {
      Paint paint = Paint()..color = point.color;
      canvas.drawCircle(point.position + offset, 5, paint);
    }

    // Dibujar los recuadros de texto
    for (var textBox in textBoxes) {
      _drawTextBox(canvas, textBox, offset);
    }

    final squarePainter = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    for (final square in allSquares) {
      canvas.drawRect(square.shift(offset), squarePainter);
    }

    if (currentSquare != null) {
      canvas.drawRect(currentSquare?.shift(offset) as Rect, squarePainter);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawTextBox(Canvas canvas, TextBox textBox, Offset offset) {
    List<String> lines = textBox.text.split('\n');
    double currentY = textBox.position.dy + offset.dy; // Posición inicial

    for (var line in lines) {
      if (line.startsWith('#')) {
        _drawTitle(canvas, line, currentY, offset,
            textBox); // Procesar título Markdown
        currentY += 30; // Ajustar espacio después de un título
      } else {
        _drawFormattedText(
            canvas, line, currentY, offset, textBox); // Procesar texto normal
        currentY += 20; // Ajustar espacio para texto normal
      }
    }
  }

  void _drawTitle(Canvas canvas, String line, double currentY, Offset offset,
      TextBox textBox) {
    // Determinar el nivel del título
    int titleLevel = _getTitleLevel(line);
    String titleText = line.substring(titleLevel).trim();

    if (titleText.isEmpty) return;

    TextStyle titleStyle = _getTitleStyle(titleLevel);
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: "Hola mundo",
        style: titleStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textOffset = Offset(textBox.position.dx + offset.dx, currentY);
    textPainter.paint(canvas, textOffset);
  }

  void _drawFormattedText(Canvas canvas, String line, double currentY,
      Offset offset, TextBox textBox) {
    // Definir el estilo para el texto normal
    TextStyle normalTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    );

    // Definir el estilo para el texto en negrita
    TextStyle boldTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    // Definir el estilo para el texto en cursiva
    TextStyle italicTextStyle = TextStyle(
      fontSize: 16,
      fontStyle: FontStyle.italic,
      color: Colors.black,
    );

    // Dividir el texto en fragmentos (normal, negrita, cursiva)
    List<TextSpan> textSpans = [];
    String currentText = '';
    bool inBold = false, inItalic = false;

    for (int i = 0; i < line.length; i++) {
      String char = line[i];

      if (char == '*' && i + 1 < line.length && line[i + 1] == '*') {
        // Cambio a negrita
        if (inBold) {
          textSpans.add(TextSpan(text: currentText, style: boldTextStyle));
          currentText = '';
          inBold = false;
        } else {
          if (currentText.isNotEmpty) {
            textSpans.add(TextSpan(text: currentText, style: normalTextStyle));
          }
          currentText = '';
          inBold = true;
        }
        i++; // Saltar el siguiente '*'
      } else if (char == '*' && !inBold) {
        // Cambio a cursiva
        if (inItalic) {
          textSpans.add(TextSpan(text: currentText, style: italicTextStyle));
          currentText = '';
          inItalic = false;
        } else {
          if (currentText.isNotEmpty) {
            textSpans.add(TextSpan(text: currentText, style: normalTextStyle));
          }
          currentText = '';
          inItalic = true;
        }
      } else {
        currentText += char; // Agregar al texto actual
      }
    }

    // Si hay texto pendiente, añadirlo
    if (currentText.isNotEmpty) {
      textSpans.add(TextSpan(text: currentText, style: normalTextStyle));
    }

    // Crear un TextSpan combinado
    TextPainter textPainter = TextPainter(
      text: TextSpan(children: textSpans),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Crear la posición final para dibujar
    final textOffset = Offset(textBox.position.dx + offset.dx, currentY);

    // Pintar el texto con formato en el canvas
    textPainter.paint(canvas, textOffset);
  }

  int _getTitleLevel(String line) {
    int titleLevel = 0;
    while (line.startsWith('#')) {
      titleLevel++;
      line = line.substring(1).trim();
    }
    return titleLevel;
  }

  // Obtener el estilo del título según el nivel
  TextStyle _getTitleStyle(int level) {
    switch (level) {
      case 1:
        return TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);
      case 2:
        return TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black);
      case 3:
        return TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);
      default:
        return TextStyle(
            fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black);
    }
  }
}
