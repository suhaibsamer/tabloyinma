import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;
import '../models/mosque.dart';
import '../services/places_service.dart';

class MosqueMapScreen extends StatefulWidget {
  const MosqueMapScreen({super.key});

  @override
  State<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends State<MosqueMapScreen> {
  final PlacesService _placesService = PlacesService();
  
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Mosque> _mosques = [];
  bool _isLoading = false;
  bool _showList = false;
  String _statusMessage = 'Initializing...';

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(36.191113, 44.009167), // Erbil
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() => _statusMessage = 'Checking permissions...');
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Location permissions are permanently denied.');
      return;
    }

    try {
      setState(() => _statusMessage = 'Getting your location...');
      final Position position = await Geolocator.getCurrentPosition();
      
      developer.log('Current Position: ${position.latitude}, ${position.longitude}');

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14.0,
        ),
      );

      _getNearbyMosques(position.latitude, position.longitude);
    } catch (e) {
      _showError('Error getting location: $e');
    }
  }

  Future<void> _getNearbyMosques(double lat, double lng) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Searching for mosques...';
    });
    
    try {
      developer.log('Fetching mosques for: $lat, $lng');
      final List<Mosque> mosques = await _placesService.fetchNearbyMosques(lat, lng);
      developer.log('Found ${mosques.length} mosques');
      
      final Set<Marker> newMarkers = mosques.map((mosque) {
        return Marker(
          markerId: MarkerId(mosque.placeId),
          position: LatLng(mosque.latitude, mosque.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: mosque.name,
            snippet: mosque.address,
          ),
        );
      }).toSet();

      setState(() {
        _mosques = mosques;
        _markers = newMarkers;
        _isLoading = false;
        _statusMessage = mosques.isEmpty ? 'No mosques found nearby.' : 'Found ${mosques.length} mosques.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: $e';
      });
      developer.log('API Error: $e');
      _showError('API Error: $e');
    }
  }

  void _onCameraIdle() {
    if (_mapController != null) {
      _mapController!.getVisibleRegion().then((LatLngBounds bounds) {
        final double centerLat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
        final double centerLng = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
        _getNearbyMosques(centerLat, centerLng);
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mosque Finder'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () => setState(() => _showList = !_showList),
            tooltip: _showList ? 'Show Map' : 'Show List',
          ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.green.shade50,
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green.shade900, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _showList ? _buildMosqueList() : _buildMapView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _determinePosition,
        backgroundColor: Colors.green.shade800,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: _kInitialPosition,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false, // Custom FAB handles this
      onCameraIdle: _onCameraIdle,
    );
  }

  Widget _buildMosqueList() {
    if (_mosques.isEmpty && !_isLoading) {
      return const Center(child: Text('No mosques found. Try moving the map.'));
    }
    return ListView.separated(
      itemCount: _mosques.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final mosque = _mosques[index];
        return ListTile(
          leading: const Icon(Icons.mosque, color: Colors.green),
          title: Text(mosque.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(mosque.address ?? 'No address available'),
          onTap: () {
            setState(() => _showList = false);
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(mosque.latitude, mosque.longitude), 16),
            );
          },
        );
      },
    );
  }
}

