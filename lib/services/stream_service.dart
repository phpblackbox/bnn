// // stream_service.dart
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:stream_video_flutter/stream_video_flutter.dart';

// class StreamService {
//   final String _streamApiKey = '7dxct7rmwucw';
//   // final String _streamApiSecret = dotenv.env['STREAM_API_SECRET'] ?? '';
//   // final String _streamBaseUrl = dotenv.env['STREAM_BASE_URL'] ?? '';
//   final String _streamBackendUrl = dotenv.env['STREAM_BACKEND_TOKEN'] ?? '';

//   late String userToken;
//   late StreamVideo client;

//   StreamService._internal();

//   static final StreamService _instance = StreamService._internal();

//   factory StreamService() {
//     return _instance;
//   }

//   void initStream(
//     String id,
//     String name,
//     String image,
//   ) async {
//     StreamVideo.reset();

//     userToken = await getUserToken(id, name, "admin", image);

//     print(userToken);

//     StreamVideo(
//       _streamApiKey,
//       user: User.regular(
//         name: name,
//         userId: id,
//         role: 'admin',
//       ),
//       userToken: userToken,
//     );
//   }

//   Future<String> getUserToken(
//       String userId, String username, String role, String image) async {
//     final url = Uri.parse(_streamBackendUrl);
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'userId': userId,
//         'role': role,
//         'username': username,
//         'image': image
//       }),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load token');
//     }
//   }

//   Future<void> disconnect() async {
//     final videoClient = StreamVideo.instance;

//     await videoClient.disconnect();
//   }
// }
