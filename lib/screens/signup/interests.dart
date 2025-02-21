import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './InterestItem.dart';
import './termsofservice.dart';

class Interests extends StatefulWidget {
  const Interests({super.key});

  @override
  State<Interests> createState() => _InterestsState();
}

class _InterestsState extends State<Interests>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

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

  @override
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
    return selectedInterests.isNotEmpty;
  }

  Future<void> _update() async {
    if (isButtonEnabled) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        final profile = {"interests": selectedInterests};
        await authProvider.setProfile(profile);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TermsOfService()));
      } catch (error) {
        CustomToast.showToastWarningBottom(
            context, 'Error updating profile: $error');
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
                  ? [AppColors.primaryBlack, AppColors.primaryRed]
                  : [
                      AppColors.primaryRed.withOpacity(0.5),
                      AppColors.primaryBlack.withOpacity(0.5)
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
