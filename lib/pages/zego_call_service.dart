// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// import 'zego_config.dart';

// class ZegoCallService {
//   static final ZegoCallService instance = ZegoCallService._internal();
//   ZegoCallService._internal();

//   bool _initialized = false;

//   String? currentUserID;

//   Future<void> init({
//     required BuildContext context,
//     required String userID,
//     required String userName,
//   }) async {
//     if (_initialized) return;

//     currentUserID = userID;

//     await ZegoUIKitPrebuiltCallInvitationService().init(
//       appID: ZegoConfig.appID,
//       appSign: ZegoConfig.appSign,
//       userID: userID,
//       userName: userName,
//       plugins: [ZegoUIKitSignalingPlugin()],
//       requireConfig: (ZegoCallInvitationData data) {
//         final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

//         config.turnOnCameraWhenJoining = false;
//         config.turnOnMicrophoneWhenJoining = true;
//         config.useSpeakerWhenJoining = true;

//         return config;
//       },
//       config: ZegoCallInvitationConfig(
//         permissions: [ZegoCallInvitationPermission.microphone],
//       ),
//     );

//     _initialized = true;
//   }

//   Future<void> uninit() async {
//     await ZegoUIKitPrebuiltCallInvitationService().uninit();
//     _initialized = false;
//   }
// }
