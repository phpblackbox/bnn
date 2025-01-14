import 'package:bnn/screens/home/home.dart';
import 'package:bnn/screens/signup/ButtonGradientMain.dart';
import 'package:flutter/material.dart';

class CreateStory extends StatefulWidget {
  const CreateStory({Key? key}) : super(key: key);

  @override
  _CreateStoryState createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/createstory_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Create Story',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                height: 0.85,
                letterSpacing: -0.11,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: ImageIcon(
                    AssetImage('assets/images/icons/close.png'),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: ImageIcon(
                    AssetImage('assets/images/icons/add_link.png'),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: ImageIcon(
                    AssetImage('assets/images/icons/download.png'),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: ImageIcon(
                    AssetImage('assets/images/icons/filters.png'),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: ImageIcon(
                    AssetImage('assets/images/icons/vector.png'),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: ImageIcon(
                    AssetImage('assets/images/icons/text.png'),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: ImageIcon(
                    AssetImage('assets/images/icons/clip.png'),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: ImageIcon(
                    AssetImage('assets/images/icons/setting.png'),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                maxLines: null, // Allows the TextField to expand vertically
                decoration: InputDecoration(
                  border: InputBorder.none, // Removes the border
                  filled: false, // No fill color
                  hintText: 'Type your message here...',
                ),
                style: TextStyle(
                  fontSize: 16.0, // Set the font size
                ),
              ),
            ),
            Spacer(),
            Row(
              children: [
                Spacer(), // This pushes the button to the right
                SizedBox(
                  width: 110, // Set your desired width here
                  child: ButtonGradientMain(
                    label: 'Send',
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Home()));
                    },
                    textColor: Colors.white,
                    gradientColors: [Color(0xFF000000), Color(0xFF820200)],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
