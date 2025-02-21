import 'package:bnn/providers/story_provider.dart';
import 'package:bnn/screens/home/home.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final supabase = Supabase.instance.client;

  final TextEditingController _storyController = TextEditingController();

  @override
  void initState() {
    super.initState();

    print(widget.storyId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false)
          .getStoryById(widget.storyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);

    return Scaffold(
      body: storyProvider.loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage((storyProvider.story["img_urls"][0])),
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
                            await storyProvider.createStoryContent(
                                widget.storyId, _storyController.text);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home()));
                          },
                          textColor: Colors.white,
                          gradientColors: [
                            AppColors.primaryBlack,
                            AppColors.primaryRed
                          ],
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
