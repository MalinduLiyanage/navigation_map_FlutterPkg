import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mtmc/mtmc.dart';
import 'package:http/http.dart' as http;
import 'package:compassx/compassx.dart';
import 'dart:math' as math;

class NavigationMap extends StatefulWidget {
  final Function(LatLng)? onDestinationSelected;
  final Function(LatLng, LatLng)? onRouteSelected;

  const NavigationMap({
    Key? key,
    this.onDestinationSelected,
    this.onRouteSelected,
  }) : super(key: key);

  @override
  State<NavigationMap> createState() => NavigationMapState();
}

class NavigationMapState extends State<NavigationMap> {
  LatLng? _currentPosition;
  Stream<Position>? _positionStream;
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  LatLng? _destination;
  double _currentSpeed = 0.0;
  List<LatLng> _fixedLocations = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position initialPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition =
          LatLng(initialPosition.latitude, initialPosition.longitude);
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    );

    _positionStream?.listen((Position position) {
      final newPosition = LatLng(position.latitude, position.longitude);
      _currentSpeed = position.speed >= 0 ? position.speed : 0;
      _currentSpeed = _currentSpeed * 3.6;
      setState(() {
        _currentPosition = newPosition;
      });
    });
  }

  Future<void> fetchRoute(LatLng start, LatLng end) async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coordinates = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        _routePoints = coordinates
            .map<LatLng>((point) => LatLng(point[1], point[0]))
            .toList();
      });
    } else {
      print("Failed to fetch route");
    }
  }

  Future<String?> getLocationName(LatLng location) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${location.latitude}&lon=${location.longitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name']; // The name of the location
      } else {
        print(
            "Failed to fetch location name. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching location name: $e");
      return null;
    }
  }

  LatLng? getCurrentLocation() {
    return _currentPosition; // Expose the current position.
  }

  double getCurrentSpeed() {
    return _currentSpeed;
  }

  double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
        from.latitude, from.longitude, to.latitude, to.longitude);
  }

  void clearRoute() {
    setState(() {
      _routePoints.clear(); // Clears the list of route points
    });
  }

  void addFixedLocation(LatLng location) {
    setState(() {
      _fixedLocations.add(location);
    });
  }

  void clearFixedLocations() {
    setState(() {
      _fixedLocations.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition!,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tileProvider: MTMC(),
        ),
        MarkerLayer(
          markers: [
            // Current position marker
            Marker(
              point: _currentPosition!,
              child: StreamBuilder<CompassXEvent>(
                stream: CompassX.events,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Icon(
                      Icons.navigation,
                      color: Colors.red,
                      size: 40,
                    );
                  }
                  final compass = snapshot.data!;
                  return Transform.rotate(
                    angle: compass.heading * math.pi / 180,
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            // Destination marker
            if (_destination != null)
              Marker(
                point: _destination!,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            // Spread the fixed location markers
            ..._fixedLocations.map((location) => Marker(
                  point: location,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.green,
                    size: 40,
                  ),
                )),
          ],
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
            ],
          ),
      ],
    );
  }
}
