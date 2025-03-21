import 'package:bnn/providers/story_provider.dart';
import 'package:bnn/screens/home/create_story_gallery.dart';
import 'package:bnn/screens/home/story_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StorySlider extends StatefulWidget {
  const StorySlider({Key? key}) : super(key: key);

  @override
  _StorySliderState createState() => _StorySliderState();
}

class _StorySliderState extends State<StorySlider> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false).getStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);

    return Padding(
      padding: EdgeInsets.all(1.0),
      child: SizedBox(
        height: 100,
        child: Skeletonizer(
          enabled: storyProvider.loading,
          enableSwitchAnimation: true,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateStoryGallery(),
                    ),
                  );
                },
                child: Container(
                  width: 66,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 33,
                        backgroundImage: AssetImage(
                            "assets/images/avatar/create_story_btn.png"),
                      ),
                      Text(
                        "Create\nStory",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Nunito",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: storyProvider.stories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryView(
                                id: storyProvider.stories[index]["id"]),
                          ),
                        );
                      },
                      child: Container(
                        width: 66,
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  storyProvider.stories[index]['avatar']!),
                              radius: 33,
                            ),
                            Text(
                              storyProvider.stories[index]['username']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Nunito",
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
