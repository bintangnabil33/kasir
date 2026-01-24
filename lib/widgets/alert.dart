import 'package:flutter/material.dart';

class AlertMessage {
  Future<void> showAlert(
    BuildContext context,
    String message,
    bool status,
  ) async {
    Color? warnafill;
    Color warnagaris;

    if (status) {
      warnafill = Colors.green[100];
      warnagaris = Colors.green;
    } else {
      warnafill = Colors.red[100];
      warnagaris = Colors.red;
    }

    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 2),
      content: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: warnafill,
          border: Border.all(color: warnagaris, width: 3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              status ? Icons.check_circle : Icons.error,
              color: warnagaris,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // ⏳ TUNGGU SAMPAI SNACKBAR SELESAI
    await Future.delayed(const Duration(seconds: 2));
  }
}
