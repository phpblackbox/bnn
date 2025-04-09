import 'dart:math';

class Constants {
  // static const String splashLogo = 'assets/images/splash_bnn_logo.png';

  // static const String walkthroughImage1 = 'assets/images/walkthrough1.png';
  // static const String walkthroughImage2 = 'assets/images/walkthrough2.png';
  // static const String walkthroughImage3 = 'assets/images/walkthrough3.png';

  // static const String walkthroughIcon1 = 'assets/images/icons/message.png';
  // static const String walkthroughIcon2 = 'assets/images/icons/telegram.png';
  // static const String walkthroughIcon3 = 'assets/images/icons/privacy.png';
  // static const String walkthroughNextButton =
  //     'assets/images/walkthrough_btn.png';
  // static const String addphoto = 'assets/images/addphoto.png';
  // static const String logo = 'assets/images/bnn_logo.png';

  static const int storyDuration = 48;
  String formatWithCommas(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
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
    const int minutesInHour = 60;
    const int hoursInDay = 24;
    const int daysInMonth = 30;
    const int daysInYear = 365;

    if (duration.inMinutes < minutesInHour) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < hoursInDay) {
      return '${duration.inHours}h';
    } else if (duration.inDays < daysInMonth) {
      return '${duration.inDays}d';
    } else if (duration.inDays < daysInYear) {
      int months = duration.inDays ~/ daysInMonth;
      if (months == 1) {
        return 'a month';
      } else {
        return '${months} months';
      }
    } else {
      int years = duration.inDays ~/ daysInYear;
      if (years == 1) {
        return 'a year';
      } else {
        return '${years} years';
      }
    }
  }

  String generateCallId() {
    final random = Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(12,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();
    return randomString;
  }

  // these are fake data for skeleton
  static const List<dynamic> fakeAddParticipants = [
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p1.png',
      'name': 'Emelie',
      'mutal': '6 mutual friends'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p3.png',
      'name': 'Abigail',
      'mutal': '2 mutual friends'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p4.png',
      'name': 'Elizabeth',
      'mutal': '12 mutual friends'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p6.png',
      'name': 'Penelope',
      'mutal': '1 mutual friend'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p7.png',
      'name': 'Chloe',
      'mutal': '3 mutual friends'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p8.png',
      'name': 'Grace',
      'mutal': '4 mutual friends'
    },
  ];

  static const List<dynamic> fakeChatList = [
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p1.png',
      'name': 'Jason bosch',
      'content': 'Hey, how’s it goin?'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p3.png',
      'name': 'Jakob Curtis',
      'content': 'Yo, how are you doing?'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p4.png',
      'name': 'Abram Levin',
      'content': 'There is a new AI image generator software i use now'
    },
    {
      'id': '1',
      'avatar': 'assets/images/avatar/p5.png',
      'name': 'Marilyn Herwitz',
      'content': 'hey, i got new Pictures for you'
    },
  ];

  static const List<dynamic> fakeParentComments = [
    {
      "id": "1",
      "name": "User One",
      "time": "2 hours ago",
      "content": "This is a comment.",
      "likes": 5,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/d84a2718-cddc-42dd-949d-6d0d4a04cc64_489708.png"
      }
    },
    {
      "id": "2",
      "name": "User Two",
      "time": "1 hour ago",
      "content": "This is another comment.",
      "likes": 3,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/d84a2718-cddc-42dd-949d-6d0d4a04cc64_489708.png"
      }
    },
    {
      "id": "2",
      "name": "User Two",
      "time": "1 hour ago",
      "content": "This is another comment.",
      "likes": 3,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/d84a2718-cddc-42dd-949d-6d0d4a04cc64_489708.png"
      }
    },
    {
      "id": "2",
      "name": "User Two",
      "time": "1 hour ago",
      "content": "This is another comment.",
      "likes": 3,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/d84a2718-cddc-42dd-949d-6d0d4a04cc64_489708.png"
      }
    },
  ];

  static const dynamic fakeUserInfo = {
    "username": "John\nSmith",
    "posts": 35,
    "followers": 6552,
    "views": 128,
    "about":
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
    "year": "20yrs",
    "marital": "Married",
    "nationality": "African-American",
    "location": "United States, California",
    "content": "Content Creator",
  };

  static const List<Map<String, dynamic>> fakeFollwers = [
    {
      "id": "66cffab6-e17c-4a8d-a08c-6f6b8d118d31",
      "username": "Charlie",
      "avatar":
          "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png",
      "mutal": "1 mutal friend",
    },
    {
      "id": "66cffab6-e17c-4a8d-a08c-6f6b8d118d31",
      "username": "Charlie Fake Faker FakerName",
      "avatar":
          "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png",
      "mutal": "1 mutal friend",
    },
    {
      "id": "66cffab6-e17c-4a8d-a08c-6f6b8d118d31",
      "username": "Charlie Fake Faker FakerName",
      "avatar":
          "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/66cffab6-e17c-4a8d-a08c-6f6b8d118d31_156069.png",
      "mutal": "1 mutal friend",
    }
  ];

  static const List<dynamic> fakeNotifications = [
    {
      "id": 11,
      "created_at": "2025-01-21T07:02:44.7553+00:00",
      "user_id": "e09e81d7-5e8c-4885-9e68-b9725745f79e",
      "actor_id": "9e2a1bcb-0367-4998-8ecd-ac741907e893",
      "action_type": "like reel",
      "target_id": 2,
      "timeDiff": "today",
      "action": "Liked your post",
      "is_read": false,
      "content": null,
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/9e2a1bcb-0367-4998-8ecd-ac741907e893_350906.png",
        "username": "slack",
        "last_name": "Reynolds",
        "first_name": "Dennis"
      }
    },
    {
      "id": 10,
      "created_at": "2025-01-21T06:55:38.607353+00:00",
      "user_id": "e09e81d7-5e8c-4885-9e68-b9725745f79e",
      "actor_id": "9e2a1bcb-0367-4998-8ecd-ac741907e893",
      "action_type": "comment reel",
      "target_id": 2,
      "timeDiff": "today",
      "action": "Liked your post",
      "is_read": false,
      "content": "notification test",
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/9e2a1bcb-0367-4998-8ecd-ac741907e893_350906.png",
        "username": "slack",
        "last_name": "Reynolds",
        "first_name": "Dennis"
      }
    },
    {
      "id": 10,
      "created_at": "2025-01-21T06:55:38.607353+00:00",
      "user_id": "e09e81d7-5e8c-4885-9e68-b9725745f79e",
      "actor_id": "9e2a1bcb-0367-4998-8ecd-ac741907e893",
      "action_type": "comment reel",
      "target_id": 2,
      "timeDiff": "today",
      "action": "Liked your post",
      "is_read": false,
      "content": "notification test",
      "profiles": {
        "avatar":
            "https://prrbylvucoyewsezqcjn.supabase.co/storage/v1/object/public/avatars/9e2a1bcb-0367-4998-8ecd-ac741907e893_350906.png",
        "username": "slack",
        "last_name": "Reynolds",
        "first_name": "Dennis"
      }
    }
  ];
}
