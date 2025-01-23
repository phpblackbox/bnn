class Message {
  final String sender;
  final String text;
  final String time;
  final bool isMe;

  Message(
      {required this.sender,
      required this.time,
      required this.text,
      required this.isMe});
}
