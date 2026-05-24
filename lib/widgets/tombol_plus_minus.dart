import 'package:flutter/material.dart';

class TombolPlusMinus extends StatelessWidget {
  final VoidCallback onTambah;
  final VoidCallback onKurang;
  final String jumlah;

  const TombolPlusMinus({
    super.key,
    required this.onTambah,
    required this.onKurang,
    required this.jumlah,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onKurang,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Icon(Icons.remove, size: 18, color: Colors.red),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            jumlah,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        InkWell(
          onTap: onTambah,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Icon(Icons.add, size: 18, color: Colors.green),
          ),
        ),
      ],
    );
  }
}