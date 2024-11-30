import 'package:flutter/material.dart';

class NeteriteCardNote extends StatelessWidget {
  const NeteriteCardNote({super.key, required this.noteTitle  });
  final String noteTitle;
  
  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: SizedBox(
        width: 150,
        height: 50,
        child: Center(child: Text(noteTitle)),
      ),
    );
  }
}
