import 'package:bnn/screens/home/notifications.dart';
import 'package:bnn/screens/profile/suggested.dart';
import 'package:bnn/screens/reel/reel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bnn/providers/notification_provider.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late NotificationProvider _notificationProvider;
  bool _hasNotifications = false;
  bool _isCheckingNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notificationProvider =
            Provider.of<NotificationProvider>(context, listen: false);
        _checkNotifications();
      }
    });
  }

  Future<void> _checkNotifications() async {
    if (!mounted || _isCheckingNotifications) return;

    _isCheckingNotifications = true;

    try {
      await _notificationProvider.getMyNotifications();
      if (mounted) {
        setState(() {
          _hasNotifications = _notificationProvider.data.isNotEmpty;
        });
      }
    } finally {
      _isCheckingNotifications = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/bnn_logo.png',
              height: 60,
            ),
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ReelScreen()));
                  },
                  child: Text(
                    '9:16s',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 1.20,
                      letterSpacing: 0.50,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Suggested()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/icons/profile_plus.png',
                      width: 20.0,
                      height: 20.0,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Notifications()));
                    if (result == true && mounted) {
                      await _checkNotifications();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      _hasNotifications
                          ? 'assets/images/icons/notification_plus.png'
                          : 'assets/images/icons/notification.png',
                      width: _hasNotifications ? 20.0 : 17,
                      height: _hasNotifications ? 20.0 : 17,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
