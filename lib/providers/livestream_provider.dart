// import 'package:bnn/services/livestream_service.dart';
// import 'package:bnn/utils/constants.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class LivestreamProvider extends ChangeNotifier {
//   final _livestreamService = LivestreamService();
//   final supabase = Supabase.instance.client;

//   List<Map<String, dynamic>> channels = [];

//   String host = "";

//   Call? livestreamCall;
//   late String callId;

//   bool _loading = true;
//   bool get loading => _loading;
//   set loading(bool value) {
//     _loading = value;
//     notifyListeners();
//   }

//   Future<void> initData() async {
//     loading = true;
//     channels = await _livestreamService.getLivestreams();
//     loading = false;
//   }

//   Future<Result<CallReceivedOrCreatedData>> joinCall() async {
//     loading = true;
//     // callId = Constants().generateCallId();
//     callId = "sm23C4G9eBq1";

//     livestreamCall = StreamVideo.instance
//         .makeCall(callType: StreamCallType.defaultType(), id: callId);

//     var result = await livestreamCall!.getOrCreate();
//     loading = false;
//     return result;
//   }

//   Future<Result<CallReceivedOrCreatedData>> createLivestream() async {
//     loading = true;
//     // callId = Constants().generateCallId();
//     callId = "sm23C4G9eBqO";

//     livestreamCall = StreamVideo.instance
//         .makeCall(callType: StreamCallType.defaultType(), id: callId);

//     final result = await livestreamCall!.getOrCreate();

//     if (result.isSuccess) {
//       // await _livestreamService.upsert(callId, true);
//       // final result = await _livestreamService.getLivestreamByCallId(callId);
//       // host = result["call_id"];
//       // await livestreamCall!.join();
//       // await livestreamCall!.goLive();
//     }
//     loading = false;
//     return result;
//   }

//   Future<Result<CallReceivedOrCreatedData>> joinLivestream(
//       String callId) async {
//     loading = true;

//     livestreamCall = StreamVideo.instance
//         .makeCall(callType: StreamCallType.defaultType(), id: callId);

//     final result = await livestreamCall!.getOrCreate();

//     if (result.isSuccess) {
//       final result = await _livestreamService.getLivestreamByCallId(callId);
//       host = result["call_id"];
//       await livestreamCall!.join();
//     }

//     loading = false;

//     return result;
//   }

//   Stream<List<Map<String, dynamic>>> getData() {
//     supabase
//         .channel('public:livestream')
//         .onPostgresChanges(
//             event: PostgresChangeEvent.all,
//             schema: 'public',
//             table: 'livestream',
//             callback: (payload) async {
//               if (payload.eventType.toString() ==
//                       "PostgresChangeEvent.update" ||
//                   payload.eventType.toString() ==
//                       "PostgresChangeEvent.insert") {
//                 // final meId = supabase.auth.currentUser!.id;
//                 // payload.newRecord["user_id"] != meId
//                 print("I got the event");
//                 bool callIdExists = channels.any((channel) =>
//                     channel['call_id'] == payload.newRecord['call_id']);

//                 if (callIdExists && !payload.newRecord['is_active']) {
//                   channels.removeWhere((channel) =>
//                       channel['call_id'] == payload.newRecord['call_id']);
//                 } else if (payload.newRecord['is_active']) {
//                   channels.add(payload.newRecord);
//                 }
//                 notifyListeners();
//               }
//             })
//         .subscribe();
//     return Stream.fromIterable([channels]);
//   }

//   Future<void> callEnd() async {
//     _livestreamService.update(callId, false);
//     livestreamCall!.end();
//   }
// }
