import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_page.dart';
import 'SignUpVolunteer_page.dart';

class VolunteerHelpPage extends StatefulWidget {
  const VolunteerHelpPage({super.key});

  @override
  State<VolunteerHelpPage> createState() => _VolunteerHelpPageState();
}

class _VolunteerHelpPageState extends State<VolunteerHelpPage> {
  final TextEditingController _searchController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchText = '';
  String _selectedSort = 'A-Z';
  String _selectedGender = 'All';
  String _selectedStatus = 'All';
  String _selectedHelpType = 'All';

  List<String> _favoriteIds = [];

  final List<String> _helpTypes = [
    'All',
    'Emergency',
    'Delivery',
    'Medical Assistance',
    'Daily Support',
    'Shopping Assistance',
    'Companion',
    'Technical Support',
    'Order Pickup',
    'Transportation',
  ];

  final List<String> _genders = ['All', 'Male', 'Female'];

  final List<String> _statuses = ['All', 'Available', 'Busy'];

  final List<String> _sortOptions = ['A-Z', 'Z-A'];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteIds = prefs.getStringList('favorite_volunteers') ?? [];
    });
  }

  Future<void> _toggleFavorite(String volunteerId) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_favoriteIds.contains(volunteerId)) {
        _favoriteIds.remove(volunteerId);
      } else {
        _favoriteIds.add(volunteerId);
      }
    });

    await prefs.setStringList('favorite_volunteers', _favoriteIds);
  }

  Future<void> _rateVolunteer({
    required String volunteerId,
    required double rating,
  }) async {
    try {
      final volunteerRef = _firestore.collection('volunteers').doc(volunteerId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(volunteerRef);

        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>;

        final double currentRating = (data['rating'] ?? 0).toDouble();
        final int ratingCount = (data['ratingCount'] ?? 0) as int;

        final double newAverage =
            ((currentRating * ratingCount) + rating) / (ratingCount + 1);

        transaction.update(volunteerRef, {
          'rating': double.parse(newAverage.toStringAsFixed(1)),
          'ratingCount': ratingCount + 1,
        });
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit rating: $e')));
    }
  }

  void _openFilterSheet() {
    String tempSort = _selectedSort;
    String tempGender = _selectedGender;
    String tempStatus = _selectedStatus;
    String tempHelpType = _selectedHelpType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Filter Volunteers',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Sort',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tempSort,
                      items: _sortOptions
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempSort = value!;
                        });
                      },
                      decoration: _dropdownDecoration(),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tempGender,
                      items: _genders
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempGender = value!;
                        });
                      },
                      decoration: _dropdownDecoration(),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tempStatus,
                      items: _statuses
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempStatus = value!;
                        });
                      },
                      decoration: _dropdownDecoration(),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Type of Assistance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tempHelpType,
                      items: _helpTypes
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempHelpType = value!;
                        });
                      },
                      decoration: _dropdownDecoration(),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSort = 'A-Z';
                                _selectedGender = 'All';
                                _selectedStatus = 'All';
                                _selectedHelpType = 'All';
                              });
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSort = tempSort;
                                _selectedGender = tempGender;
                                _selectedStatus = tempStatus;
                                _selectedHelpType = tempHelpType;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF87CEEB),
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF4F4F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered = docs.where((
      doc,
    ) {
      final data = doc.data();

      final String name = (data['name'] ?? '').toString().toLowerCase();
      final String helpType = (data['helpType'] ?? '').toString();
      final String gender = (data['gender'] ?? '').toString();
      final bool isAvailable = (data['isAvailable'] ?? false) as bool;

      final bool matchesSearch =
          _searchText.isEmpty || name.contains(_searchText);

      final bool matchesGender =
          _selectedGender == 'All' || gender == _selectedGender;

      final bool matchesHelpType =
          _selectedHelpType == 'All' || helpType == _selectedHelpType;

      final bool matchesStatus =
          _selectedStatus == 'All' ||
          (_selectedStatus == 'Available' && isAvailable) ||
          (_selectedStatus == 'Busy' && !isAvailable);

      return matchesSearch && matchesGender && matchesHelpType && matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      final nameA = (a.data()['name'] ?? '').toString().toLowerCase();
      final nameB = (b.data()['name'] ?? '').toString().toLowerCase();

      if (_selectedSort == 'A-Z') {
        return nameA.compareTo(nameB);
      } else {
        return nameB.compareTo(nameA);
      }
    });

    return filtered;
  }

  Widget _buildStarRow(String volunteerId, double currentRating) {
    return Row(
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return InkWell(
          onTap: () => _rateVolunteer(
            volunteerId: volunteerId,
            rating: starNumber.toDouble(),
          ),
          child: Icon(
            starNumber <= currentRating.round()
                ? Icons.star
                : Icons.star_border,
            size: 18,
            color: const Color(0xFFFFC107),
          ),
        );
      }),
    );
  }

  Widget _buildVolunteerCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final String volunteerId = doc.id;
    final String name = (data['name'] ?? 'Unknown').toString();
    final String helpType = (data['helpType'] ?? 'No help type').toString();
    final String gender = (data['gender'] ?? 'Unknown').toString();
    final bool isAvailable = (data['isAvailable'] ?? false) as bool;
    final double rating = (data['rating'] ?? 0).toDouble();
    final String? photoUrl = data['photoUrl']?.toString();

    final bool isFavorite = _favoriteIds.contains(volunteerId);

    return Container(
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
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? const Icon(Icons.person, size: 34, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF025590),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      helpType,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gender,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
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
                                color: Color(0xFFFFC107),
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _toggleFavorite(volunteerId),
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
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
                  isAvailable ? 'Available' : 'Busy',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              _buildStarRow(volunteerId, rating),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 28),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Volunteer Help',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.filter_list_rounded, size: 28),
                    ),
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
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        onPressed: _openFilterSheet,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                      hintText: 'Search volunteer',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildSmallChip('Sort: $_selectedSort'),
                    const SizedBox(width: 8),
                    _buildSmallChip('Gender: $_selectedGender'),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildSmallChip('Status: $_selectedStatus'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildSmallChip('Help: $_selectedHelpType'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore.collection('volunteers').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final docs = snapshot.data?.docs ?? [];
                    final filteredDocs = _applyFilters(docs);

                    if (filteredDocs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No volunteers found',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        return _buildVolunteerCard(filteredDocs[index]);
                      },
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.home_outlined, size: 32),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.person_outline, size: 32),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined, size: 30),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF025590),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
