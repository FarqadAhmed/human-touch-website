import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VolunteerHelpInfoPage extends StatefulWidget {
  final String volunteerId;

  const VolunteerHelpInfoPage({super.key, required this.volunteerId});

  @override
  State<VolunteerHelpInfoPage> createState() => _VolunteerHelpInfoPageState();
}

class _VolunteerHelpInfoPageState extends State<VolunteerHelpInfoPage> {
  DateTime? _selectedDate;
  DocumentSnapshot<Map<String, dynamic>>? _selectedSlot;

  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 5;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submitBooking() async {
    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a day and time')),
      );
      return;
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    final slotData = _selectedSlot!.data()!;
    final volunteerRef = _firestore
        .collection('volunteers')
        .doc(widget.volunteerId);

    await _firestore.collection('booking_requests').add({
      'volunteerRef': volunteerRef,
      'slotRef': _selectedSlot!.reference,
      'patientUid': currentUser.uid,
      'patientName': currentUser.displayName ?? 'User',
      'requestedDate': Timestamp.fromDate(
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day),
      ),
      'requestedTime': slotData['timeLabel'] ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking request submitted')));
  }

  Future<void> _addReview() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please write a review')));
      return;
    }

    final volunteerRef = _firestore
        .collection('volunteers')
        .doc(widget.volunteerId);

    await _firestore.collection('volunteer_reviews').add({
      'volunteerRef': volunteerRef,
      'userName': currentUser.displayName ?? 'User',
      'userPhoto': currentUser.photoURL ?? '',
      'rating': _selectedRating,
      'comment': _reviewController.text.trim(),
      'createdTime': FieldValue.serverTimestamp(),
    });

    _reviewController.clear();
    _selectedRating = 5;

    if (mounted) {
      setState(() {});
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added successfully')),
      );
    }
  }

  void _openReviewBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Review',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedRating = star;
                          });
                        },
                        icon: Icon(
                          star <= _selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write your review here...',
                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _addReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87CEEB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Review',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final volunteerRef = _firestore
        .collection('volunteers')
        .doc(widget.volunteerId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: volunteerRef.snapshots(),
      builder: (context, volunteerSnapshot) {
        if (volunteerSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!volunteerSnapshot.hasData || !volunteerSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Volunteer not found')),
          );
        }

        final volunteer = volunteerSnapshot.data!.data()!;
        final String name = volunteer['name'] ?? 'No Name';
        final String helpType = volunteer['helpType'] ?? '';
        final String about = volunteer['about'] ?? '';
        final String photoUrl = volunteer['photoUrl'] ?? '';
        final bool isAvailable = volunteer['isAvailable'] ?? false;

        return Scaffold(
          backgroundColor: const Color(0xFF87CEEB),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 70),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3F6),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                              ),
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    'Volunteer Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: Colors.white,
                                  backgroundImage: photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl.isEmpty
                                      ? const Icon(Icons.person, size: 34)
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              helpType,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                          const Text(
                            'About Volunteer',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            about,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Schedules',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _selectedDate == null
                                    ? _monthName(DateTime.now().month)
                                    : _monthName(_selectedDate!.month),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _firestore
                                .collection('volunteer_slots')
                                .where('volunteerRef', isEqualTo: volunteerRef)
                                .where('isActive', isEqualTo: true)
                                .orderBy('slotDate')
                                .snapshots(),
                            builder: (context, slotSnapshot) {
                              if (!slotSnapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final allSlots = slotSnapshot.data!.docs;

                              final Map<String, DateTime> uniqueDays = {};
                              for (final slot in allSlots) {
                                final Timestamp ts = slot['slotDate'];
                                final date = ts.toDate();
                                final key =
                                    '${date.year}-${date.month}-${date.day}';
                                uniqueDays[key] = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                );
                              }

                              final days = uniqueDays.values.toList()
                                ..sort((a, b) => a.compareTo(b));

                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: days.map((day) {
                                  final isSelected =
                                      _selectedDate != null &&
                                      _selectedDate!.year == day.year &&
                                      _selectedDate!.month == day.month &&
                                      _selectedDate!.day == day.day;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = day;
                                        _selectedSlot = null;
                                      });
                                    },
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF87CEEB)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        day.day.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 16),
                          const Text(
                            'Visit Hours',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (_selectedDate == null)
                            const Text(
                              'Select a day first',
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: _firestore
                                  .collection('volunteer_slots')
                                  .where(
                                    'volunteerRef',
                                    isEqualTo: volunteerRef,
                                  )
                                  .where('isActive', isEqualTo: true)
                                  .where('isBooked', isEqualTo: false)
                                  .orderBy('slotDate')
                                  .snapshots(),
                              builder: (context, hourSnapshot) {
                                if (!hourSnapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final slots = hourSnapshot.data!.docs.where((
                                  slot,
                                ) {
                                  final Timestamp ts = slot['slotDate'];
                                  final date = ts.toDate();

                                  return date.year == _selectedDate!.year &&
                                      date.month == _selectedDate!.month &&
                                      date.day == _selectedDate!.day;
                                }).toList();

                                if (slots.isEmpty) {
                                  return const Text(
                                    'No available hours',
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: slots.map((slot) {
                                    final data = slot.data();
                                    final bool isSelected =
                                        _selectedSlot?.id == slot.id;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedSlot = slot;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF87CEEB)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          data['timeLabel'] ?? '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),

                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Reviews',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: _openReviewBottomSheet,
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add review',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _firestore
                                .collection('volunteer_reviews')
                                .where('volunteerRef', isEqualTo: volunteerRef)
                                .orderBy('createdTime', descending: true)
                                .limit(3)
                                .snapshots(),
                            builder: (context, reviewSnapshot) {
                              if (!reviewSnapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final reviews = reviewSnapshot.data!.docs;

                              if (reviews.isEmpty) {
                                return Column(
                                  children: List.generate(
                                    3,
                                    (index) => _buildDummyReviewCard(
                                      userName: index == 0
                                          ? 'Ahmed Abdulla'
                                          : index == 1
                                          ? 'Sara Hasan'
                                          : 'Yousef Ibrahim',
                                      rating: index == 0
                                          ? 4
                                          : index == 1
                                          ? 5
                                          : 3,
                                      comment: index == 0
                                          ? 'Very helpful and kind volunteer.'
                                          : index == 1
                                          ? 'She was supportive and professional.'
                                          : 'Good experience overall.',
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: reviews.map((review) {
                                  final data = review.data();
                                  return _buildReviewCard(
                                    userName: data['userName'] ?? 'User',
                                    userPhoto: data['userPhoto'] ?? '',
                                    rating: (data['rating'] ?? 0) as int,
                                    comment: data['comment'] ?? '',
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _submitBooking,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF87CEEB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewCard({
    required String userName,
    required String userPhoto,
    required int rating,
    required String comment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: userPhoto.isNotEmpty
                ? NetworkImage(userPhoto)
                : null,
            child: userPhoto.isEmpty
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDummyReviewCard({
    required String userName,
    required int rating,
    required String comment,
  }) {
    return _buildReviewCard(
      userName: userName,
      userPhoto: '',
      rating: rating,
      comment: comment,
    );
  }
}
