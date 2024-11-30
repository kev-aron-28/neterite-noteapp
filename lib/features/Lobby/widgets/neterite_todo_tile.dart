import 'package:flutter/material.dart';

class NeteriteTodoTile extends StatefulWidget {
  final String title;
  final String subtitle;

  const NeteriteTodoTile({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  _NeteriteTodoTileState createState() => _NeteriteTodoTileState();
}

class _NeteriteTodoTileState extends State<NeteriteTodoTile> {
  bool isChecked = false; // Controla el estado del checkbox

  void _handleCheckboxChanged(bool? value) {
    setState(() {
      isChecked = value ?? false; // Cambia el estado
    });
    print("CHECK BOX CHANGED to $isChecked");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3), // Espaciado entre tiles
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox púrpura
          Checkbox(
            value: isChecked,
            onChanged: _handleCheckboxChanged,
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.purple; // Fondo púrpura si está seleccionado
              }
              return Colors.white; // Fondo gris si no está seleccionado
            }),
            shape: const CircleBorder(), // Hacer el checkbox circular (opcional)
          ),
          const SizedBox(width: 10), // Espaciado entre checkbox y texto
          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
