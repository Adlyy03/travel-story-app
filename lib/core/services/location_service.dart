import 'dart:async';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  notRequested,
  granted,
  denied,
  permanentlyDenied,
}

class LocationService {
  StreamSubscription<Position>? _positionStream;
  
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  Future<LocationPermissionStatus> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.denied;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      default:
        return LocationPermissionStatus.notRequested;
    }
  }

  Future<LocationPermissionStatus> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.denied;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      default:
        return LocationPermissionStatus.denied;
    }
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {}

    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  void startTracking(Function(Position) onPositionUpdate) {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(
      (Position position) {
        if (position.accuracy <= 50) {
          onPositionUpdate(position);
        }
      },
      onError: (error) {
        // Handle error silently
      },
    );
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  bool get isTracking => _positionStream != null;

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
