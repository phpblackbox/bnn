import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close the full-screen view on tap
          },
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain, // Adjusts the image to fit within the screen
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
