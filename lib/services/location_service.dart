import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  LocationService._();

  static final _location = Location();

  static bool _isServiceEnabled = false;
  static PermissionStatus _permissionStatus = PermissionStatus.denied;
  static LocationData? currentLocation;

  static Future<void> init() async {
    await _checkService();
    await _checkPermission();
  }

  static Future<void> _checkService() async {
    _isServiceEnabled = await _location.serviceEnabled();
    if (!_isServiceEnabled) {
      _isServiceEnabled = await _location.requestService();
      if (!_isServiceEnabled) {
        return; // Endi sozlamalardan to'g'rilash kerak
      }
    }
  }

  static Future<void> _checkPermission() async {
    _permissionStatus = await _location.hasPermission();

    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return; // Endi sozlamalardan to'g'rilash kerak
      }
    }
  }

  static Future<void> getCurrentLocation() async {
    if (_isServiceEnabled && _permissionStatus == PermissionStatus.granted) {
      currentLocation = await _location.getLocation();
    }
  }

  static Stream<LocationData> getLiveLocation() async* {
    yield* _location.onLocationChanged;
  }

  static Future<List<LatLng>> fetchPolylinePoints(
    LatLng from,
    LatLng to,
  ) async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: dotenv.get("GOOGLE_MAPS_API_KEY"),
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.transit,
      ),
    );

    if (result.points.isNotEmpty) {
      return result.alternatives
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    }

    return [];
  }

}
