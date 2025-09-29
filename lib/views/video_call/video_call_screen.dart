import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:videocall/backend/agora/agora_controller.dart';
import 'package:videocall/backend/agora/agora_provider.dart';
import 'package:videocall/utils/my_print.dart';

import '../../utils/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String userName;
  final int uid;

  const VideoCallScreen({
    Key? key,
    required this.channelName,
    required this.userName,
    this.uid = 0,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late AgoraController agoraController;
  late AgoraProvider agoraProvider;
  bool isInitialized = false;
  bool isJoining = true;

  @override
  void initState() {
    super.initState();
    agoraProvider = context.read<AgoraProvider>();
    agoraController = AgoraController(agoraProvider: agoraProvider);
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    // Check permissions first
    final hasPermissions = await PermissionsHelper.requestVideoCallPermissionsWithDialog(context);

    if (!hasPermissions) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera and microphone permissions are required')),
        );
        Navigator.pop(context);
      }
      return;
    }

    agoraProvider = AgoraProvider();
    agoraController = AgoraController(agoraProvider: agoraProvider);

    // Initialize Agora SDK
    bool initialized = await agoraController.initializeAgoraSDK();

    if (initialized) {
      // Start preview
      await agoraController.startPreview();

      // Join channel
      bool joined = await agoraController.joinChannel(
        channelName: widget.channelName,
        uid: widget.uid,
      );

      if (mounted) {
        setState(() {
          isInitialized = joined;
          isJoining = false;
        });
      }

      if (!joined && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join channel')),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          isJoining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize Agora SDK. Please check your App ID.')),
        );
      }
    }
  }

  @override
  void dispose() {
    agoraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AgoraProvider>.value(
      value: agoraProvider,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text('Call - ${widget.channelName}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _showLeaveConfirmation(context),
          ),
        ),
        body: isJoining
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Joining channel...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        )
            : !isInitialized
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize video call',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        )
            : Stack(
          children: [
            // Remote video view (full screen)
            _buildRemoteVideoView(),

            // Local video view (Picture-in-Picture)
            Positioned(
              top: 16,
              right: 16,
              child: _buildLocalVideoView(),
            ),

            // Control buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildControlButtons(),
            ),

            // Call info
            Positioned(
              top: 16,
              left: 16,
              child: _buildCallInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideoView() {
    return Consumer<AgoraProvider>(
      builder: (context, provider, child) {
        final remoteUid = provider.remoteUid.get();

        if (remoteUid == 0) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 80, color: Colors.white54),
                  SizedBox(height: 16),
                  Text(
                    'Waiting for others to join...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        }

        // Render remote video
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: agoraController.engine!,
              canvas: VideoCanvas(uid: remoteUid),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocalVideoView() {
    return Consumer<AgoraProvider>(
      builder: (context, provider, child) {
        final isVideoEnabled = provider.isVideoEnabled.get();

        return Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isVideoEnabled
                ? AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: agoraController.engine!,
                canvas: const VideoCanvas(uid: 0),
              ),
            )
                : const Center(
              child: Icon(
                Icons.videocam_off,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return Consumer<AgoraProvider>(
      builder: (context, provider, child) {
        final isVideoEnabled = provider.isVideoEnabled.get();
        final isAudioMuted = provider.isAudioMuted.get();
        final isScreenSharing = provider.isScreenSharing.get();
        final isSpeakerEnabled = provider.isSpeakerEnabled.get();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute/Unmute button
                  _buildControlButton(
                    icon: isAudioMuted ? Icons.mic_off : Icons.mic,
                    label: isAudioMuted ? 'Unmute' : 'Mute',
                    onPressed: () => agoraController.toggleAudio(),
                    backgroundColor: isAudioMuted ? Colors.red : Colors.white24,
                  ),

                  // Video on/off button
                  _buildControlButton(
                    icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    label: isVideoEnabled ? 'Stop Video' : 'Start Video',
                    onPressed: () => agoraController.toggleVideo(),
                    backgroundColor: !isVideoEnabled ? Colors.red : Colors.white24,
                  ),

                  // Switch camera button
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    label: 'Flip',
                    onPressed: () => agoraController.switchCamera(),
                    backgroundColor: Colors.white24,
                  ),

                  // End call button
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: 'End',
                    onPressed: () => _showLeaveConfirmation(context),
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Speaker button
                  _buildControlButton(
                    icon: isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
                    label: isSpeakerEnabled ? 'Speaker' : 'Earpiece',
                    onPressed: () => agoraController.enableSpeaker(!isSpeakerEnabled),
                    backgroundColor: Colors.white24,
                  ),
                  const SizedBox(width: 16),
                  // Screen share button
                  _buildControlButton(
                    icon: isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                    label: isScreenSharing ? 'Stop Share' : 'Share',
                    onPressed: () async {
                      if (isScreenSharing) {
                        await agoraController.stopScreenShare();
                      } else {
                        await agoraController.startScreenShare();
                      }
                    },
                    backgroundColor: isScreenSharing ? Colors.blue : Colors.white24,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.white24,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(32),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(32),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCallInfo() {
    return Consumer<AgoraProvider>(
      builder: (context, provider, child) {
        final remoteUsers = provider.remoteUsers.get();
        final localUid = provider.localUid.get();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Channel: ${widget.channelName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You: $localUid',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
              if (remoteUsers.isNotEmpty)
                Text(
                  'Participants: ${remoteUsers.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLeaveConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Call'),
        content: const Text('Are you sure you want to leave this call?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await agoraController.leaveChannel();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}