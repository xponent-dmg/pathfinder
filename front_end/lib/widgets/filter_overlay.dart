import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class FilterOverlay extends StatefulWidget {
  const FilterOverlay({super.key});

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay> {
  // Location selection
  final List<String> _locations = [
    'AB1',
    'AB2',
    'AB3',
    'Clock Court',
    'MG auditorium',
  ];
  String? _selectedLocation;
  bool _isLocationDropdownOpen = false;

  // Date range selection
  DateTime? _startDate;
  DateTime? _endDate;

  // Category selection
  final List<String> _categories = [
    'Academic',
    'Cultural',
    'Sports',
    'Technology',
    'Arts',
    'Social',
    'Career',
    'Others'
  ];
  List<String> _selectedCategories = [];

  // Price filter
  RangeValues _priceRange = const RangeValues(0, 100);

  // Event type filter
  bool _showFreeEvents = true;
  bool _showPaidEvents = true;
  bool _showOnlineEvents = true;
  bool _showInPersonEvents = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with enhanced styling
          Row(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Spacer(),
              Text(
                "Filter Events",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: Icon(Icons.refresh, color: Colors.red[700], size: 16),
                label: Text(
                  "Reset",
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          Divider(color: Colors.grey[200], thickness: 1.5, height: 24),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Location Section
                _buildSectionTitle("Location"),
                _buildLocationSelector(),

                const SizedBox(height: 24),

                // Event Categories Section
                _buildSectionTitle("Event Categories"),
                _buildCategorySelector(),

                // Date Range Section
                _buildSectionTitle("Date Range"),
                _buildDateRangeSelector(),

                const SizedBox(height: 24),

                // Price Range Section
                _buildSectionTitle("Price Range (₹)"),
                _buildPriceRangeSlider(),

                const SizedBox(height: 24),

                // Event Type Section
                _buildSectionTitle("Event Type"),
                _buildEventTypeFilters(),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Apply Button with enhanced styling
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_alt, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Apply Filters",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isLocationDropdownOpen = !_isLocationDropdownOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Colors.blue[700],
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedLocation ?? 'Select location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedLocation == null
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isLocationDropdownOpen ? 0.5 : 0,
                  duration: Duration(milliseconds: 200),
                  child:
                      Icon(Icons.keyboard_arrow_down, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ),
        if (_isLocationDropdownOpen)
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.only(top: 4),
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  final isSelected = _selectedLocation == location;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLocation = location;
                        _isLocationDropdownOpen = false;
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          bottom: index < _locations.length - 1
                              ? BorderSide(color: Colors.grey[200]!, width: 0.5)
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          isSelected
                              ? Icon(Icons.check_circle,
                                  color: Colors.blue[700], size: 18)
                              : Icon(Icons.location_on_outlined,
                                  color: Colors.grey[400], size: 18),
                          SizedBox(width: 12),
                          Text(
                            location,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.blue[700]
                                  : Colors.black87,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final dateFormat = DateFormat('MMM d, yyyy');
    String dateRangeText = 'Select date range';

    if (_startDate != null && _endDate != null) {
      dateRangeText =
          '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';
    } else if (_startDate != null) {
      dateRangeText = '${dateFormat.format(_startDate!)} - Select end date';
    }

    return GestureDetector(
      onTap: _showDateRangePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: Colors.blue[700],
                size: 16,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                dateRangeText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _startDate == null ? Colors.grey[600] : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.blue[700], size: 14),
          ],
        ),
      ),
    );
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.blue[700]),
                    SizedBox(width: 10),
                    Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 400,
                  width: 360,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SfDateRangePicker(
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: _startDate != null && _endDate != null
                        ? PickerDateRange(_startDate, _endDate)
                        : null,
                    minDate: DateTime.now(),
                    maxDate: DateTime.now().add(const Duration(days: 365)),
                    todayHighlightColor: Colors.blue[700],
                    startRangeSelectionColor: Colors.blue[700],
                    endRangeSelectionColor: Colors.blue[700],
                    rangeSelectionColor: Colors.blue[100],
                    headerStyle: DateRangePickerHeaderStyle(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    onSubmit: (value) {
                      if (value is PickerDateRange) {
                        setState(() {
                          _startDate = value.startDate;
                          _endDate = value.endDate ?? value.startDate;
                        });
                      }
                      Navigator.pop(context);
                    },
                    onCancel: () => Navigator.pop(context),
                    showActionButtons: true,
                    confirmText: 'APPLY',
                    cancelText: 'CANCEL',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    // Map of category names to their respective icon data
    final Map<String, IconData> categoryIcons = {
      'Academic': Icons.school,
      'Cultural': Icons.theater_comedy,
      'Sports': Icons.sports,
      'Technology': Icons.computer,
      'Arts': Icons.palette,
      'Social': Icons.people,
      'Career': Icons.work,
      'Others': Icons.more_horiz,
    };

    // Split categories into two rows
    final int halfLength = (_categories.length / 2).ceil();
    final List<String> firstRowCategories = _categories.sublist(0, halfLength);
    final List<String> secondRowCategories = _categories.sublist(halfLength);

    return SizedBox(
      height: 180,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row of categories
            Row(
              children: firstRowCategories.map((category) {
                return _buildCategoryCard(
                    category, categoryIcons[category] ?? Icons.label);
              }).toList(),
            ),
            SizedBox(height: 12),
            // Second row of categories
            Row(
              children: secondRowCategories.map((category) {
                return _buildCategoryCard(
                    category, categoryIcons[category] ?? Icons.label);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, IconData iconData) {
    final bool isSelected = _selectedCategories.contains(category);

    // Define gradient colors based on selection state
    List<Color> gradientColors = isSelected
        ? [Colors.blue[700]!, Colors.blue[500]!]
        : [Colors.white, Colors.white];

    return Container(
      margin: EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedCategories.remove(category);
              } else {
                _selectedCategories.add(category);
              }
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
              border: Border.all(
                color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                width: isSelected ? 0 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Color.fromARGB(255, 71, 72, 156),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    iconData,
                    size: 18,
                    color: isSelected ? Colors.blue[700] : Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 20,
                activeColor: Colors.blue[700],
                inactiveColor: Colors.blue[100],
                labels: RangeLabels(
                  "₹${_priceRange.start.toInt()}",
                  _priceRange.end >= 1000
                      ? "₹1000+"
                      : "₹${_priceRange.end.toInt()}",
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹0",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "₹${_priceRange.start.toInt()} - ${_priceRange.end >= 1000 ? '1000+' : _priceRange.end.toInt()}",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      "₹1000+",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventTypeFilters() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            title: "Free Events",
            value: _showFreeEvents,
            icon: Icons.money_off,
            onChanged: (value) {
              setState(() {
                _showFreeEvents = value;
              });
            },
          ),
          Divider(height: 8, thickness: 0.5),
          _buildSwitchTile(
            title: "Paid Events",
            value: _showPaidEvents,
            icon: Icons.payments_outlined,
            onChanged: (value) {
              setState(() {
                _showPaidEvents = value;
              });
            },
          ),
          Divider(height: 8, thickness: 0.5),
          _buildSwitchTile(
            title: "Online Events",
            value: _showOnlineEvents,
            icon: Icons.laptop,
            onChanged: (value) {
              setState(() {
                _showOnlineEvents = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.blue[700]),
                SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[700],
            activeTrackColor: Colors.blue[200],
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedLocation = null;
      _startDate = null;
      _endDate = null;
      _selectedCategories = [];
      _priceRange = const RangeValues(0, 100);
      _showFreeEvents = true;
      _showPaidEvents = true;
      _showOnlineEvents = true;
      _showInPersonEvents = true;
      _isLocationDropdownOpen = false;
    });
  }

  void _applyFilters() {
    // Create a filter map to pass back to the search
    final filterData = {
      'location': _selectedLocation,
      'startDate': _startDate,
      'endDate': _endDate,
      'categories': _selectedCategories,
      'priceRange': _priceRange,
      'showFreeEvents': _showFreeEvents,
      'showPaidEvents': _showPaidEvents,
      'showOnlineEvents': _showOnlineEvents,
      'showInPersonEvents': _showInPersonEvents,
    };

    // Close the bottom sheet and return the filter data
    Navigator.pop(context, filterData);

    // Show a snackbar to confirm filters have been applied
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Filters applied successfully'),
          ],
        ),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
