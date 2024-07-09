import 'package:flutter/material.dart';
import 'package:flutter_day_52/utils/extensions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

import '../../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final _placeController = TextEditingController();
  final LatLng _myApartment = const LatLng(41.2624092, 69.1517428);
  final LatLng _najotTalim = const LatLng(41.2858743, 69.2036048);
  LatLng myCurrentPosition = const LatLng(41.2624092, 69.1517428);
  MapType _mapType = MapType.normal;

  Set<Marker> myMarkers = {};
  Set<Polyline> polylines = {};
  List<LatLng> myPositions = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTypeChanged() {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await LocationService.getCurrentLocation();
      myCurrentPosition = LatLng(
        LocationService.currentLocation?.latitude ?? 0,
        LocationService.currentLocation?.longitude ?? 0,
      );
      setState(() {});
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      myCurrentPosition = position.target;
    });
  }

  void watchMyLocation() {
    LocationService.getLiveLocation().listen((location) {
      debugPrint("Live location: $location");
    });
  }

  void addLocationMarker() {
    myMarkers.add(
      Marker(
        markerId: MarkerId(myMarkers.length.toString()),
        position: myCurrentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    myPositions.add(myCurrentPosition);

    if (myPositions.length == 2) {
      LocationService.fetchPolylinePoints(
        myPositions[0],
        myPositions[1],
      ).then((List<LatLng> positions) {
        polylines.add(
          Polyline(
            polylineId: PolylineId(UniqueKey().toString()),
            color: Colors.blue,
            width: 5,
            points: positions,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              onCameraMove: onCameraMove,
              buildingsEnabled: true,
              initialCameraPosition:
                  CameraPosition(target: _myApartment, zoom: 20),
              mapType: _mapType,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId("myCurrentPosition"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                  position: myCurrentPosition,
                ),
                ...myMarkers,
              },
              polylines: polylines,
            ),
            Container(
              margin: const EdgeInsets.only(left: 12, right: 60, top: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                  )
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: GooglePlacesAutoCompleteTextFormField(
                textEditingController: _placeController,
                googleAPIKey: dotenv.get('GOOGLE_MAPS_API_KEY'),
                debounceTime: 200,
                isLatLngRequired: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 12),
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search place",
                ),
                maxLines: 1,
                getPlaceDetailWithLatLng: (prediction) {
                  if (prediction.lng != null && prediction.lat != null) {
                    LatLng destination = LatLng(double.parse(prediction.lat!),
                        double.parse(prediction.lng!));
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: destination,
                          zoom: 18,
                        ),
                      ),
                    );
                    setState(() {
                      myCurrentPosition = destination;
                    });
                  }

                  debugPrint(
                      "Coordinates: (${prediction.lat},${prediction.lng})");
                },
                itmClick: (prediction) {
                  _placeController.text = prediction.description ?? "";
                  _placeController.selection = TextSelection.fromPosition(
                    TextPosition(offset: prediction.description?.length ?? 0),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _onMapTypeChanged,
            child: Icon(
                _mapType == MapType.normal ? Icons.map_outlined : Icons.map),
          ),
          12.height,
          FloatingActionButton(
            onPressed: addLocationMarker,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
