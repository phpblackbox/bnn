import 'dart:io';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bnn/screens/post/post_item.dart';

class Posts extends StatefulWidget {
  final String? userId;
  final bool? bookmark;

  const Posts({super.key, this.userId, this.bookmark});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: Platform.isIOS ? 24 : 48);

  @override
  void initState() {
    super.initState();
    initialData(widget.userId, widget.bookmark);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_scrollListener);
    });
  }

  _scrollListener() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    if (_scrollController.hasClients && _scrollController.position != null) {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent * 1 &&
          !_scrollController.position.outOfRange &&
          !postProvider.loadingMore) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);

          final currentUserId = authProvider.user?.id;
          postProvider.loadingMore = true;
          if (currentUserId != null) {
            await postProvider.loadPosts(
                userId: widget.userId,
                bookmark: widget.bookmark,
                currentUserId: currentUserId);
          }
          postProvider.loadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> initialData(String? userId, bool? bookmark) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id;
      if (currentUserId != null) {
        postProvider.offset = 0;
        postProvider.posts = [];
        postProvider.loadPosts(
            userId: userId, bookmark: bookmark, currentUserId: currentUserId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: postProvider.loadingMore
            ? postProvider.posts!.length + 1
            : postProvider.posts?.length,
        itemBuilder: (context, index) {
          if (index < postProvider.posts!.length) {
            return PostItem(
              post: postProvider.posts![index],
              index: index,
              userId: widget.userId,
              onDelete: (index) {
                setState(() {
                  postProvider.posts!.removeAt(index);
                });
              },
            );
          } else {
            return Container(
              margin: EdgeInsets.all(4),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
        },
      ),
    );
  }
}
