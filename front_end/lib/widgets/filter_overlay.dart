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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Text(
                "Filter Events",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  "Reset",
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          Divider(color: Colors.grey[300]),

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

                // const SizedBox(height: 24),
                // Date Range Section
                _buildSectionTitle("Date Range"),
                _buildDateRangeSelector(),

                const SizedBox(height: 24),

                // Price Range Section
                _buildSectionTitle("Price Range (₹)"),
                _buildPriceRangeSlider(),

                const SizedBox(height: 24),

                // // Event Type Section
                // _buildSectionTitle("Event Type"),
                // _buildEventTypeFilters(),

                // const SizedBox(height: 16),
              ],
            ),
          ),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Apply Filters",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Select location'),
          value: _selectedLocation,
          items: _locations.map((String location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLocation = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: Text(
                dateRangeText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _startDate == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.calendar_month, color: Colors.blue[700]),
            const SizedBox(width: 8),
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Date Range',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  width: 360,
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
      height: 180, // Increased height to accommodate two rows
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

    return Container(
      // width: 100,
      margin: EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          // The main card
          Material(
            color: isSelected ? Colors.blue[100] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
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
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                    width: 0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 71, 72, 156),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.all(7),
                      child: Icon(
                        iconData,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.blue[700] : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
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
        ],
      ),
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
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
            _priceRange.end >= 1000 ? "₹1000+" : "₹${_priceRange.end.toInt()}",
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "₹0",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              "₹${_priceRange.start.toInt()} - ${_priceRange.end >= 1000 ? '1000+' : _priceRange.end.toInt()}",
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
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
      ],
    );
  }

  Widget _buildEventTypeFilters() {
    return Column(
      children: [
        _buildSwitchTile(
          title: "Free Events",
          value: _showFreeEvents,
          onChanged: (value) {
            setState(() {
              _showFreeEvents = value;
            });
          },
        ),
        _buildSwitchTile(
          title: "Paid Events",
          value: _showPaidEvents,
          onChanged: (value) {
            setState(() {
              _showPaidEvents = value;
            });
          },
        ),
        _buildSwitchTile(
          title: "Online Events",
          value: _showOnlineEvents,
          onChanged: (value) {
            setState(() {
              _showOnlineEvents = value;
            });
          },
        ),
        _buildSwitchTile(
          title: "In-Person Events",
          value: _showInPersonEvents,
          onChanged: (value) {
            setState(() {
              _showInPersonEvents = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15),
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
        content: Text('Filters applied'),
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
