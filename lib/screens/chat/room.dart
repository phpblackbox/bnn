import 'package:bnn/screens/chat/oneVideoCall.dart';
import 'package:bnn/screens/chat/oneVoiceCall.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({
    super.key,
    required this.room,
  });

  final types.Room room;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  bool _isAttachmentUploading = false;
  late SupabaseChatController _chatController;

  @override
  void initState() {
    _chatController = SupabaseChatController(room: widget.room);
    super.initState();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _showMenuModal(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final size = overlay.size;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(size.width - 100, 0, 0, size.height),
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: Column(children: [
            Row(children: [
              Icon(Icons.person, color: Color(0xFF4D4C4A)),
              SizedBox(width: 10),
              Text(
                'View Profile',
                style: TextStyle(color: Color(0xFF4D4C4A)),
              )
            ]),
            Divider()
          ]),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Column(children: [
            Row(children: [
              Icon(Icons.delete_outline, color: Color(0xFF4D4C4A)),
              SizedBox(width: 10),
              Text(
                'Delete Profile',
                style: TextStyle(color: Color(0xFF4D4C4A)),
              )
            ]),
            Divider()
          ]),
        ),
        PopupMenuItem<int>(
          value: 3,
          child: Column(children: [
            Row(children: [
              Icon(Icons.search, color: Color(0xFF4D4C4A)),
              SizedBox(width: 10),
              Text(
                'Search Chat',
                style: TextStyle(color: Color(0xFF4D4C4A)),
              )
            ]),
            Divider()
          ]),
        ),
        PopupMenuItem<int>(
          value: 4,
          child: Column(children: [
            Row(children: [
              Icon(Icons.block_flipped, color: Color(0xFF4D4C4A)),
              SizedBox(width: 10),
              Text(
                'Block User',
                style: TextStyle(color: Color(0xFF4D4C4A)),
              )
            ]),
            Divider()
          ]),
        ),
        PopupMenuItem<int>(
          value: 5,
          child: Column(children: [
            Row(children: [
              Icon(Icons.bug_report_outlined, color: Color(0xFF4D4C4A)),
              SizedBox(width: 10),
              Text(
                'Report User',
                style: TextStyle(color: Color(0xFF4D4C4A)),
              )
            ]),
          ]),
        ),
      ],
    ).then((value) {
      if (value != null) {
        // Handle the selected option here
        print('Selected option: $value');
      }
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 130,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.image),
                      Text('Image'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.attach_file),
                      Text('File'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      _setAttachmentUploading(true);
      try {
        final bytes = result.files.single.bytes;
        final name = result.files.single.name;
        final uploadResult = await SupabaseChatCore.instance
            .uploadAsset(widget.room, name, bytes!);
        final message = types.PartialFile(
          mimeType: uploadResult.mimeType,
          name: name,
          size: result.files.single.size,
          uri: uploadResult.url,
        );
        await SupabaseChatCore.instance.sendMessage(message, widget.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );
    if (result != null) {
      _setAttachmentUploading(true);
      final bytes = await result.readAsBytes();
      final size = bytes.length;
      final image = await decodeImageFromList(bytes);
      final name = result.name;
      try {
        final uploadResult = await SupabaseChatCore.instance
            .uploadAsset(widget.room, name, bytes);
        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uploadResult.url,
          width: image.width.toDouble(),
        );
        await SupabaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      final client = http.Client();
      final request = await client.get(
        Uri.parse(message.uri),
        headers: SupabaseChatCore.instance.httpSupabaseHeaders,
      );
      final result = await FileSaver.instance.saveFile(
        name: message.uri.split('/').last,
        bytes: request.bodyBytes,
      );
      await OpenFilex.open(result);
    }
  }

  Future<void> _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) async {
    final updatedMessage = message.copyWith(previewData: previewData);

    await SupabaseChatCore.instance
        .updateMessage(updatedMessage, widget.room.id);
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    await _chatController.endTyping();
    await SupabaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  String formatDateTime(int? timestamp) {
    if (timestamp == null) {
      return 'No date available';
    }

    DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();

    // Check if the message is from today
    bool isToday = now.year == messageDate.year &&
        now.month == messageDate.month &&
        now.day == messageDate.day;

    // Check if the message is from yesterday
    bool isYesterday = now.year == messageDate.year &&
        now.month == messageDate.month &&
        now.day == messageDate.day - 1;

    // Format based on whether it's today, yesterday, or earlier
    if (isToday) {
      var timeFormat = DateFormat('hh:mm a'); // Format for time
      return timeFormat.format(messageDate);
    } else if (isYesterday) {
      var yesterdayFormat =
          DateFormat('Yesterday, hh:mm a'); // Format for yesterday
      return yesterdayFormat.format(messageDate);
    } else {
      var dateFormat =
          DateFormat('MMM dd, hh:mm a'); // Format for full date and time
      return dateFormat.format(messageDate);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(170),
          child: Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Color(0xFF820200),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.0)),
            child: Column(
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 20.0,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Spacer(),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.local_phone,
                            size: 20.0,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OneVoiceCall()));
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.video_camera_back_outlined,
                            size: 20.0,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OneVideoCall()));
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            size: 20.0,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _showMenuModal(context);
                          },
                        ),
                      ],
                    )
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: widget.room.imageUrl == null
                              ? null
                              : NetworkImage(widget.room.imageUrl!),
                        ),
                        SizedBox(width: 16),
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.room.name!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Online',
                              style: TextStyle(
                                color: Colors.white
                                    .withOpacity(0.6299999952316284),
                                fontSize: 10,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      ],
                    ))
              ],
            ),
          ),
        ),
        body: StreamBuilder<List<types.Message>>(
          initialData: const [],
          stream: _chatController.messages,
          builder: (context, messages) => StreamBuilder<List<types.User>>(
            initialData: const [],
            stream: _chatController.typingUsers,
            builder: (context, users) => Chat(
              // showUserNames: true,
              showUserAvatars: true,
              theme: DefaultChatTheme(
                backgroundColor: Colors.white,
                primaryColor: Colors.transparent,
                secondaryColor: Colors.transparent,
                inputContainerDecoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                dateDividerTextStyle:
                    TextStyle(color: Colors.transparent, fontSize: 1),
                dateDividerMargin: EdgeInsets.all(0),
                inputTextDecoration: InputDecoration(
                  hintText: "Write a message...",
                  hintStyle: TextStyle(color: Color(0x99898989)),
                  border: InputBorder.none, // Remove the border
                  enabledBorder: InputBorder.none, // Remove the enabled border
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFEAEAEA),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                inputTextStyle: TextStyle(fontSize: 12),
                inputTextColor: Color(0xFF4D4C4A),
                sendButtonIcon: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset(
                    'assets/images/message_send_btn.png',
                    fit: BoxFit.fill,
                  ),
                ),
                sendButtonMargin: EdgeInsets.all(0),
                attachmentButtonMargin: EdgeInsets.all(0),
                inputPadding: EdgeInsets.only(top: 12, bottom: 12),
                inputMargin:
                    EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
                inputBackgroundColor: Color(0xFFE9E9E9),
                inputBorderRadius: BorderRadius.circular(40.0),
                messageMaxWidth: 550,
              ),
              typingIndicatorOptions: TypingIndicatorOptions(
                typingUsers: users.data ?? [],
              ),
              isAttachmentUploading: _isAttachmentUploading,
              messages: messages.data ?? [],
              onAttachmentPressed: _handleAttachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              user: SupabaseChatCore.instance.loggedUser!,
              imageHeaders: SupabaseChatCore.instance.httpSupabaseHeaders,
              onMessageVisibilityChanged: (message, visible) async {
                if (message.status != types.Status.seen &&
                    message.author.id !=
                        SupabaseChatCore.instance.loggedSupabaseUser!.id) {
                  await SupabaseChatCore.instance.updateMessage(
                    message.copyWith(status: types.Status.seen),
                    widget.room.id,
                  );
                }
              },
              onEndReached: _chatController.loadPreviousMessages,
              inputOptions: InputOptions(
                enabled: true,
                onTextChanged: (text) => _chatController.onTyping(),
              ),

              textMessageBuilder: (message,
                  {required int messageWidth, required bool showName}) {
                bool isMe = (message.author.id ==
                    SupabaseChatCore.instance.loggedUser!.id);

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft:
                            isMe ? Radius.circular(15) : Radius.circular(0),
                        bottomRight:
                            isMe ? Radius.circular(0) : Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.metadata != null)
                          isMe
                              ? Text(
                                  "You replied to their story",
                                  style: TextStyle(
                                      color: Color(0xFF4D4C4A), fontSize: 10),
                                )
                              : Text(
                                  "Replied to your story",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 10),
                                ),
                        if (message.metadata != null)
                          Image.network(
                            message.metadata!["image_url"],
                            fit: BoxFit.fill,
                            width: 108,
                            height: 190,
                          ),
                        Text(
                          message.text,
                          style: TextStyle(color: Colors.black, fontSize: 10),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatDateTime(message.createdAt),
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            SizedBox(width: 16),
                            if (isMe)
                              message.status.toString() == "Status.seen"
                                  ? Icon(
                                      Icons.done_all_outlined,
                                      color: Color(0xFFF30802),
                                      size: 14,
                                    )
                                  : Icon(
                                      Icons.done,
                                      color: Color(0xFFF30802),
                                      size: 14,
                                    )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
}
