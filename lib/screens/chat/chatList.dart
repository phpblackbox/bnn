import 'package:bnn/screens/chat/chat.dart';
import 'package:bnn/screens/chat/room.dart';
import 'package:bnn/screens/chat/users.dart';
import 'package:bnn/screens/signup/CustomInputField.dart';
import 'package:bnn/widgets/room_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final TextEditingController searchController = TextEditingController();
  final List<dynamic> data = [
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

  static const _pageSize = 20;
  String _filter = '';
  final PagingController<int, types.Room> _controller =
      PagingController(firstPageKey: 0);

  static const _pageSizeUser = 20;
  String _filterUser = '';

  @override
  void initState() {
    _controller.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setFilters(String filter) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filter = filter;
      if (mounted) {
        _controller.nextPageKey = 0;
        _controller.refresh();
      }
    });
  }

  Future<void> _fetchPage(int offset) async {
    try {
      final newItems = await SupabaseChatCore.instance
          .rooms(filter: _filter, offset: offset, limit: _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _controller.appendLastPage(newItems);
      } else {
        final nextPageKey = offset + newItems.length;
        _controller.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _controller.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: [
        Container(
          child: Row(children: [
            Expanded(
              child: CustomInputField(
                placeholder: "Search for friends",
                controller: searchController,
                onChanged: (value) => _setFilters(value),
                icon: Icons.search,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => const UsersPage(),
                  ),
                );
              },
            )
          ]),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _controller.nextPageKey = 0;
                  _controller.refresh();
                }
              });
            },
            child: StreamBuilder<List<types.Room>>(
              stream: SupabaseChatCore.instance.roomsUpdates(),
              builder: (context, snapshot) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    if (_filter == '' && snapshot.data != null) {
                      _controller.itemList = SupabaseChatCore.updateRoomList(
                        _controller.itemList ?? [],
                        snapshot.data!,
                      );
                    }
                  }
                });
                return PagedListView<int, types.Room>(
                  pagingController: _controller,
                  builderDelegate: PagedChildBuilderDelegate<types.Room>(
                    itemBuilder: (context, room, index) => RoomTile(
                      room: room,
                      onTap: (room) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RoomPage(
                              room: room,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ));
  }
}
