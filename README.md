# NavigationMap

`NavigationMap` is a Flutter package for live navigation, location tracking, and route visualization on interactive maps. It's built using `flutter_map`, with support for features like fixed markers, current speed, and route drawing.

## Features

- Display current location and track movement.
- Draw routes between locations.
- Add fixed location markers.
- Get real-time speed in km/h.
- Fetch location names using reverse geocoding.

## Installation

Add `navigation_map` to your `pubspec.yaml`:

```yaml
dependencies:
  navigation_map: ^0.0.1
  latlong2: 0.9.1
```
Configure your Permissions according to your Target Platform.

- For Android

1. Add the following to your `gradle.properties` file:

```
android.useAndroidX=true
android.enableJetifier=true
```

2. Make sure you set the compileSdkVersion in your `android/app/build.gradle` file to 34:

```
android {
  compileSdkVersion 34

  ...
}
```

3. Setup Permissions in `AndroidManifest.xml`

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />    
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <application
```

4. If it raises a Kotlin version error, update to the latest Kotlin version in `settings.gradle`

```
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "7.3.0" apply false
    id "org.jetbrains.kotlin.android" version "2.0.21" apply false
}
```

- For iOS

1. Add below in your `Info.plist` file (located under ios/Runner) 

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
```

For more information about the configurations on Android and iOS, visit `geolocator` package's page on Pub.dev

## Docs

1. Load the map and get current location

```
Widget build(BuildContext context) {
  final GlobalKey<NavigationMapState> navMapKey = GlobalKey();

  return SafeArea(
    child: Scaffold(
      body: NavigationMap(
        key: navMapKey,
      ),
    ),
  );
}
```

2. Retrieve Current Location as a `LatLng` Coordinates.

```
final location = navMapKey.currentState?.getCurrentLocation();
  if (location != null) {
    print(location);
  }
```
3. Add Fixed Location

```
final mapState = navMapKey.currentState;
  if (mapState != null) {
    // Example fixed location
    mapState.addFixedLocation(
    LatLng(6.927079, 79.861244)); // Replace with your LatLng
  }
```

4. Define a Route

```
navMapKey.currentState?.clearRoute(); 
navMapKey.currentState?.fetchRoute(
LatLng(37.7749, -122.4194), LatLng(34.0522, -118.2437));
```

5. Get Distance in meters
```
final mapState = navMapKey.currentState;
  if (mapState != null) {
    LatLng colombo = LatLng(6.9271, 79.8612);
    LatLng galle = LatLng(6.0328, 80.2168);
    double distance = mapState.calculateDistance(colombo, galle);

    print("Distance: $distance meters");
  }
```
6. Clear the route if is set

```
navMapKey.currentState?.clearRoute(); 
```

7. Get Current Speed in kmph
```
print(navMapKey.currentState?.getCurrentSpeed());
```

8. Retrieve Location Name

```
//Ex : Location Name: D. R. Wijewardene Mawatha, Suduwella, Slave Island, Colombo, Colombo District, Western Province, 00200, Sri Lanka
floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final mapState = navMapKey.currentState;
            LatLng colombo = LatLng(6.9271, 79.8612);
            if (mapState != null) {
              String? locationName = await mapState.getLocationName(colombo);
              if (locationName != null) {
                print("Location Name: $locationName");
              } else {
                print("Could not retrieve location name.");
              }
            }
          },
        ),
```