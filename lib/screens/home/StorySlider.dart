import 'package:bnn/main.dart';
import 'package:bnn/screens/home/gallery.dart';
import 'package:bnn/screens/home/story.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StorySlider extends StatefulWidget {
  const StorySlider({super.key});

  @override
  _StorySliderState createState() => _StorySliderState();
}

class _StorySliderState extends State<StorySlider> {
  List<Map<String, dynamic>>? stories = [
    {
      'id': '0',
      'avatar': 'assets/images/avatar/create_story_btn.png',
      'username': 'Create \n story',
    },
  ];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchstories();
  }

  Future<void> fetchstories() async {
    setState(() {
      _loading = true;
    });
    if (supabase.auth.currentUser != null) {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User is not logged in!');
        return;
      }

      try {
        final data = await supabase.from('view_stories').select();

        if (data.isNotEmpty) {
          setState(() {
            stories!.addAll(data);
            _loading = false;
          });
        }
      } catch (e) {
        print('Caught error: $e');
        if (e.toString().contains("JWT expired")) {
          await supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1.0),
      child: SizedBox(
        height: 110,
        child: Skeletonizer(
          enabled: _loading,
          enableSwitchAnimation: true,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stories!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Galley()));
                  }

                  if (index > 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Story(id: stories![index]["user_id"])));
                  }
                },
                child: Stack(
                  children: [
                    if (index != 0)
                      Positioned(
                        left: 6,
                        top: 12,
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: CustomPaint(
                            painter: GradientOvalPainter(),
                          ),
                        ),
                      ),
                    Container(
                      width: 66, // Set width to avoid layout issues
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          index == 0
                              ? CircleAvatar(
                                  radius: 33,
                                  backgroundImage:
                                      AssetImage(stories![index]['avatar']!),
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(stories![index]['avatar']!),
                                  radius:
                                      33, // Half of the height/width for a perfect circle
                                ),
                          Text(
                            stories![index]['username']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Nunito",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GradientOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final gradient = LinearGradient(
      colors: [
        Color(0xFF000000), // Black
        Color(0xFF820200), // Dark Red
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    paint.shader =
        gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final fill = Paint()..color = Colors.white;
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
