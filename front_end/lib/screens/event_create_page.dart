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
  final _priceController = TextEditingController();

  // Event toggles and options
  bool _isFreeEvent = true;
  bool _isMandatoryEvent = false;
  bool _isOnlineEvent = false;

  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _mounted = true;

  // Stepper control
  int _currentStep = 0;
  final int _totalSteps = 3;

  final List<String> _stepTitles = ['Basic Info', 'Details', 'Time & Location'];

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
    _priceController.dispose();
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

  // Navigate to the next step
  void _nextStep() {
    bool canProgress = false;

    // Validate current step before proceeding
    if (_currentStep == 0) {
      canProgress = _eventNameController.text.isNotEmpty && _imageFile != null;
    } else if (_currentStep == 1) {
      canProgress = _eventDetailsController.text.isNotEmpty;

      // Check price if it's not a free event
      if (!_isFreeEvent) {
        canProgress = canProgress &&
            _priceController.text.isNotEmpty &&
            double.tryParse(_priceController.text) != null;
      }
    } else if (_currentStep == 2) {
      canProgress =
          _eventDate != null && _startTime != null && _endTime != null;

      // For online events, we don't need location
      // For in-person events, we need location
      if (!_isOnlineEvent) {
        canProgress = canProgress && _eventLocationController.text.isNotEmpty;
        // Room number is optional
      }
    }

    if (canProgress) {
      setState(() {
        if (_currentStep < _totalSteps - 1) {
          _currentStep++;
        }
      });
    } else {
      // Show error message based on step
      String errorMessage = '';
      if (_currentStep == 0) {
        if (_eventNameController.text.isEmpty) {
          errorMessage = 'Please enter an event name';
        } else if (_imageFile == null) {
          errorMessage = 'Please upload an event image';
        }
      } else if (_currentStep == 1) {
        if (_eventDetailsController.text.isEmpty) {
          errorMessage = 'Please enter event details';
        } else if (!_isFreeEvent && _priceController.text.isEmpty) {
          errorMessage = 'Please enter a price for the event';
        } else if (!_isFreeEvent &&
            double.tryParse(_priceController.text) == null) {
          errorMessage = 'Please enter a valid price';
        }
      } else if (_currentStep == 2) {
        if (_eventDate == null) {
          errorMessage = 'Please select a date';
        } else if (_startTime == null || _endTime == null) {
          errorMessage = 'Please select both start and end time';
        } else if (!_isOnlineEvent && _eventLocationController.text.isEmpty) {
          errorMessage = 'Please enter a location';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar(
          text: errorMessage,
          color: Colors.red,
        ).build(),
      );
    }
  }

  // Go back to the previous step
  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  Future<void> _handleCreateEvent() async {
    if (_formKey.currentState!.validate()) {
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
        // Prepare price
        double? price = 0;
        if (!_isFreeEvent) {
          price = double.tryParse(_priceController.text);
        }

        // Call API to create event
        Map<String, dynamic> result = await _eventsService.createEvent(
          name: _eventNameController.text,
          details: _eventDetailsController.text,
          location: _isOnlineEvent ? "Online" : _eventLocationController.text,
          roomNo: _isOnlineEvent ? "N/A" : _roomNoController.text,
          eventDate: _eventDate!,
          startTime: _formatTimeOfDay(_startTime!),
          endTime: _formatTimeOfDay(_endTime!),
          imageFile: _imageFile,
          context: context,
          isFree: _isFreeEvent,
          isMandatory: _isMandatoryEvent,
          isOnline: _isOnlineEvent,
          price: price!,
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
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar(
              text: 'Event created successfully!',
              color: Colors.green,
            ).build(),
          );

          // Navigate back safely
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

  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          bool isCompleted = _currentStep > index;
          bool isActive = _currentStep == index;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Line on the left side of the circle
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: isCompleted || isActive
                              ? Colors.blue[700]
                              : Colors.grey[300],
                        ),
                      ),

                    // Circle indicator
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.blue[700]
                            : isActive
                                ? Colors.white
                                : Colors.grey[100],
                        border: Border.all(
                          color: isCompleted || isActive
                              ? Colors.blue[700]!
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.blue[700]
                                      : Colors.grey[500],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    // Line on the right side of the circle
                    if (index < _totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          color:
                              isCompleted ? Colors.blue[700] : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Step title
                Text(
                  _stepTitles[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive || isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isActive || isCompleted
                        ? Colors.blue[800]
                        : Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  CircularProgressIndicator(color: Colors.blue[700]),
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
          : Column(
              children: [
                // Horizontal stepper indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildStepIndicator(),
                ),

                // Form content area
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: _buildCurrentStep(),
                      ),
                    ),
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: Offset(0, -2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                              side: BorderSide(color: Colors.blue[700]!),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text("Previous"),
                          ),
                        ),
                      if (_currentStep > 0) SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentStep < _totalSteps - 1
                              ? _nextStep
                              : _handleCreateEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _currentStep < _totalSteps - 1
                                ? "Next"
                                : "Create Event",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildTimeLocationStep();
      default:
        return Container();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Event Image",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Event Image Upload
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 220,
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
                      SizedBox(height: 8),
                      Text(
                        "Tap to select from gallery",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: 24),

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
            prefixIcon: Icon(Icons.event, color: Colors.blue[700]),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter event name';
            }
            return null;
          },
        ),

        SizedBox(height: 16),

        // Club Name
        Text(
          "Club Name (Optional)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _clubNameController,
          decoration: InputDecoration(
            hintText: "Enter organizing club name",
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
            prefixIcon: Icon(Icons.people, color: Colors.blue[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Event Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _eventDetailsController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: "Describe your event: purpose, agenda, highlights...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter event details';
              }
              return null;
            },
          ),
        ),

        SizedBox(height: 24),

        // Event Options Section
        Text(
          "Event Options",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),

        // Free Event Toggle
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: Text(
              'Free Event',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text('Toggle off to set a price for this event'),
            value: _isFreeEvent,
            activeColor: Colors.blue[700],
            onChanged: (value) {
              setState(() {
                _isFreeEvent = value;
              });
            },
          ),
        ),

        // Price Field (show only if not free)
        if (!_isFreeEvent) ...[
          SizedBox(height: 16),
          Text(
            "Price (₹)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              hintText: "Enter price in rupees",
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
              prefixIcon: Icon(Icons.currency_rupee, color: Colors.blue[700]),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (!_isFreeEvent) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
              }
              return null;
            },
          ),
        ],

        SizedBox(height: 16),

        // Mandatory Event Toggle
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: Text(
              'Mandatory Event',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text('Mark if attendance is compulsory'),
            value: _isMandatoryEvent,
            activeColor: Colors.blue[700],
            onChanged: (value) {
              setState(() {
                _isMandatoryEvent = value;
              });
            },
          ),
        ),

        SizedBox(height: 16),

        // Online Event Toggle
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: Text(
              'Online Event',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text('Toggle on if this is a virtual event'),
            value: _isOnlineEvent,
            activeColor: Colors.blue[700],
            onChanged: (value) {
              setState(() {
                _isOnlineEvent = value;
              });
            },
          ),
        ),

        SizedBox(height: 20),

        // Pro Tips
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.blue[700], size: 24),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pro Tips",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "• Include key information like who should attend\n• Mention what participants should bring\n• Include contact details for queries",
                      style: TextStyle(
                        color: Colors.blue[800],
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

  Widget _buildTimeLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  _eventDate != null ? _formatDate(_eventDate!) : "Select Date",
                  style: TextStyle(
                    color:
                        _eventDate != null ? Colors.black87 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
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

        // If online event, don't show physical location
        if (!_isOnlineEvent) ...[
          SizedBox(height: 20),

          // Location Label with tooltip
          Row(
            children: [
              Text(
                "Location",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 5),
              Tooltip(
                message:
                    "Enter the building or area where the event will take place",
                child: Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _eventLocationController,
            decoration: InputDecoration(
              hintText: "Enter location (e.g., AB1)",
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
              prefixIcon: Icon(Icons.location_on, color: Colors.blue[700]),
            ),
            validator: (value) {
              if (!_isOnlineEvent && (value == null || value.trim().isEmpty)) {
                return 'Please enter event location';
              }
              return null;
            },
          ),

          SizedBox(height: 20),

          // Room number (optional)
          Row(
            children: [
              Text(
                "Room Number (Optional)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 5),
              Tooltip(
                message: "Specify a room number if applicable",
                child: Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _roomNoController,
            decoration: InputDecoration(
              hintText: "Enter room number if applicable",
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
              prefixIcon: Icon(Icons.meeting_room, color: Colors.blue[700]),
            ),
            // No validator as this field is optional
          ),
        ] else ...[
          // Online event message
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.videocam, color: Colors.green[700]),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Online Event",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Make sure to include meeting link and access details in the event description",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
