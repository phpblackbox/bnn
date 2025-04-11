import 'package:bnn/providers/profile_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/inputs/custom-input-field.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Following extends StatefulWidget {
  const Following({super.key});

  @override
  State<Following> createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  final supabase = Supabase.instance.client;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  List<Map<String, dynamic>> fillteredFollowing = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.loading = true;
      await profileProvider.getFollowing();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            "Following",
            style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.0),
          onPressed: () {
            Navigator.pop(context);
            profileProvider.getCountsOfProfileInfo();
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Column(
          children: [
            CustomInputField(
              placeholder: "Search for friends",
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                if (value.isNotEmpty) {
                  final data = profileProvider.following
                      .where((follower) =>
                          (follower['name'] as String?)
                              ?.toLowerCase()
                              .contains(value.toLowerCase()) ??
                          false)
                      .toList();
                  fillteredFollowing = data;
                }
              },
              icon: Icons.search,
            ),
            SizedBox(height: 20),
            Expanded(
              child: Skeletonizer(
                enabled: profileProvider.loading,
                enableSwitchAnimation: true,
                child: ListView.builder(
                  // shrinkWrap: true,
                  itemCount: searchQuery.isEmpty
                      ? profileProvider.following.length
                      : fillteredFollowing.length,
                  itemBuilder: (context, index) {
                    final item = searchQuery.isEmpty
                        ? profileProvider.following[index]
                        : fillteredFollowing[index];
                    return Container(
                      padding: EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/user-profile',
                              arguments: {'userId': item['id']});
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(item['avatar']),
                              radius: 25,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? "",
                                    style: TextStyle(
                                      color: Color(0xFF4D4C4A),
                                      fontSize: 12,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700,
                                      height: 1.50,
                                    ),
                                  ),
                                  Text(
                                    item['mutal'] ?? "",
                                    style: TextStyle(
                                      color: Color(0xFF4D4C4A),
                                      fontFamily: "Poppins",
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 40),
                            Expanded(
                              child: ButtonGradientMain(
                                label: 'Unfollow',
                                onPressed: () async {
                                  await profileProvider.unfollow(item['r_id']);
                                  CustomToast.showToastSuccessTop(
                                      context, "Successfully unfollowed!");
                                },
                                textColor: Colors.white,
                                gradientColors: profileProvider.loading
                                    ? [Colors.transparent, Colors.transparent]
                                    : [
                                        AppColors.primaryBlack,
                                        AppColors.primaryRed
                                      ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
