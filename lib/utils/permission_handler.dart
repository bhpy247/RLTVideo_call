import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videocall/utils/my_print.dart';

class PermissionsHelper {
  // Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;

      if (status.isGranted) {
        MyPrint.printOnConsole("Camera permission already granted");
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.camera.request();
        MyPrint.printOnConsole("Camera permission request result: $result");
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        MyPrint.printOnConsole("Camera permission permanently denied");
        return false;
      }

      return false;
    } catch (e, s) {
      MyPrint.printOnConsole("Error requesting camera permission: $e");
      MyPrint.printOnConsole(s);
      return false;
    }
  }

  // Check and request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;

      if (status.isGranted) {
        MyPrint.printOnConsole("Microphone permission already granted");
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.microphone.request();
        MyPrint.printOnConsole("Microphone permission request result: $result");
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        MyPrint.printOnConsole("Microphone permission permanently denied");
        return false;
      }

      return false;
    } catch (e, s) {
      MyPrint.printOnConsole("Error requesting microphone permission: $e");
      MyPrint.printOnConsole(s);
      return false;
    }
  }

  // Request both camera and microphone permissions
  static Future<Map<String, bool>> requestVideoCallPermissions() async {
    final cameraGranted = await requestCameraPermission();
    final microphoneGranted = await requestMicrophonePermission();

    return {
      'camera': cameraGranted,
      'microphone': microphoneGranted,
    };
  }

  // Check if all video call permissions are granted
  static Future<bool> checkVideoCallPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;

    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  // Show permission dialog with custom message
  static Future<bool> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    required Future<bool> Function() requestPermission,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final granted = await requestPermission();
              if (context.mounted) {
                Navigator.pop(context, granted);
              }
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // Show settings dialog when permission is permanently denied
  static Future<void> showSettingsDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Request video call permissions with user-friendly dialogs
  static Future<bool> requestVideoCallPermissionsWithDialog(
      BuildContext context,
      ) async {
    // Check current permissions
    final hasPermissions = await checkVideoCallPermissions();

    if (hasPermissions) {
      return true;
    }

    // Request camera permission
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      if (cameraStatus.isPermanentlyDenied) {
        await showSettingsDialog(
          context: context,
          title: 'Camera Permission Required',
          message: 'Please enable camera permission in settings to use video calling.',
        );
        return false;
      }

      final cameraGranted = await showPermissionDialog(
        context: context,
        title: 'Camera Permission',
        message: 'This app needs camera access to enable video calling.',
        requestPermission: requestCameraPermission,
      );

      if (!cameraGranted) {
        return false;
      }
    }

    // Request microphone permission
    final microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      if (microphoneStatus.isPermanentlyDenied) {
        await showSettingsDialog(
          context: context,
          title: 'Microphone Permission Required',
          message: 'Please enable microphone permission in settings to use video calling.',
        );
        return false;
      }

      final microphoneGranted = await showPermissionDialog(
        context: context,
        title: 'Microphone Permission',
        message: 'This app needs microphone access to enable audio during video calls.',
        requestPermission: requestMicrophonePermission,
      );

      if (!microphoneGranted) {
        return false;
      }
    }

    return await checkVideoCallPermissions();
  }
}