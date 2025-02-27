import 'package:bnn/providers/livestream_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({
    super.key,
  });

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  @override
  Widget build(BuildContext context) {
    final LivestreamProvider livestreamProvider =
        Provider.of<LivestreamProvider>(context);

    return SafeArea(
      child: StreamBuilder(
        stream: livestreamProvider.livestreamCall!.state.valueStream,
        initialData: livestreamProvider.livestreamCall!.state.value,
        builder: (context, snapshot) {
          final callState = snapshot.data!;
          final participant = callState.callParticipants.first;

          return Scaffold(
            body: Stack(
              children: [
                if (snapshot.hasData)
                  StreamVideoRenderer(
                    call: livestreamProvider.livestreamCall!,
                    videoTrackType: SfuTrackType.video,
                    participant: participant,
                  ),
                if (!snapshot.hasData)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (snapshot.hasData && callState.status.isDisconnected)
                  const Center(
                    child: Text('Stream not live'),
                  ),
                Positioned(
                  top: 12.0,
                  left: 12.0,
                  child: Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: Colors.red,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Viewers: ${callState.callParticipants.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.0,
                  right: 12.0,
                  child: Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: Colors.black,
                    child: GestureDetector(
                      onTap: () {
                        livestreamProvider.callEnd();
                        Navigator.pop(context);
                      },
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'End Call',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
