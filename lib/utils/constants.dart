import 'dart:math';
import 'package:bnn/models/profiles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static const String splashLogo = 'assets/images/splash_bnn_logo.png';

  static const String walkthroughImage1 = 'assets/images/walkthrough1.png';
  static const String walkthroughImage2 = 'assets/images/walkthrough2.png';
  static const String walkthroughImage3 = 'assets/images/walkthrough3.png';

  static const String walkthroughIcon1 = 'assets/images/icons/message.png';
  static const String walkthroughIcon2 = 'assets/images/icons/telegram.png';
  static const String walkthroughIcon3 = 'assets/images/icons/privacy.png';
  static const String walkthroughNextButton =
      'assets/images/walkthrough_btn.png';
  static const String addphoto = 'assets/images/addphoto.png';
  static const String logo = 'assets/images/bnn_logo.png';

  Profiles? profile;
  static Future<void> saveProfile(Profiles profileData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', profileData.id);
    await prefs.setString('first_name', profileData.firstName);
    await prefs.setString('last_name', profileData.lastName);
    await prefs.setString('username', profileData.username);
    await prefs.setInt('age', profileData.age);
    await prefs.setString('bio', profileData.bio!);
    await prefs.setInt('gender', profileData.gender);
    await prefs.setString('avatar', profileData.avatar);
  }

  static Future<Profiles?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    String? firstName = prefs.getString('first_name');
    String? lastName = prefs.getString('last_name');
    String? username = prefs.getString('username');
    int? age = prefs.getInt('age');
    String? bio = prefs.getString('bio');
    int? gender = prefs.getInt('gender');
    String? avatar = prefs.getString('avatar');

    if (id != null) {
      return Profiles(
        id: id,
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        username: username ?? '',
        age: age ?? 0,
        bio: bio ?? '',
        gender: gender ?? 0,
        avatar: avatar ?? '',
      );
    }
    return null; // Return null if no profile is found
  }

  String generateRandomNumberString(int length) {
    final Random random = Random();
    String randomString = '';

    for (int i = 0; i < length; i++) {
      randomString +=
          random.nextInt(10).toString(); // Generates a digit between 0 and 9
    }

    return randomString;
  }

  String formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h';
    } else if (duration.inDays <= 30) {
      return '${duration.inDays}d';
    } else {
      return '30+d'; // For any duration greater than 30 days
    }
  }
}
