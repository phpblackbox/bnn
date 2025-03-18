import 'package:flutter/material.dart';

class ButtonPostAction extends StatelessWidget {
  final IconData icon;
  final String count;
  final VoidCallback onTap;

  const ButtonPostAction({
    Key? key,
    required this.icon,
    required this.count,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
        decoration: ShapeDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
              size: 16.0,
            ),
            const SizedBox(width: 4.0),
            count != "null"
                ? Text(
                    count,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  )
                : Container(
                    width: 10,
                    height: 10,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                        strokeWidth: 1, color: Colors.white),
                  ),
          ],
        ),
      ),
    );
  }
}
