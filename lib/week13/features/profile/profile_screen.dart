import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/avatar.jpg';
    await File(picked.path).copy(path);
    await FileImage(File(path)).evict();
    if (!mounted) return;
    await context.read<SettingsModel>().setAvatar(path);
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted ||
          PermissionStatus.limited ||
          PermissionStatus.provisional:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Without the camera you can still choose a photo from the gallery',
            ),
          ),
        );
      case PermissionStatus.permanentlyDenied || PermissionStatus.restricted:
        await _showSettingsDialog();
    }
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera is off'),
        content: const Text(
          'You turned off camera access for this app. '
          'To take a profile photo, allow the camera in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open ?? false) await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<SettingsModel>().avatarPath;
    final file = path == null ? null : File(path);
    final hasPhoto = file != null && file.existsSync();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: hasPhoto ? FileImage(file) : null,
              child: hasPhoto
                  ? null
                  : const Text('M', style: TextStyle(fontSize: 48)),
            ),
            FilledButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
