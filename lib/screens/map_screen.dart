import 'dart:async';
import 'package:expensetracker/models/Transaction.dart';
import 'package:expensetracker/services/google_sheets_provider.dart';
import 'package:expensetracker/services/location_provider.dart';
import 'package:provider/provider.dart';
import "package:flutter/material.dart";
import "package:location/location.dart";
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  static const routeName = "mapscreen";

  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set.from([]);

  var mapStyle = [
    {
      "featureType": "administrative.land_parcel",
      "elementType": "labels",
      "stylers": [
        {"visibility": "off"}
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text",
      "stylers": [
        {"visibility": "off"}
      ]
    },
    {
      "featureType": "road.local",
      "elementType": "labels",
      "stylers": [
        {"visibility": "off"}
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<LocationProvider>(context, listen: false)
                  .fetchLocation();
            },
          ),
        ],
      ),
      body: Consumer2<LocationProvider, GoogleSheetsProvider>(builder: (
        BuildContext context,
        locationProvider,
        googleSheetsProvider,
        Widget? child,
      ) {
        // Loading
        if (locationProvider.loading || googleSheetsProvider.loading) {
          return LinearProgressIndicator();
        }
        // If error
        if (locationProvider.error) {
          return Text(
            "Unexpected Error: Location not found",
            style: TextStyle(color: Colors.red),
          );
        }

        // Location data available
        LocationData _locationData = locationProvider.locationData;
        var uuid = Uuid();
        Set<Marker> _markers = Set.from([]);

        googleSheetsProvider.transactionList.forEach(
          (Transaction _transaction) {
            _markers.add(
              Marker(
                markerId: MarkerId(_transaction.id.toString()),
                infoWindow: InfoWindow(title: _transaction.name),
                position: LatLng(
                  _transaction.latitude,
                  _transaction.longitude,
                ),
              ),
            );
          },
        );

        return GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              _locationData.latitude,
              _locationData.longitude,
            ),
            zoom: 17,
          ),
          onMapCreated: (GoogleMapController controller) {
            controller.setMapStyle(mapStyle.toString());
            _controller.complete(controller);
          },
          // onTap: (pos) {
          //   print(pos);
          //   Marker f = Marker(
          //     markerId: MarkerId('1'),
          //     // icon:  Icon(Icons.monetization_on),
          //     infoWindow: InfoWindow(title: "test", snippet: 'lemon'),
          //     position: LatLng(pos.latitude, pos.longitude),
          //     onTap: () {},
          //   );
          // },
        );
      }),
    );
  }
}
