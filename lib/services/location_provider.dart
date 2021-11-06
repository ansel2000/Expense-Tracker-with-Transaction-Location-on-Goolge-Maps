import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

class LocationProvider extends ChangeNotifier {
  late LocationData locationData;
  bool loading = false;
  bool error = false;

  Future<void> fetchLocation() async {
    print("IN HERE");
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    loading = true;
    notifyListeners();

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setError();
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        setError();
        return;
      }
    }

    _locationData = await location.getLocation();

    print(_locationData.latitude.toString() +
        "," +
        _locationData.longitude.toString());

    loading = false;
    locationData = _locationData;
    notifyListeners();
  }

  setError() {
    error = true;
    loading = false;
    notifyListeners();
  }

  LocationProvider() {
    fetchLocation();
  }
}
