import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Dashboard_page.dart';
import 'SignUpVolunteer_page.dart';
import 'VolunteerHelpInfo_page.dart';

import 'package:humantouch/pages/app_settings_store.dart';

class VolunteerHelpPage extends StatefulWidget {
  const VolunteerHelpPage({super.key});

  @override
  State<VolunteerHelpPage> createState() => _VolunteerHelpPageState();
}

class _VolunteerHelpPageState extends State<VolunteerHelpPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  String _selectedAvailability = 'All';
  String _selectedHelpType = 'All';

  List<String> _favoriteIds = [];

  final List<String> _availabilityOptions = [
    'All',
    'Available',
    'Busy',
  ];

  final List<String> _helpTypeOptions = [
    'All',
    'Medical',
    'Shopping',
    'Transportation',
    'Daily Support',
    'Other',
  ];

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  String optionText(String value) {
    switch (value) {
      case 'All':
        return tr('All', 'الكل');
      case 'Available':
        return tr('Available', 'متاح');
      case 'Busy':
        return tr('Busy', 'مشغول');
      case 'Medical':
        return tr('Medical', 'طبي');
      case 'Shopping':
        return tr('Shopping', 'تسوق');
      case 'Transportation':
        return tr('Transportation', 'مواصلات');
      case 'Daily Support':
        return tr('Daily Support', 'دعم يومي');
      case 'Other':
        return tr('Other', 'أخرى');
      default:
        return value;
    }
  }

  String availabilityText(bool isAvailable) {
    return isAvailable ? tr('Available', 'متاح') : tr('Busy', 'مشغول');
  }

  @override
  void initState() {
    super.initState();
    AppSettingsStore.instance.addListener(_onLanguageChanged);
    _loadFavoritesFromFirebase();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoritesFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};

    setState(() {
      _favoriteIds = List<String>.from(data['favoriteVolunteers'] ?? []);
    });
  }

  Future<void> _toggleFavorite(String volunteerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      if (_favoriteIds.contains(volunteerId)) {
        _favoriteIds.remove(volunteerId);
      } else {
        _favoriteIds.add(volunteerId);
      }
    });

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'favoriteVolunteers': _favoriteIds,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> _volunteersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'volunteer')
        .snapshots();
  }

  List<Map<String, dynamic>> _filterVolunteers(QuerySnapshot snapshot) {
    final volunteers = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return {
        'id': doc.id,
        'name': data['name'] ?? 'Volunteer',
        'helpType':
            data['helpType'] ?? data['volunteerType'] ?? 'Daily Support',
        'gender': data['gender'] ?? 'Unknown',
        'isAvailable': data['isAvailable'] ?? true,
        'rating': (data['rating'] ?? 0).toDouble(),
        'photoUrl': data['photoUrl'] ?? '',
        'phone': data['phone'] ?? data['phoneNumber'] ?? '',
        'volunteerSpecialty': data['volunteerSpecialty'] ?? '',
        'volunteerSkill': data['volunteerSkill'] ?? '',
        'volunteerBio': data['volunteerBio'] ?? '',
        'volunteerWork': data['volunteerWork'] ?? '',
      };
    }).where((v) {
      final name = v['name'].toString().toLowerCase();
      final helpType = v['helpType'].toString().toLowerCase();
      final isAvailable = v['isAvailable'] == true;

      final matchesSearch = _searchText.isEmpty ||
          name.contains(_searchText) ||
          helpType.contains(_searchText);

      final matchesAvailability = _selectedAvailability == 'All' ||
          (_selectedAvailability == 'Available' && isAvailable) ||
          (_selectedAvailability == 'Busy' && !isAvailable);

      final matchesHelpType = _selectedHelpType == 'All' ||
          helpType == _selectedHelpType.toLowerCase();

      return matchesSearch && matchesAvailability && matchesHelpType;
    }).toList();

    volunteers.sort((a, b) {
      return a['name'].toString().toLowerCase().compareTo(
            b['name'].toString().toLowerCase(),
          );
    });

    return volunteers;
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  optionText(item),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _buildFilterDropdown(
            value: _selectedAvailability,
            items: _availabilityOptions,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedAvailability = value;
              });
            },
          ),
          const SizedBox(width: 10),
          _buildFilterDropdown(
            value: _selectedHelpType,
            items: _helpTypeOptions,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedHelpType = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerCard(Map<String, dynamic> data) {
    final String volunteerId = data['id'].toString();
    final String name = data['name'].toString();
    final String helpType = data['helpType'].toString();
    final String gender = data['gender'].toString();
    final bool isAvailable = data['isAvailable'] == true;
    final double rating = (data['rating'] ?? 0).toDouble();
    final String photoUrl = data['photoUrl'].toString();

    final bool isFavorite = _favoriteIds.contains(volunteerId);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VolunteerHelpInfoPage(volunteer: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFC5E7F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 34, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF025590),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        optionText(helpType),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gender,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: isArabic
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(rating.toStringAsFixed(1)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _toggleFavorite(volunteerId),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.12)
                        : Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    availabilityText(isAvailable),
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isArabic ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF87CEEB),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpVolunteerPage(),
              ),
            );
          },
          child: const Icon(Icons.person_add, color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 130,
                    width: double.infinity,
                    color: const Color(0xFF87CEEB),
                  ),
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: Icon(
                        isArabic ? Icons.arrow_forward : Icons.arrow_back,
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          tr('Volunteer Help', 'مساعدة المتطوعين'),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: tr('Search volunteer', 'ابحث عن متطوع'),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              _buildFiltersRow(),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _volunteersStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF87CEEB),
                        ),
                      );
                    }

                    final volunteers = _filterVolunteers(snapshot.data!);

                    if (volunteers.isEmpty) {
                      return Center(
                        child: Text(
                          tr('No volunteers found', 'لا يوجد متطوعون'),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: volunteers.length,
                      itemBuilder: (context, index) {
                        return _buildVolunteerCard(volunteers[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
