import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'VolunteerHelpChat.dart';
import 'call_engine_service.dart';

class VolunteerHelpCallPage extends StatefulWidget {
  final String volunteerId;
  final String volunteerName;
  final String? callId;
  final bool isIncoming;

  const VolunteerHelpCallPage({
    super.key,
    required this.volunteerId,
    required this.volunteerName,
    this.callId,
    this.isIncoming = false,
  });

  @override
  State<VolunteerHelpCallPage> createState() => _VolunteerHelpCallPageState();
}

class _VolunteerHelpCallPageState extends State<VolunteerHelpCallPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _timeoutTimer;
  Timer? _ringingTimer;

  bool _isCreatingCall = false;

  String get _currentStatus => CallEngineService.instance.callStatus;

  @override
  void initState() {
    super.initState();

    if (widget.callId != null && widget.callId!.isNotEmpty) {
      CallEngineService.instance.listenToCall(widget.callId!);
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _ringingTimer?.cancel();
    super.dispose();
  }

  Future<String?> _createCallIfNeeded() async {
    if (CallEngineService.instance.activeCallId != null) {
      return CallEngineService.instance.activeCallId;
    }

    if (_isCreatingCall) {
      return CallEngineService.instance.activeCallId;
    }

    _isCreatingCall = true;

    final callId = await CallEngineService.instance.createCall(
      receiverId: widget.volunteerId,
      receiverName: widget.volunteerName,
    );

    _isCreatingCall = false;

    return callId;
  }

  void _startRingingTimer() {
    _ringingTimer?.cancel();

    _ringingTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      if (CallEngineService.instance.callStatus == 'calling') {
        await CallEngineService.instance.updateStatus('ringing');
      }
    });
  }

  void _startTimeoutWatcher() {
    _timeoutTimer?.cancel();

    _timeoutTimer = Timer(const Duration(seconds: 25), () async {
      if (!mounted) return;

      final status = CallEngineService.instance.callStatus;

      if (status == 'calling' || status == 'ringing') {
        await CallEngineService.instance.updateStatus('missed');
      }
    });
  }

  Future<void> _startCall() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final callId = await _createCallIfNeeded();
    if (callId == null) return;

    await CallEngineService.instance.updateStatus('calling');

    _startRingingTimer();
    _startTimeoutWatcher();
  }

  Future<void> _acceptCall() async {
    final callId = CallEngineService.instance.activeCallId ?? widget.callId;
    if (callId == null || callId.isEmpty) return;

    await CallEngineService.instance.acceptCall(callId);
  }

  Future<void> _endCall() async {
    await CallEngineService.instance.endCall();
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VolunteerHelpChatPage(
          volunteerId: widget.volunteerId,
          volunteerName: widget.volunteerName,
        ),
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'calling':
        return 'Calling...';
      case 'ringing':
        return 'Ringing...';
      case 'accepted':
        return 'Connected';
      case 'rejected':
        return 'Rejected';
      case 'missed':
        return 'Missed Call';
      case 'ended':
        return 'Call Ended';
      case 'failed':
        return 'Failed';
      default:
        return 'Ready';
    }
  }

  bool _showLoading(String status) {
    return status == 'calling' || status == 'ringing';
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Login required')),
      );
    }

    final callID = CallEngineService.instance.activeCallId ??
        widget.callId ??
        'temp_${user.uid}_${widget.volunteerId}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StreamBuilder<String>(
            stream: CallEngineService.instance.statusStream,
            initialData: CallEngineService.instance.callStatus,
            builder: (context, snapshot) {
              final status = snapshot.data ?? 'idle';

              return Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          if (status == 'calling' ||
                              status == 'ringing' ||
                              status == 'accepted') {
                            await _endCall();
                          }

                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.volunteerName.isNotEmpty
                          ? widget.volunteerName[0].toUpperCase()
                          : 'V',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF025590),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.volunteerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _statusText(status),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  if (_showLoading(status))
                    const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _openChat,
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat'),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _startCall,
                          child: const Text('Call'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _acceptCall,
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _endCall,
                          child: const Text('End'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ZegoSendCallInvitationButton(
                    isVideoCall: true,
                    resourceID: 'zegouikit_call',
                    callID: callID,
                    invitees: [
                      ZegoUIKitUser(
                        id: widget.volunteerId,
                        name: widget.volunteerName,
                      ),
                    ],
                    onPressed: (code, message, _) async {
                      if (code.isEmpty) {
                        await _startCall();
                      } else {
                        await _createCallIfNeeded();
                        await CallEngineService.instance.updateStatus('failed');
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
