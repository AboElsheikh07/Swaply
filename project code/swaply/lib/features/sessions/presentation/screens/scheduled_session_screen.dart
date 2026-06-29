import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ScheduledCallPage extends StatelessWidget {
  final String callID;
  final String currentUserId;
  final String currentUserName;

  const ScheduledCallPage({
    super.key,
    required this.callID,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 925971338,
        appSign:
            '8e38c24f69d7fad8dc2050dc484e3b24331eb49de8ea9789b6f73f5d3eb8a08d',
        userID: currentUserId,
        userName: currentUserName,
        callID: callID,

        // 1. Move your hangup/exit logic into the separate events parameter
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
            // This triggers when the user clicks the red hangup button or exits
            // defaultAction.call() automatically handles returning to your previous page safely
            defaultAction.call();
          },
        ),

        // 2. Keep the configuration purely for structural UI customization
        config: ZegoUIKitPrebuiltCallConfig.groupVideoCall()
          ..topMenuBar.isVisible = true
          ..topMenuBar.buttons = [
            ZegoCallMenuBarButtonName.switchCameraButton,
            ZegoCallMenuBarButtonName.toggleCameraButton,
            ZegoCallMenuBarButtonName.toggleMicrophoneButton,
          ],
      ),
    );
  }
}
