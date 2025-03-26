import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_finder/services/profile_picture_service.dart';
import 'package:path_finder/widgets/filter_overlay.dart';
import 'package:provider/provider.dart';
import 'package:path_finder/providers/user_provider.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  File? _file;
  // StreamSubscription? _profilePictureSubscription;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();

    // Subscribe to profile picture changes
    // _profilePictureSubscription =
    //     ProfilePictureService.profilePictureStream.listen((file) {
    //   if (mounted) {
    //     setState(() {
    //       _file = file;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    // Cancel subscription when widget is disposed
    // _profilePictureSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProfilePicture() async {
    File? tempFile = await ProfilePictureService.getProfilePicture();
    if (mounted) {
      setState(() {
        _file = tempFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 280.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      backgroundColor: Color.fromRGBO(182, 222, 255, 1),
      title: Center(
        child: Text(
          "PathFinder",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () {},
        icon: Image.asset(
          "assets/menu-icon.png",
          width: 30,
          height: 30,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Hero(
            tag: 'profile_pic',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/profile').then((_) {
                    // Refresh profile picture when returning from profile page
                    _loadProfilePicture();
                  });
                },
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (_file != null)
                      ? Image.file(
                          _file!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/profile_pics/profile-pic.jpg",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
            margin: EdgeInsets.only(bottom: 25, left: 20, right: 20),
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/search');
                },
                borderRadius: BorderRadius.circular(18),
                child: Row(
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.search_rounded,
                      size: 25,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: IgnorePointer(
                        child: TextField(
                          focusNode: FocusNode(),
                          onTapOutside: (event) {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          controller: TextEditingController(),
                          cursorColor: Colors.blue,
                          decoration: InputDecoration(
                            hintText: 'Search for events...',
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            border: InputBorder.none,
                            alignLabelWithHint: true,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final filterResult = await showModalBottomSheet(
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          context: context,
                          builder: (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: FilterOverlay(),
                          ),
                        );

                        // Process filter results
                        if (filterResult != null) {
                          print('Filter applied: ${filterResult.toString()}');
                        }
                      },
                      icon: Icon(
                        Icons.filter_alt,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(182, 222, 255, 1),
                Color.fromRGBO(229, 244, 255, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Spacer for the AppBar
              SizedBox(height: 80),
              Container(
                margin: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                padding: EdgeInsets.only(top: 5, right: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Consumer<UserProvider>(
                                builder: (context, value, child) => Text(
                                      "Hey ${(value.name.split(" ")[0] != 'new') ? value.name.split(" ")[0] : "there"}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                          ),
                        ),
                        SizedBox(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 4.0),
                              child: Text(
                                "Discover new events!",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed('/map');
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              "assets/map-icon2.jpg",
                              width: 80,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
