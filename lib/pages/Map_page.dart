import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'accessible_place.dart';
import 'accessible_places_service.dart';
import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class AiMessage {
  final String text;
  final bool isAi;

  AiMessage({required this.text, required this.isAi});
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  final AccessiblePlacesService _placesService = AccessiblePlacesService();

  GoogleMapController? _mapController;
  Position? _currentPosition;

  bool _isLoadingLocation = true;
  bool _isSearching = false;

  AccessiblePlace? _selectedPlace;

  final List<AiMessage> _messages = [
    AiMessage(
      text:
          'Hello 👋 Tell me where you want to go, and I will suggest accessible places near you.',
      isAi: true,
    ),
  ];

  List<AccessiblePlace> _results = [];
  Set<Marker> _markers = {};

  static const Color _mainBlue = Color(0xFF87CEEB);
  static const Color _pageBg = Color(0xFFF4F4F4);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _saveSearchLog({
    required String query,
    required int resultCount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('map_search_logs').add({
      'userId': user.uid,
      'query': query,
      'resultCount': resultCount,
      'userLat': _currentPosition?.latitude,
      'userLng': _currentPosition?.longitude,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _saveSelectedPlace({
    required AccessiblePlace place,
    required String action,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('selected_accessible_places')
        .add({
          'userId': user.uid,
          'action': action,
          'placeId': place.id,
          'name': place.name,
          'category': place.category,
          'lat': place.lat,
          'lng': place.lng,
          'distanceKm': place.distanceKm,
          'mapsUri': place.mapsUri,
          'wheelchairEntrance': place.wheelchairEntrance,
          'accessibleParking': place.accessibleParking,
          'accessibleRestroom': place.accessibleRestroom,
          'accessibleSeating': place.accessibleSeating,
          'note': place.note,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  void _goToPage(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    }
  }

  Widget _bottomItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 27),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ];
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _mainBlue,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _shadow(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomItem(Icons.home_rounded, 'Home', 0),
          _bottomItem(Icons.person_rounded, 'Profile', 1),
          _bottomItem(Icons.settings_rounded, 'Settings', 2),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(height: 130, width: double.infinity, color: _mainBlue),
            Container(
              height: 40,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _pageBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
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
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Color(0xFF263238),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Accessible Map',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        _addAiMessage('Please turn on location services first.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        _addAiMessage(
          'Location permission is required to suggest nearby places.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _markers = {
          Marker(
            markerId: const MarkerId('my_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'My Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        };
      });

      _moveCamera(LatLng(position.latitude, position.longitude), zoom: 14);
    } catch (_) {
      setState(() => _isLoadingLocation = false);
      _addAiMessage('Failed to get your location.');
    }
  }

  void _addAiMessage(String text) {
    setState(() {
      _messages.add(AiMessage(text: text, isAi: true));
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(AiMessage(text: text, isAi: false));
    });
  }

  Future<void> _searchByPrompt(String prompt) async {
    if (_currentPosition == null) {
      _addAiMessage('I still need your current location first.');
      return;
    }

    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;

    _addUserMessage(trimmed);
    _searchController.clear();

    setState(() {
      _isSearching = true;
      _selectedPlace = null;
      _results = [];
    });

    try {
      final places = await _placesService.searchPlaces(
        query: trimmed,
        userLat: _currentPosition!.latitude,
        userLng: _currentPosition!.longitude,
      );

      await _saveSearchLog(query: trimmed, resultCount: places.length);

      final markers = <Marker>{
        Marker(
          markerId: const MarkerId('my_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
        ...places.map(
          (place) => Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.lat, place.lng),
            infoWindow: InfoWindow(
              title: place.name,
              snippet:
                  '${place.category} • ${place.distanceKm.toStringAsFixed(1)} km',
            ),
            onTap: () {
              setState(() {
                _selectedPlace = place;
              });
              _saveSelectedPlace(place: place, action: 'marker_tap');
            },
          ),
        ),
      };

      setState(() {
        _results = places;
        _markers = markers;
        _isSearching = false;
      });

      if (places.isEmpty) {
        _addAiMessage('I could not find accessible places for that request.');
        return;
      }

      _addAiMessage(
        'I found ${places.length} accessible options near you. Choose one and I will open its location.',
      );

      final first = places.first;
      _moveCamera(LatLng(first.lat, first.lng), zoom: 13.5);
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _addAiMessage('Search failed. Please try again.');
    }
  }

  Future<void> _openPlaceInMaps(AccessiblePlace place) async {
    await _saveSelectedPlace(place: place, action: 'open_map');

    final uri = Uri.parse(place.mapsUri);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _moveCamera(LatLng target, {double zoom = 14}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return ActionChip(
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE5E5E5)),
      label: Text(label),
      onPressed: () => _searchByPrompt(label),
    );
  }

  Widget _buildMessageBubble(AiMessage message) {
    return Align(
      alignment: message.isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: message.isAi ? const Color(0xFFEAF6FB) : _mainBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isAi ? Colors.black87 : Colors.white,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPlaceCard(AccessiblePlace place) {
    final isSelected = _selectedPlace?.id == place.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFDDF2FB) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? _mainBlue : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${place.category} • ${place.distanceKm.toStringAsFixed(1)} km away',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (place.wheelchairEntrance) _tag('Entrance'),
              if (place.accessibleParking) _tag('Parking'),
              if (place.accessibleRestroom) _tag('Restroom'),
              if (place.accessibleSeating) _tag('Seating'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            place.note,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _selectedPlace = place;
                    });

                    await _saveSelectedPlace(
                      place: place,
                      action: 'select_place',
                    );

                    _moveCamera(LatLng(place.lat, place.lng), zoom: 15.5);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Select',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openPlaceInMaps(place),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Open Map'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = _currentPosition == null
        ? const LatLng(26.2235, 50.5876)
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: _isLoadingLocation
                          ? const Center(child: CircularProgressIndicator())
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: initialTarget,
                                zoom: 14,
                              ),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: false,
                              markers: _markers,
                              onMapCreated: (controller) {
                                _mapController = controller;
                              },
                            ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                        decoration: BoxDecoration(
                          color: _pageBg,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 14,
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 95,
                              child: ListView(
                                children: _messages
                                    .take(
                                      _messages.length > 3
                                          ? 3
                                          : _messages.length,
                                    )
                                    .map(_buildMessageBubble)
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildQuickChip('Restaurant'),
                                _buildQuickChip('Cafe'),
                                _buildQuickChip('Hospital'),
                                _buildQuickChip('Mall'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Tell AI where you want to go',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onSubmitted: _searchByPrompt,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: _isSearching
                                      ? null
                                      : () => _searchByPrompt(
                                          _searchController.text,
                                        ),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _mainBlue,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: _isSearching
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            if (_results.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 220,
                                child: ListView.builder(
                                  itemCount: _results.length,
                                  itemBuilder: (context, index) {
                                    return _buildPlaceCard(_results[index]);
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }
}
