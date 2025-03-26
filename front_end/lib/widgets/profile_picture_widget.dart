import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_finder/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../services/profile_picture_service.dart';

class ProfilePictureWidget extends StatefulWidget {
  final double size;
  final VoidCallback? onChanged;

  const ProfilePictureWidget({
    super.key,
    this.size = 120.0,
    this.onChanged,
  });

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  File? _profilePicture;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final profilePic = await ProfilePictureService.getProfilePicture();
    if (mounted) {
      setState(() {
        _profilePicture = profilePic;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    final currTime = DateTime.now().toString();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final image =
                      await ProfilePictureService.pickImageFromGallery(
                          currTime);
                  if (image != null && mounted) {
                    setState(() {
                      _profilePicture = image;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!();
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await ProfilePictureService.takePhoto(currTime);
                  if (image != null && mounted) {
                    setState(() {
                      _profilePicture = image;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!();
                    }
                  }
                },
              ),
              if (_profilePicture != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo',
                      style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ProfilePictureService.removeProfilePicture();
                    if (mounted) {
                      setState(() {
                        _profilePicture = null;
                      });
                      if (widget.onChanged != null) {
                        widget.onChanged!();
                      }
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Profile picture
        GestureDetector(
          onLongPress: () => _showImageSourceActionSheet(context),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _profilePicture != null
                  ? Image.file(
                      _profilePicture!,
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/profile_pics/profile-pic.jpg',
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),

        // Edit button
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => _showImageSourceActionSheet(context),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
