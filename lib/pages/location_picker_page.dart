import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_settings_store.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  static const LatLng _defaultLocation = LatLng(26.2235, 50.5876);
  static const Color _mainBlue = Color(0xFF87CEEB);
  static const Color _pageBg = Color(0xFFF4F4F4);

  LatLng _selectedLocation = _defaultLocation;
  bool _isLoading = true;
  String _locationText = '';

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    AppSettingsStore.instance.addListener(_onLanguageChanged);
    _locationText = tr('Selected Location', 'الموقع المحدد');
    _initializeLocation();
  }

  void _onLanguageChanged() {
    if (!mounted) return;

    setState(() {
      if (_locationText == 'Selected Location' ||
          _locationText == 'الموقع المحدد') {
        _locationText = tr('Selected Location', 'الموقع المحدد');
      } else {
        _locationText = _formatLocationText(_selectedLocation);
      }
    });
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  String _formatLocationText(LatLng location) {
    return tr(
      'Lat: ${location.latitude.toStringAsFixed(5)}, Lng: ${location.longitude.toStringAsFixed(5)}',
      'خط العرض: ${location.latitude.toStringAsFixed(5)}، خط الطول: ${location.longitude.toStringAsFixed(5)}',
    );
  }

  Future<void> _initializeLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!mounted) return;

      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (!mounted) return;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final LatLng currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _selectedLocation = currentLocation;
        _locationText = _formatLocationText(currentLocation);
        _isLoading = false;
      });

      final controller = await _mapController.future;

      if (!mounted) return;

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 16),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoading = false);
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final LatLng currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _selectedLocation = currentLocation;
        _locationText = _formatLocationText(currentLocation);
      });

      final controller = await _mapController.future;

      if (!mounted) return;

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 16),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Unable to get current location',
              'تعذر الحصول على الموقع الحالي',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _saveLocationLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('location_logs').add({
      'userId': user.uid,
      'address': _locationText,
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _confirmLocation() async {
    await _saveLocationLog();

    if (!mounted) return;

    Navigator.pop(context, {
      'address': _locationText,
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
    });
  }

  void _goBack() {
    Navigator.pop(context);
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
                icon: Icon(
                  isArabic ? Icons.arrow_forward : Icons.arrow_back,
                  size: 28,
                  color: const Color(0xFF263238),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    tr('Pick Location', 'اختيار الموقع'),
                    style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      markerId: const MarkerId('selected_location'),
      position: _selectedLocation,
      draggable: true,
      onDragEnd: (LatLng newPosition) {
        if (!mounted) return;

        setState(() {
          _selectedLocation = newPosition;
          _locationText = _formatLocationText(newPosition);
        });
      },
    );

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation,
                              zoom: 14,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            markers: {marker},
                            onMapCreated: (GoogleMapController controller) {
                              if (!_mapController.isCompleted) {
                                _mapController.complete(controller);
                              }
                            },
                            onTap: (LatLng tappedLocation) {
                              if (!mounted) return;

                              setState(() {
                                _selectedLocation = tappedLocation;
                                _locationText =
                                    _formatLocationText(tappedLocation);
                              });
                            },
                          ),
                          Positioned(
                            top: 16,
                            right: isArabic ? null : 16,
                            left: isArabic ? 16 : null,
                            child: FloatingActionButton(
                              heroTag: 'current_location_btn',
                              mini: true,
                              backgroundColor: Colors.white,
                              onPressed: _goToCurrentLocation,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 20,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 8,
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _locationText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _confirmLocation,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _mainBlue,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        tr(
                                          'Confirm Location',
                                          'تأكيد الموقع',
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
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
      ),
    );
  }
}
