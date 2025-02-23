import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Username extends StatefulWidget {
  const Username({super.key});

  @override
  _Username createState() => _Username();
}

class _Username extends State<Username> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool get isButtonEnabled {
    return usernameController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    final meProfile = authProvider.profile!;
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      size: 20.0, color: Color(0xFF4D4C4A)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 5),
                Text(
                  'Username',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4D4C4A),
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                CustomInputField(
                  placeholder: meProfile.username!,
                  controller: usernameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      final profile = {"username": value};
                      await authProvider.setProfile(profile);
                      await authProvider.updateProfile();
                    }
                  },
                ),
                SizedBox(height: 6),
                Text(
                  'Username changes will be saved  in your profile after moderation',
                  style: TextStyle(
                    color: Color(0xFF4D4C4A),
                    fontSize: 10,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
