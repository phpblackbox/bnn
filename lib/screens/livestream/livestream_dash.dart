import 'package:bnn/providers/livestream_provider.dart';
import 'package:bnn/screens/livestream/livestream_screen.dart';
import 'package:bnn/screens/livestream/livestream_view.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LivestreamDash extends StatefulWidget {
  const LivestreamDash({super.key});

  @override
  State<LivestreamDash> createState() => _LivestreamDashState();
}

class _LivestreamDashState extends State<LivestreamDash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LivestreamProvider>(context, listen: false).initData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LivestreamProvider livestreamProvider =
        Provider.of<LivestreamProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await livestreamProvider.createLivestream();
                if (result.isSuccess == true) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LiveStreamScreen(),
                    ),
                  );
                } else {
                  CustomToast.showToastDangerTop(context,
                      'Error for create livestream: ${result.toString()}');
                }
              },
              child: const Text('Create Livestream'),
            ),
            ElevatedButton(
              onPressed: () async {
                String callId = "sm23C4G9eBqO";
                final result = await livestreamProvider.joinLivestream(callId);

                if (result.isSuccess == true) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LiveStreamView(),
                    ),
                  );
                } else {
                  CustomToast.showToastDangerTop(context,
                      'Error for create livestream: ${result.toString()}');
                }
              },
              child: const Text('Create Livestream'),
            ),
            livestreamProvider.loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: livestreamProvider.getData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data ?? [];
                      print("data =  ${data.toString()}");

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: livestreamProvider.channels.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.all(8),
                            child: GestureDetector(
                              onTap: () async {
                                if (mounted) {
                                  String callId = livestreamProvider
                                      .channels[index]["call_id"];
                                  final result = await livestreamProvider
                                      .joinLivestream(callId);
                                  if (result.isSuccess == true) {
                                    _navigatorKey.currentState
                                        ?.pushNamed('/livestream-view');
                                  } else {
                                    CustomToast.showToastDangerTop(context,
                                        'Error join livestream: ${result.toString()}');
                                  }
                                }
                              },
                              child: Column(children: [
                                Text(
                                    'userId: ${livestreamProvider.channels[index]["user_id"]}'),
                                Text(
                                    'callId: ${livestreamProvider.channels[index]["call_id"]}')
                              ]),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
