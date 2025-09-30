import 'package:videocall/backend/common/common_provider.dart';

class AgoraProvider extends CommonProvider {
  AgoraProvider() {
    isInChannel = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    isVideoEnabled = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );

    isAudioMuted = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    isScreenSharing = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    isSpeakerEnabled = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );

    currentChannelName = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );

    localUid = CommonProviderPrimitiveParameter<int>(
      value: 0,
      notify: notify,
    );

    remoteUid = CommonProviderPrimitiveParameter<int>(
      value: 0,
      notify: notify,
    );

    remoteUsers = CommonProviderPrimitiveParameter<List<int>>(
      value: [],
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<bool> isInChannel;
  late CommonProviderPrimitiveParameter<bool> isVideoEnabled;
  late CommonProviderPrimitiveParameter<bool> isAudioMuted;
  late CommonProviderPrimitiveParameter<bool> isScreenSharing;
  late CommonProviderPrimitiveParameter<bool> isSpeakerEnabled;
  late CommonProviderPrimitiveParameter<String> currentChannelName;
  late CommonProviderPrimitiveParameter<int> localUid;
  late CommonProviderPrimitiveParameter<int> remoteUid;
  late CommonProviderPrimitiveParameter<List<int>> remoteUsers;

  void resetData({bool isNotify = true}) {
    isInChannel.set(value: false, isNotify: false);
    isVideoEnabled.set(value: true, isNotify: false);
    isAudioMuted.set(value: false, isNotify: false);
    isScreenSharing.set(value: false, isNotify: false);
    isSpeakerEnabled.set(value: true, isNotify: false);
    currentChannelName.set(value: "", isNotify: false);
    localUid.set(value: 0, isNotify: false);
    remoteUid.set(value: 1, isNotify: false);
    remoteUsers.set(value: [], isNotify: isNotify);
  }
}