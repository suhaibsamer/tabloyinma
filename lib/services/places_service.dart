import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mosque.dart';

class PlacesService {
  // Production Note: In a production environment, you should secure your API key 
  // and consider using a backend proxy to avoid exposing it on the client side.
  static const String _apiKey = 'AIzaSyAF3qUoIw9KJg-wuBMhU2qvAWJJpgKHLzM';

  Future<List<Mosque>> fetchNearbyMosques(double lat, double lng) async {
    final String url = 
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=5000' // Search within 5km radius
        '&type=mosque'
        '&keyword=mosque'
        '&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final List<dynamic> results = data['results'];
          return results.map((json) => Mosque.fromJson(json)).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Google Places API Error: ${data['status']} - ${data['error_message'] ?? 'No additional info'}');
        }
      } else {
        throw Exception('HTTP Request Failed: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch mosques: $e');
    }
  }
}
