import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_finder/providers/event_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_snackbar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_finder/services/api_services/events_api.dart';

class EventCreatePage extends StatefulWidget {
  const EventCreatePage({super.key});

  @override
  State<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends State<EventCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final EventsService _eventsService = EventsService();
  bool _isLoading = false;

  // Controllers
  final _eventNameController = TextEditingController();
  final _eventDetailsController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final _clubNameController = TextEditingController();
  final _roomNoController = TextEditingController();

  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _mounted = true;
  }

  @override
  void dispose() {
    _mounted = false;
    _eventNameController.dispose();
    _eventDetailsController.dispose();
    _eventLocationController.dispose();
    _clubNameController.dispose();
    _roomNoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar(
          text: 'Failed to pick image: $e',
          color: Colors.red,
        ).build(),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _eventDate) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _handleCreateEvent() async {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      if (_eventDate == null) {
        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar(
              text: 'Please select an event date',
              color: Colors.red,
            ).build(),
          );
        }
        return;
      }

      if (_startTime == null || _endTime == null) {
        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar(
              text: 'Please select start and end times',
              color: Colors.red,
            ).build(),
          );
        }
        return;
      }

      if (_imageFile == null) {
        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar(
              text: 'Please upload an event image',
              color: Colors.red,
            ).build(),
          );
        }
        return;
      }

      // Show loading indicator
      if (_mounted) {
        setState(() {
          _isLoading = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackbar(text: 'Creating event...').build(),
        );
      }

      try {
        print('Starting event creation process');
        // Call API to create event
        Map<String, dynamic> result = await _eventsService.createEvent(
          name: _eventNameController.text,
          details: _eventDetailsController.text,
          location: _eventLocationController.text,
          roomNo: _roomNoController.text,
          eventDate: _eventDate!,
          startTime: _formatTimeOfDay(_startTime!),
          endTime: _formatTimeOfDay(_endTime!),
          imageFile: _imageFile,
          context: context,
        );

        // Check if widget is still mounted before updating state
        if (!_mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          // First update the provider
          try {
            await Provider.of<EventProvider>(context, listen: false)
                .fetchAllEvents();
            await Provider.of<EventProvider>(context, listen: false)
                .fetchTodaysEvents();
          } catch (e) {
            print('Error refreshing events: $e');
            // Continue anyway, as the event was created successfully
          }

          // Then show success message
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar(
              text: 'Event created successfully!',
              color: Colors.green,
            ).build(),
          );

          // Navigate back safely with a slight delay
          if (_mounted) {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          }
        } else {
          // Error creating event
          if (_mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackbar(
                text: result['message'] ?? 'Error creating event',
                color: Colors.red,
              ).build(),
            );
          }
        }
      } catch (e) {
        if (_mounted) {
          setState(() {
            _isLoading = false;
          });
          print('Exception caught during event creation: $e');

          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar(
              text: 'Error: ${e.toString()}',
              color: Colors.red,
            ).build(),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent with light icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          "Create Event",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Creating event...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image Upload
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _imageFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 50,
                                      color: Colors.blue[700],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Upload Event Image",
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 25),

                      // Event Name
                      Text(
                        "Event Name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _eventNameController,
                        decoration: InputDecoration(
                          hintText: "Enter event name",
                          fillColor: Colors.grey[100],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter event name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Event Details
                      Text(
                        "Event Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _eventDetailsController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Enter event details",
                          fillColor: Colors.grey[100],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter event details';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Start and End time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Start Time",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectStartTime(context),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.blue[700],
                                          size: 18,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          _startTime != null
                                              ? _formatTimeOfDay(_startTime!)
                                              : "Start Time",
                                          style: TextStyle(
                                            color: _startTime != null
                                                ? Colors.black87
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "End Time",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectEndTime(context),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.blue[700],
                                          size: 18,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          _endTime != null
                                              ? _formatTimeOfDay(_endTime!)
                                              : "End Time",
                                          style: TextStyle(
                                            color: _endTime != null
                                                ? Colors.black87
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Date
                      Text(
                        "Date",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.blue[700],
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text(
                                _eventDate != null
                                    ? _formatDate(_eventDate!)
                                    : "Select Date",
                                style: TextStyle(
                                  color: _eventDate != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Club Name not needed

                      // Location
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Location",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _eventLocationController,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey[100],
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter event location';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Room no",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _roomNoController,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey[100],
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter room no';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // Create Event button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleCreateEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Create Event",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
