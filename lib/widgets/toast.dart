import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class CustomToast {
  static void showNoramlToast(context, text) {
    showToast(text, context: context);
  }

  static void showToastWarningBottom(context, text) {
    showToast(
      text,
      context: context,
      axis: Axis.horizontal,
      textStyle: TextStyle(fontSize: 12.0, color: Colors.white),
      backgroundColor: Color(0xFFf0ad4e),
      fullWidth: true,
      duration: Duration(seconds: 4),
      borderRadius: BorderRadius.vertical(
          top: Radius.elliptical(5, 10), bottom: Radius.elliptical(5, 10)),
    );
  }

  static void showToastDangerBottom(context, text) {
    showToast(
      text,
      context: context,
      axis: Axis.horizontal,
      textStyle: TextStyle(fontSize: 12.0, color: Colors.white),
      backgroundColor: Color(0xFFd9534f),
      fullWidth: true,
      duration: Duration(seconds: 4),
      borderRadius: BorderRadius.vertical(
          top: Radius.elliptical(5, 10), bottom: Radius.elliptical(5, 10)),
    );
  }

  static void showToastSuccessTop(context, text) {
    showToast(
      text,
      context: context,
      axis: Axis.horizontal,
      toastHorizontalMargin: 10.0,
      position: StyledToastPosition(align: Alignment.topRight, offset: 20.0),
      duration: Duration(seconds: 4),
      textStyle: TextStyle(fontSize: 12.0, color: Colors.white),
      backgroundColor: Color(0xFF5cb85c),
      borderRadius: BorderRadius.vertical(
          top: Radius.elliptical(5, 10), bottom: Radius.elliptical(5, 10)),
    );
  }

  static void showToastWarningTop(context, text) {
    showToast(
      text,
      context: context,
      axis: Axis.horizontal,
      toastHorizontalMargin: 10.0,
      position: StyledToastPosition(align: Alignment.topRight, offset: 20.0),
      duration: Duration(seconds: 4),
      textStyle: TextStyle(fontSize: 12.0, color: Colors.white),
      backgroundColor: Color(0xFFf0ad4e),
      borderRadius: BorderRadius.vertical(
          top: Radius.elliptical(5, 10), bottom: Radius.elliptical(5, 10)),
    );
  }

  static void showToastDangerTop(context, text) {
    showToast(
      text,
      context: context,
      axis: Axis.horizontal,
      toastHorizontalMargin: 10.0,
      position: StyledToastPosition(align: Alignment.topRight, offset: 20.0),
      duration: Duration(seconds: 4),
      textStyle: TextStyle(fontSize: 12.0, color: Colors.white),
      backgroundColor: Color(0xFFd9534f),
      borderRadius: BorderRadius.vertical(
          top: Radius.elliptical(5, 10), bottom: Radius.elliptical(5, 10)),
    );
  }

  static void showToastSuccessBottom(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
