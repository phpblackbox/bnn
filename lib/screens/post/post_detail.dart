import 'package:bnn/screens/post/post_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bnn/providers/post_provider.dart';

class PostDetail extends StatefulWidget {
  final int postId;

  const PostDetail({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  dynamic post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final postData = await postProvider.getPostById(widget.postId);
    setState(() {
      post = postData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (post == null) {
      return const Scaffold(
        body: Center(
          child: Text('Post not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: PostItem(
          post: post,
          index: 0,
          userId: post['author_id'],
          onDelete: (index) {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
