import 'package:flutter/material.dart';

class MyMessageBubble extends StatelessWidget {
  final String senderName;
  final DateTime createdAt;
  final String message;

  const MyMessageBubble({
    super.key,
    required this.senderName,
    required this.createdAt,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
    const Color(0xA6FF8D28);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              senderName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _timeAgo(createdAt),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6E6E6E),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Bulle
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
          ),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 22,
              height: 1.5,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  // Fonction qui calcule "il y a ..."
  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return "à l'instant";
    } else if (difference.inMinutes < 60) {
      return "il y a ${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "il y a ${difference.inHours} h";
    } else if (difference.inDays < 30) {
      return "il y a ${difference.inDays} jours";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "il y a $months mois";
    } else {
      final years = (difference.inDays / 365).floor();
      return "il y a $years ans";
    }
  }
}