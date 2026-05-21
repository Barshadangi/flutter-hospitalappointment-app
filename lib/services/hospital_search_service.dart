import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class HospitalSearchService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getNearbyHospitals() async {

    Position userPosition = await LocationService.getCurrentLocation();

    QuerySnapshot snapshot =
        await _firestore.collection('hospitals').get();

    List<Map<String, dynamic>> nearbyHospitals = [];

    for (var doc in snapshot.docs) {

      double hospitalLat = doc['latitude'];
      double hospitalLng = doc['longitude'];

      double distanceInMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        hospitalLat,
        hospitalLng,
      );

      double distanceInKm = distanceInMeters / 1000;

      if (distanceInKm <= 10) {
        nearbyHospitals.add({
          'id': doc.id,
          'name': doc['name'],
          'address': doc['address'],
          'distance': distanceInKm,
        });
      }
    }

    nearbyHospitals.sort(
      (a, b) => a['distance'].compareTo(b['distance']),
    );

    return nearbyHospitals;
  }
}