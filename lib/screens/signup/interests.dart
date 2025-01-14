import 'package:bnn/main.dart';
import 'package:flutter/material.dart';
import 'ButtonGradientMain.dart';
import './InterestItem.dart';
import './termsofservice.dart';

class Interests extends StatefulWidget {
  const Interests({super.key});

  @override
  State<Interests> createState() => _InterestsState();
}

class _InterestsState extends State<Interests>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<String> interests = [
    'Harry potter',
    '90s Kid',
    'House Parties',
    'SoundCloud',
    'Spa',
    'Self Care',
    'Heavy Metals',
    'House Parties',
    'Spa',
    'Gin Tonic',
    'Gymnastics',
    'Harry potter',
    '90s Kid',
    'House Parties',
    'SoundCloud',
    'Spa',
    'Self Care',
    'Heavy Metals',
    'House Parties',
    'Spa',
    'Gin Tonic',
    'Gymnastics',
    'Harry potter',
    '90s Kid',
    'House Parties',
    'SoundCloud',
    'Spa',
    'Self Care',
    'Heavy Metals',
    'House Parties',
    'Spa',
    'Gin Tonic',
    'Gymnastics',
  ];

  List<String> selectedInterests = [];

  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Start the animation
    _controller.forward();
  }

  void _onInterestSelected(bool isSelected, String interest) {
    setState(() {
      if (isSelected) {
        selectedInterests.add(interest);
      } else {
        selectedInterests.remove(interest);
      }
    });
    print("Selected Interests: $selectedInterests");
  }

  bool get isButtonEnabled {
    return selectedInterests
        .isNotEmpty; // Enable button if at least one interest is selected
  }

  Future<void> _update() async {
    if (isButtonEnabled) {
      try {
        final userId = supabase.auth.currentUser!.id;

        print(selectedInterests);

        await supabase.from('profiles').upsert({
          'id': userId,
          'interests': selectedInterests,
        });

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TermsOfService()));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $error')),
        );
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Interests",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust padding values here
        child: Column(
          children: [
            Text(
              "Let everyone know what you’re interested to enjoy reels based on your interests.",
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0, // Space between items
              runSpacing: 8.0, // Space between lines when they wrap
              children: interests.map((interest) {
                return InterestItem(
                  interest: interest,
                  onSelected: (isSelected) =>
                      _onInterestSelected(isSelected, interest),
                );
              }).toList(),
            ),
            Spacer(),
            ButtonGradientMain(
              label: 'Continue',
              onPressed: _update,
              textColor: Colors.white,
              gradientColors: isButtonEnabled
                  ? [Color(0xFF000000), Color(0xFF820200)] // Active gradient
                  : [
                      Color(0xFF820200).withOpacity(0.5),
                      Color(0xFF000000).withOpacity(0.5)
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
