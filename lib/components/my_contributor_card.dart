import 'package:flutter/material.dart';

class MyContributorsCard extends StatelessWidget {
  final String title;
  final List<String> contributors;

  const MyContributorsCard({
    super.key,
    required this.title,
    required this.contributors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const Icon(
                Icons.group_outlined,
                size: 24,
                color: Colors.black,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Chips dynamiques
          if (contributors.isEmpty)
            Text(
              "Aucun membre pour le moment",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withValues(alpha: 0.60),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: contributors.map((name) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DCC4)
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}