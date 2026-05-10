import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'VolunteerHelpCall.dart';
import 'call_engine_service.dart';
import 'app_settings_store.dart';

class IncomingCallPage extends StatefulWidget {
  final String callId;
  final String callerId;
  final String callerName;
  final String volunteerId;
  final String? photoUrl;

  const IncomingCallPage({
    super.key,
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.volunteerId,
    this.photoUrl,
  });

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage> {
  bool _handled = false;

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) {
    return isArabic ? ar : en;
  }

  @override
  void initState() {
    super.initState();

    AppSettingsStore.instance.addListener(_languageListener);

    CallEngineService.instance.listenToCall(widget.callId);
    CallEngineService.instance.updateStatus('ringing');

    _listenToCallChanges();
    _autoMissed();
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_languageListener);
    super.dispose();
  }

  void _languageListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _listenToCallChanges() {
    CallEngineService.instance.listenToCall(widget.callId);

    CallEngineService.instance.statusStream.listen((status) {
      if (!mounted || _handled) return;

      if (status == 'ended' ||
          status == 'missed' ||
          status == 'rejected' ||
          status == 'failed') {
        _handled = true;
        Navigator.pop(context);
      }
    });
  }

  void _accept(BuildContext context) async {
    if (_handled) return;
    _handled = true;

    await CallEngineService.instance.acceptCall(widget.callId);

    if (!mounted) return;

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VolunteerHelpCallPage(
          callId: widget.callId,
          volunteerId:
              widget.callerId.isNotEmpty ? widget.callerId : widget.volunteerId,
          volunteerName: widget.callerName,
          isIncoming: true,
        ),
      ),
    );
  }

  void _reject(BuildContext context) async {
    if (_handled) return;
    _handled = true;

    await CallEngineService.instance.rejectCall(widget.callId);

    if (!mounted) return;

    Navigator.pop(context);
  }

  void _autoMissed() async {
    await Future.delayed(const Duration(seconds: 25));

    if (!_handled) {
      _handled = true;

      await CallEngineService.instance.markMissed(widget.callId);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.photoUrl != null && widget.photoUrl!.isNotEmpty;

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage:
                    hasPhoto ? NetworkImage(widget.photoUrl!) : null,
                child: !hasPhoto
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                widget.callerName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tr("Incoming Call...", "مكالمة واردة..."),
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "reject",
                    backgroundColor: Colors.red,
                    onPressed: () => _reject(context),
                    child: const Icon(Icons.call_end),
                  ),
                  FloatingActionButton(
                    heroTag: "accept",
                    backgroundColor: Colors.green,
                    onPressed: () => _accept(context),
                    child: const Icon(Icons.call),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
