// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:humantouch/pages/zego_call_service.dart';
// //import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// import 'VolunteerHelpChat.dart';

// class VolunteerHelpCallPage extends StatefulWidget {
//   final String volunteerId;

//   const VolunteerHelpCallPage({super.key, required this.volunteerId});

//   @override
//   State<VolunteerHelpCallPage> createState() => _VolunteerHelpCallPageState();
// }

// class _VolunteerHelpCallPageState extends State<VolunteerHelpCallPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   bool _invitationSent = false;
//   bool _isMutedUi = false;
//   bool _isSpeakerUi = true;
//   bool _isVideoUi = false;

//   String _buildCallID(String myId, String volunteerId) {
//     final ids = [myId, volunteerId]..sort();
//     return 'call_${ids[0]}_${ids[1]}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = ZegoCallService.instance.currentUserID;

//     if (currentUser == null || currentUser.isEmpty) {
//       return const Scaffold(
//       body: Center(child: Text('Call SDK is not initialized')),
//     );
//   }

//     return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//       stream: _firestore
//           .collection('volunteers')
//           .doc(widget.volunteerId)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return const Scaffold(
//             body: Center(child: Text('Volunteer not found')),
//           );
//         }

//         final volunteer = snapshot.data!.data()!;
//         final volunteerName = volunteer['name'] ?? 'Volunteer';
//         final volunteerPhoto = volunteer['photoUrl'] ?? '';
//         final isAvailable = volunteer['isAvailable'] ?? true;
//         final callID = _buildCallID(currentUser, widget.volunteerId);

//         return Scaffold(
//           backgroundColor: Colors.black,
//           body: Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 fit: BoxFit.cover,
//                 image: volunteerPhoto.toString().isNotEmpty
//                     ? NetworkImage(volunteerPhoto)
//                     : const AssetImage('assets/images/placeholder_person.png')
//                           as ImageProvider,
//                 colorFilter: ColorFilter.mode(
//                   Colors.black.withOpacity(0.45),
//                   BlendMode.darken,
//                 ),
//               ),
//             ),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 14),

//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           onPressed: () => Navigator.pop(context),
//                           icon: const Icon(
//                             Icons.arrow_back,
//                             color: Colors.white,
//                           ),
//                         ),
//                         Expanded(
//                           child: Column(
//                             children: [
//                               Text(
//                                 volunteerName,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 isAvailable
//                                     ? (_invitationSent
//                                           ? 'Calling...'
//                                           : 'Ready to call')
//                                     : 'Busy',
//                                 style: TextStyle(
//                                   color: isAvailable
//                                       ? Colors.greenAccent
//                                       : Colors.redAccent,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.92),
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: const Text(
//                             'Voice Call',
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const Spacer(),

//                   Padding(
//                     padding: const EdgeInsets.only(right: 24),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF87CEEB),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 10,
//                           ),
//                           child: const Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.person_add_alt,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                               SizedBox(width: 4),
//                               Text(
//                                 'Voice Call',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Container(
//                             width: 100,
//                             height: 143,
//                             color: Colors.white12,
//                             child: volunteerPhoto.toString().isNotEmpty
//                                 ? Image.network(
//                                     volunteerPhoto,
//                                     fit: BoxFit.cover,
//                                   )
//                                 : const Icon(
//                                     Icons.person,
//                                     color: Colors.white,
//                                     size: 50,
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 28),

//                   Stack(
//                     alignment: Alignment.topCenter,
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         height: 90,
//                         margin: const EdgeInsets.only(top: 27),
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               blurRadius: 30,
//                               color: Colors.black.withOpacity(0.15),
//                               offset: const Offset(0, -4),
//                             ),
//                           ],
//                           borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(24),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Center(
//                                 child: _roundButton(
//                                   icon: _isMutedUi
//                                       ? Icons.mic_off
//                                       : FontAwesomeIcons.microphone,
//                                   active: _isMutedUi,
//                                   onTap: () {
//                                     setState(() {
//                                       _isMutedUi = !_isMutedUi;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Center(
//                                 child: _roundButton(
//                                   icon: _isVideoUi
//                                       ? FontAwesomeIcons.video
//                                       : FontAwesomeIcons.videoSlash,
//                                   active: _isVideoUi,
//                                   onTap: () {
//                                     setState(() {
//                                       _isVideoUi = !_isVideoUi;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                             const Expanded(child: SizedBox()),
//                             Expanded(
//                               child: Center(
//                                 child: _roundButton(
//                                   icon: _isSpeakerUi
//                                       ? FontAwesomeIcons.volumeHigh
//                                       : FontAwesomeIcons.volumeLow,
//                                   active: _isSpeakerUi,
//                                   onTap: () {
//                                     setState(() {
//                                       _isSpeakerUi = !_isSpeakerUi;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Center(
//                                 child: _roundButton(
//                                   icon: Icons.message_outlined,
//                                   active: false,
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             VolunteerHelpChatPage(
//                                               volunteerId: widget.volunteerId,
//                                             ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       ZegoSendCallInvitationButton(
//                         isVideoCall: false,
//                         resourceID: 'zegouikit_call',
//                         invitees: [
//                           ZegoUIKitUser(
//                             id: widget.volunteerId,
//                             name: volunteerName,
//                           ),
//                         ],
//                         iconSize: const Size(60, 60),
//                         buttonSize: const Size(60, 60),
//                         onPressed: (code, message, errorInvitees) {
//                           setState(() {
//                             _invitationSent = code.isEmpty;
//                           });

//                           if (code.isNotEmpty && mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Call failed: $message')),
//                             );
//                           }
//                         },
//                         callID: callID,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _roundButton({
//     required IconData icon,
//     required bool active,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 56,
//         height: 56,
//         decoration: BoxDecoration(
//           color: active ? const Color(0xFF87CEEB) : Colors.white,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           icon,
//           color: active ? Colors.white : const Color(0xFF2E5B75),
//           size: 24,
//         ),
//       ),
//     );
//   }
// }
