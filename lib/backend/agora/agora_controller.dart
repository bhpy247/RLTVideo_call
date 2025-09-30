import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:videocall/utils/my_print.dart';
import 'agora_provider.dart';

class AgoraController {
  late AgoraProvider _agoraProvider;
  RtcEngine? _engine;

  // TODO: Replace with your Agora App ID from https://console.agora.io/
  static const String appId = "a4f6ec2131214594a35803d040871760";

  AgoraController({AgoraProvider? agoraProvider}) {
    _agoraProvider = agoraProvider ?? AgoraProvider();
  }

  AgoraProvider get agoraProvider => _agoraProvider;
  RtcEngine? get engine => _engine;

  Future<bool> initializeAgoraSDK() async {
    try {
      MyPrint.printOnConsole("Initializing Agora SDK");

      if (appId.isEmpty || appId == "YOUR_AGORA_APP_ID") {
        MyPrint.printOnConsole("ERROR: Please set your Agora App ID");
        return false;
      }

      _engine = createAgoraRtcEngine();

      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      await _engine!.enableVideo();
      await _engine!.enableAudio();

      _setupEventHandlers();

      MyPrint.printOnConsole("Agora SDK initialized successfully");
      return true;
    } catch (e, s) {
      MyPrint.printOnConsole("Error initializing Agora SDK: $e");
      MyPrint.printOnConsole(s);
      return false;
    }
  }

  void _setupEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          MyPrint.printOnConsole("Local user ${connection.localUid} joined channel: ${connection.channelId}");
          _agoraProvider.isInChannel.set(value: true, isNotify: true);
          _agoraProvider.localUid.set(value: connection.localUid ?? 0, isNotify: true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          MyPrint.printOnConsole("Remote user $remoteUid joined");
          _agoraProvider.remoteUid.set(value: remoteUid, isNotify: true);

          List<int> remoteUsers = List.from(_agoraProvider.remoteUsers.get());
          if (!remoteUsers.contains(remoteUid)) {
            remoteUsers.add(remoteUid);
            _agoraProvider.remoteUsers.set(value: remoteUsers, isNotify: true);
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          MyPrint.printOnConsole("Remote user $remoteUid left channel");

          List<int> remoteUsers = List.from(_agoraProvider.remoteUsers.get());
          remoteUsers.remove(remoteUid);
          _agoraProvider.remoteUsers.set(value: remoteUsers, isNotify: true);

          if (_agoraProvider.remoteUid.get() == remoteUid) {
            _agoraProvider.remoteUid.set(value: 0, isNotify: true);
          }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          MyPrint.printOnConsole("Left channel");
          _agoraProvider.isInChannel.set(value: false, isNotify: true);
          _agoraProvider.remoteUid.set(value: 0, isNotify: true);
          _agoraProvider.remoteUsers.set(value: [], isNotify: true);
        },
        onError: (ErrorCodeType err, String msg) {
          MyPrint.printOnConsole("Agora Error: $err - $msg");
        },
      ),
    );
  }

  Future<bool> joinChannel({
    required String channelName,
    String? token,
    int uid = 0,
  }) async {
    try {
      MyPrint.printOnConsole("Joining channel: $channelName");

      _agoraProvider.currentChannelName.set(value: channelName, isNotify: true);

      await _engine!.joinChannel(
        token: "d4ae3f9467c443ecb5442e0676a835d7",
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      MyPrint.printOnConsole("Successfully joined channel");
      return true;
    } catch (e, s) {
      MyPrint.printOnConsole("Error joining channel: $e");
      MyPrint.printOnConsole(s);
      return false;
    }
  }

  Future<void> startPreview() async {
    try {
      await _engine!.startPreview();
      _agoraProvider.isVideoEnabled.set(value: true, isNotify: true);
      MyPrint.printOnConsole("Local video preview started");
    } catch (e, s) {
      MyPrint.printOnConsole("Error starting preview: $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> stopPreview() async {
    try {
      await _engine!.stopPreview();
      _agoraProvider.isVideoEnabled.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Local video preview stopped");
    } catch (e, s) {
      MyPrint.printOnConsole("Error stopping preview: $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> toggleVideo() async {
    try {
      bool isEnabled = _agoraProvider.isVideoEnabled.get();

      if (isEnabled) {
        await _engine!.muteLocalVideoStream(true);
        await stopPreview();
      } else {
        await _engine!.muteLocalVideoStream(false);
        await startPreview();
      }

      MyPrint.printOnConsole("Video toggled: ${!isEnabled}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error toggling video: $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> toggleAudio() async {
    try {
      bool isMuted = _agoraProvider.isAudioMuted.get();

      await _engine!.muteLocalAudioStream(!isMuted);
      _agoraProvider.isAudioMuted.set(value: !isMuted, isNotify: true);

      MyPrint.printOnConsole("Audio ${isMuted ? 'unmuted' : 'muted'}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error toggling audio: $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> switchCamera() async {
    try {
      await _engine!.switchCamera();
      MyPrint.printOnConsole("Camera switched");
    } catch (e, s) {
      MyPrint.printOnConsole("Error switching camera: $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> enableSpeaker(bool enabled) async {
    try {
      await _engine!.setEnableSpeakerphone(enabled);
      _agoraProvider.isSpeakerEnabled.set(value: enabled, isNotify: true);
      MyPrint.printOnConsole("Speaker ${enabled ? 'enabled' : 'disabled'}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error toggling speaker: $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> startScreenShare() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _engine!.startScreenCapture(const ScreenCaptureParameters2(
          captureAudio: true,
          captureVideo: true,
        ));
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _engine!.startScreenCapture(const ScreenCaptureParameters2(
          captureAudio: false,
          captureVideo: true,
        ));
      }

      _agoraProvider.isScreenSharing.set(value: true, isNotify: true);
      MyPrint.printOnConsole("Screen sharing started");
    } catch (e, s) {
      MyPrint.printOnConsole("Error starting screen share: $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> stopScreenShare() async {
    try {
      await _engine!.stopScreenCapture();
      _agoraProvider.isScreenSharing.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Screen sharing stopped");
    } catch (e, s) {
      MyPrint.printOnConsole("Error stopping screen share: $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> leaveChannel() async {
    try {
      await _engine!.leaveChannel();

      _agoraProvider.isInChannel.set(value: false, isNotify: true);
      _agoraProvider.remoteUid.set(value: 0, isNotify: true);
      _agoraProvider.remoteUsers.set(value: [], isNotify: true);
      _agoraProvider.currentChannelName.set(value: "", isNotify: true);

      MyPrint.printOnConsole("Left channel successfully");
    } catch (e, s) {
      MyPrint.printOnConsole("Error leaving channel: $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> dispose() async {
    try {
      await leaveChannel();
      await _engine!.release();
      _engine = null;
      MyPrint.printOnConsole("Agora engine disposed");
    } catch (e, s) {
      MyPrint.printOnConsole("Error disposing Agora engine: $e");
      MyPrint.printOnConsole(s);
    }
  }
}