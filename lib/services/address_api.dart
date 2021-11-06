import 'package:geocoder/geocoder.dart';

Future<String> getAddress(double latitude, double longitude) async {
  final coordinates = new Coordinates(latitude, longitude);
  List<Address> addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);

  return addresses[0].subLocality ?? "";

  addresses.forEach((element) {
    print(element.locality);
    print(element.subLocality);
    print(element.addressLine);
    print("#########");
  });
  print("----------");
  String addr = addresses.first.addressLine.split(',')[0] +
      ", " +
      addresses.first.featureName;
  // print(addr);

  return addr;
}
