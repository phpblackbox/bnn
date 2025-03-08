// import 'package:bnn/providers/livestream_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';

// class LiveStreamScreen extends StatefulWidget {
//   const LiveStreamScreen({
//     super.key,
//   });

//   @override
//   State<LiveStreamScreen> createState() => _LiveStreamScreenState();
// }

// class _LiveStreamScreenState extends State<LiveStreamScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final LivestreamProvider livestreamProvider =
//         Provider.of<LivestreamProvider>(context);

//     return SafeArea(
//       child: StreamBuilder(
//         stream: livestreamProvider.livestreamCall!.state.valueStream,
//         initialData: livestreamProvider.livestreamCall!.state.value,
//         builder: (context, snapshot) {
//           final callState = snapshot.data!;
//           final participant = callState.callParticipants.first;

//           return Scaffold(
//             appBar: AppBar(
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: OutlinedButton(
//                     onPressed: () {
//                       livestreamProvider.callEnd();
//                       Navigator.pop(context);
//                     },
//                     child: const Text('End Call'),
//                   ),
//                 ),
//               ],
//               title: Text('Viewers: ${callState.callParticipants.length}'),
//               automaticallyImplyLeading: false,
//             ),
//             body: Stack(
//               children: [
//                 if (snapshot.hasData)
//                   StreamVideoRenderer(
//                     call: livestreamProvider.livestreamCall!,
//                     videoTrackType: SfuTrackType.video,
//                     participant: participant,
//                   ),
//                 if (!snapshot.hasData)
//                   const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 if (snapshot.hasData && callState.status.isDisconnected)
//                   const Center(
//                     child: Text('Stream not live'),
//                   ),

//                 StreamCallContainer(
//                   call: livestreamProvider.livestreamCall!,
//                   callContentBuilder: (context, call, state) {
//                     var participant = state.callParticipants.firstWhere(
//                       (e) => e.userId == StreamVideo.instance.currentUser.id,
//                     );

//                     return StreamCallContent(
//                       call: call,
//                       callState: callState,
//                       callParticipantsBuilder: (context, call, state) {
//                         return StreamCallParticipants(
//                           call: call,
//                           participants: [participant],
//                           callParticipantBuilder:
//                               (context, callParticipant, state) {
//                             // Build call participant video
//                             return StreamCallParticipant(
//                                 call: call, participant: state);
//                           },
//                         );
//                       },
//                     );
//                   },
//                 ),
//                 // LivestreamPlayer(call: livestreamProvider.livestreamCall!)
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
