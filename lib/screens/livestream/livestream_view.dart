// import 'package:bnn/providers/livestream_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';

// class LiveStreamView extends StatelessWidget {
//   const LiveStreamView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final LivestreamProvider livestreamProvider =
//         Provider.of<LivestreamProvider>(context);

//     final call = livestreamProvider.livestreamCall!;

//     return StreamBuilder(
//       stream: call.state.valueStream,
//       initialData: call.state.value,
//       builder: (context, snapshot) {
//         final callState = snapshot.data;
//         return Stack(
//           children: [
//             if (snapshot.hasData && callState != null && !callState.isBackstage)
//               StreamCallContainer(
//                 call: call,
//                 callContentBuilder: (context, call, state) {
//                   return StreamCallContent(
//                     call: call,
//                     callState: state,
//                     callParticipantsBuilder: (context, call, state) {
//                       // Show only the host's video
//                       final host = state.callParticipants
//                           .where((p) => p.userId == livestreamProvider.host)
//                           .firstOrNull;

//                       if (host == null) {
//                         return const Center(
//                           child: Text('Waiting for host...'),
//                         );
//                       }

//                       return StreamVideoRenderer(
//                         call: call,
//                         participant: host,
//                         videoFit: VideoFit.contain,
//                         videoTrackType: SfuTrackType.video,
//                       );
//                     },
//                   );
//                 },
//               ),
//             // StreamCallParticipant(
//             //   call: call,
//             //   participant: callState.localParticipant!,
//             // ),
//             // StreamCallParticipants(
//             //   call: call,
//             //   participants: callState.callParticipants,
//             //   layoutMode: ParticipantLayoutMode.grid,
//             // ),
//             // LivestreamPlayer(call: call),
//             // StreamCallContent(
//             //   call: call,
//             //   callState: callState,
//             //   callParticipantsBuilder: (context, call, state) {
//             //     return StreamCallParticipants(
//             //       call: call,
//             //       participants: callState.callParticipants,
//             //     );
//             //   },
//             // ),
//             // StreamCallParticipant(
//             //   call: call,
//             //   participant: callState.localParticipant!,
//             // ),
//             // StreamVideoRenderer(
//             //   call: call,
//             //   videoTrackType: SfuTrackType.screenShare,
//             //   participant: callState.callParticipants.first,
//             // ),
//             if (snapshot.hasData && callState != null && !callState.isBackstage)
//               Positioned(
//                 top: 12.0,
//                 left: 12.0,
//                 child: Material(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   color: Colors.red,
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'Viewers: ${callState.callParticipants.length}',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (snapshot.hasData && callState != null && callState.isBackstage)
//               const Material(
//                 child: Center(
//                   child: Text('Stream not live'),
//                 ),
//               ),
//             if (!snapshot.hasData)
//               const Center(
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
