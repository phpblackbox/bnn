import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/livestream/livestream_screen.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';

class LivestreamDash extends StatefulWidget {
  const LivestreamDash({super.key});

  @override
  State<LivestreamDash> createState() => _LivestreamDashState();
}

class _LivestreamDashState extends State<LivestreamDash> {
  Profiles? loadedProfile;

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  void fetchdata() async {
    final res = await Constants.loadProfile();

    setState(() {
      loadedProfile = res;
    });

    // StreamVideo(
    //   'udqd594zzqub',
    //   user: User(
    //     info: UserInfo(
    //       name: 'John Doe',
    //       id: loadedProfile!.id,
    //     ),
    //   ),
    //   userToken:
    //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJAc3RyZWFtLWlvL2Rhc2hib2FyZCIsImlhdCI6MTczODYwMjI3MSwiZXhwIjoxNzM4Njg4NjcxLCJ1c2VyX2lkIjoiIWFub24iLCJyb2xlIjoidmlld2VyIiwiY2FsbF9jaWRzIjpbImxpdmVzdHJlYW06bGl2ZXN0cmVhbV8yNDAwOWQ3Ni1jOTViLTRlZmUtOTAwMC00Y2Q2ZmRmOTZiYjMiXX0.O_CP-Qb3V9ElxShtRdFQ86YeqfB0jL36QOZuhbSgPTs',
    // );
  }

  Future<void> _createLivestream() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LiveStreamScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: loadedProfile == null
            ? Text("No user")
            : Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _createLivestream(),
                    child: const Text('Create Livestream'),
                  ),
                ],
              ),
      ),
    );
  }
}
