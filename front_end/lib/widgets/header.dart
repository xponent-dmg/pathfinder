import 'package:flutter/material.dart';
import 'package:path_finder/widgets/filter_overlay.dart';
import 'package:provider/provider.dart';
import 'package:path_finder/providers/user_provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final firstName = userProvider.name.isNotEmpty
        ? userProvider.name.split(' ')[0]
        : 'there';
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
                  Navigator.of(context).pushNamed('/profile');
                },
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    "assets/profile-pic.jpg",
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
                  child: TextField(
                    focusNode: FocusNode(),
                    onTapOutside: (event) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    controller: TextEditingController(),
                    cursorColor: Colors.blue,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
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
                IconButton(
                  onPressed: () async {
                    final filterResult = await showModalBottomSheet(
                      isScrollControlled:
                          true, // Makes the modal take up more space
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      context: context,
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.75, // Take up 75% of screen height
                        child: FilterOverlay(),
                      ),
                    );

                    // Process filter results
                    if (filterResult != null) {
                      // You can implement filtering logic here or pass to a provider
                      print('Filter applied: ${filterResult.toString()}');

                      // Example: Extracting some values

                      // Add your search filtering logic based on these values
                    }
                  },
                  icon: Icon(
                    Icons.filter_alt,
                    color: Colors.grey,
                  ),
                )
              ],
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
                              "Hey $firstName",
                              style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              ),
                            )),
                        ),
                      ),
                      SizedBox(
                        child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                        child: Text(
                          "Discover new events!",
                          style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          ),
                        ),
                        ),
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
