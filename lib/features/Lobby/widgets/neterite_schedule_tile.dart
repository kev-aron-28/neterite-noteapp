import 'package:flutter/material.dart';

class NeteriteScheduleTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const NeteriteScheduleTile({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3), // Spacing between tiles
      padding: const EdgeInsets.all(3), // Inner padding
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.red, // Red left border
            width: 4, // Border thickness
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
