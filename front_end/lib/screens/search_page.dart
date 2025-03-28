import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_finder/providers/event_provider.dart';
import 'package:path_finder/screens/search_screen.dart';
import 'dart:async';

import 'package:path_finder/services/api_services/events_api.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  // Controllers and variables
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final EventsService _eventsService = EventsService();
  bool _hasSearched = false;
  String _searchQuery = '';
  Timer? _debounce;

  // Animation controller for search results
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Category selection
  final List<String> _categories = [
    'All',
    'Clubs',
    'Events',
    'Workshops',
    'Conferences',
    'Networking'
  ];
  String _selectedCategory = 'All';

  // Mock recent searches
  final List<String> _recentSearches = [
    'Hackathon',
    'Photography Club',
    'Music Festival',
    'AI Workshop'
  ];

  Future<void> getAllEvents() async {
    await _eventsService.getAllEvents();
  }

  List<Map<String, dynamic>> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);

    // Fetch events when page initializes and make sure loading state is handled
    Future.microtask(() {
      final provider = context.read<EventProvider>();
      provider.fetchAllEvents();
      // if (provider.eventList.isEmpty && !provider.isLoading) {
      // provider.fetchAllEvents();
      // }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _animationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Debounce search to avoid excessive API calls
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        setState(() {
          _searchQuery = _searchController.text.trim();
          _hasSearched = true;
          _filterResults();
        });
        _animationController.forward(from: 0.0);
      } else {
        setState(() {
          _filteredResults = List.from(context.read<EventProvider>().eventList);
        });
      }
    });
  }

  // Filter results based on search query and category
  void _filterResults() {
    final query = _searchQuery.toLowerCase();
    final allEvents = context.read<EventProvider>().eventList;
    setState(() {
      if (_selectedCategory == 'All') {
        _filteredResults = allEvents
            .where((result) =>
                result['name'].toString().toLowerCase().contains(query) ||
                result['location'].toString().toLowerCase().contains(query))
            .toList();
        print("filtered events: ${_filteredResults.length}");
      } else {
        _filteredResults = allEvents
            .where((result) => (result['name']
                    .toString()
                    .toLowerCase()
                    .contains(query) ||
                result['location'].toString().toLowerCase().contains(query)))
            .toList();
      }
    });
  }

  // Handle category selection
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterResults();
    });
    _animationController.forward(from: 0.0);
  }

  // Clear search
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredResults = List.from(context.read<EventProvider>().eventList);
    });
  }

  // Select a recent search
  // void _selectRecentSearch(String search) {
  //   _searchController.text = search;
  //   setState(() {
  //     _searchQuery = search;
  //     _hasSearched = true;
  //     _filterResults();
  //   });
  //   _animationController.forward(from: 0.0);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Add this to resize when keyboard appears
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Search",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search for events...",
                  hintStyle: TextStyle(
                      color: Colors.grey[500], fontWeight: FontWeight.w600),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                style: TextStyle(fontSize: 16),
                onTap: () {
                  setState(() {});
                },
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                    _hasSearched = true;
                    if (!_recentSearches.contains(value) && value.isNotEmpty) {
                      _recentSearches.insert(0, value);
                      if (_recentSearches.length > 5) {
                        _recentSearches.removeLast();
                      }
                    }
                  });
                  _filterResults();
                  _animationController.forward(from: 0.0);
                },
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category filter chips - Make more compact when keyboard is open
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom > 0 ? 50 : 60,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(category),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                            fontSize:
                                MediaQuery.of(context).viewInsets.bottom > 0
                                    ? 12
                                    : 14,
                          ),
                          selectedColor: Colors.blue[700],
                          backgroundColor: Colors.grey[100],
                          onSelected: (selected) {
                            _selectCategory(category);
                          },
                          elevation: isSelected ? 2 : 0,
                          shadowColor: Colors.black.withAlpha(76),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          // Make chips smaller when keyboard is visible
                          visualDensity:
                              MediaQuery.of(context).viewInsets.bottom > 0
                                  ? VisualDensity(horizontal: -1, vertical: -1)
                                  : VisualDensity.standard,
                          padding: MediaQuery.of(context).viewInsets.bottom > 0
                              ? EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Recent searches or results - Use Flexible instead of Expanded for better adaptation
            Flexible(
              child: SearchScreen(
                fadeAnimation: _fadeAnimation,
                filteredResults: _filteredResults,
              ),
            ),
            // Flexible(
            //   child: _buildSearchResults(),
            // ),
          ],
        ),
      ),
    );
  }

  // Build recent searches widget with scrollable content
  // Widget _buildRecentSearches() {
  //   return SingleChildScrollView(
  //     physics: BouncingScrollPhysics(),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             "Recent Searches",
  //             style: GoogleFonts.poppins(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black87,
  //             ),
  //           ),
  //           SizedBox(height: 16),
  //           _recentSearches.isEmpty
  //               ? Center(
  //                   child: Text(
  //                     "No recent searches",
  //                     style: TextStyle(
  //                       color: Colors.grey[600],
  //                       fontSize: 16,
  //                     ),
  //                   ),
  //                 )
  //               : Column(
  //                   children: _recentSearches.map((search) {
  //                     return ListTile(
  //                       leading: Icon(Icons.history, color: Colors.grey[600]),
  //                       title: Text(
  //                         search,
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           color: Colors.black87,
  //                         ),
  //                       ),
  //                       trailing: Icon(Icons.north_west,
  //                           color: Colors.grey[600], size: 18),
  //                       contentPadding: EdgeInsets.symmetric(horizontal: 8),
  //                       dense: true,
  //                       onTap: () => _selectRecentSearch(search),
  //                     );
  //                   }).toList(),
  //                 ),
  //           SizedBox(height: 24),
  //           Text(
  //             "Popular Searches",
  //             style: GoogleFonts.poppins(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black87,
  //             ),
  //           ),
  //           SizedBox(height: 16),
  //           Wrap(
  //             spacing: 8,
  //             runSpacing: 8,
  //             children: [
  //               "Programming Club",
  //               "Career Fair",
  //               "Music Festival",
  //               "Workshop",
  //               "Sports Tournament"
  //             ].map((item) {
  //               return InkWell(
  //                 onTap: () => _selectRecentSearch(item),
  //                 borderRadius: BorderRadius.circular(50),
  //                 child: Container(
  //                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey[100],
  //                     borderRadius: BorderRadius.circular(50),
  //                     border: Border.all(color: Colors.grey[300]!),
  //                   ),
  //                   child: Text(
  //                     item,
  //                     style: TextStyle(
  //                       color: Colors.black87,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //           // Add extra space at bottom for keyboard
  //           SizedBox(
  //               height: MediaQuery.of(context).viewInsets.bottom > 0 ? 120 : 0),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
