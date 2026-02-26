import 'package:flutter/material.dart';
import '../pages/create_capsule_page.dart';

class DraggableCreateCapsuleButton extends StatefulWidget {
  const DraggableCreateCapsuleButton({super.key});

  @override
  State<DraggableCreateCapsuleButton> createState() =>
      _DraggableCreateCapsuleButtonState();
}

class _DraggableCreateCapsuleButtonState
    extends State<DraggableCreateCapsuleButton> {

  double top = 600;
  double left = 300;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
          top: top,
          left: left,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                left += details.delta.dx;
                top += details.delta.dy;

                // Empêche de sortir de l’écran
                left = left.clamp(0, screenSize.width - 70);
                top = top.clamp(0, screenSize.height - 100);
              });
            },
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFFF8D28).withValues(alpha: 0.65),
              elevation: 6,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCapsulePage(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}