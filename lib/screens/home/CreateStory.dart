import 'package:bnn/main.dart';
import 'package:bnn/screens/home/home.dart';
import 'package:bnn/screens/signup/ButtonGradientMain.dart';
import 'package:flutter/material.dart';

class CreateStory extends StatefulWidget {
  final int storyId;

  const CreateStory({
    super.key,
    required this.storyId,
  });

  @override
  _CreateStoryState createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  Map<String, dynamic>? data;
  final TextEditingController _storyController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchdata();
  }

  void fetchdata() async {
    final res = await supabase
        .from('stories')
        .select()
        .eq('id', widget.storyId)
        .single();
    if (res.isNotEmpty) {
      setState(() {
        data = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(data != null ? (data?["img_urls"][0]) : null),
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
                controller: _storyController,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: false,
                  hintText: 'Type your message here...',
                ),
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            Spacer(),
            Row(
              children: [
                Spacer(),
                SizedBox(
                  width: 110,
                  child: ButtonGradientMain(
                    label: 'Send',
                    onPressed: () async {
                      await supabase.from('stories').upsert({
                        'id': widget.storyId,
                        'content': _storyController.text
                      });
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
