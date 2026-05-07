# Flutter Map Application — Blueprint and Implementation Plan

**Project Type:** College Demonstration Project  
**Domain:** Geolocation and Map Integration  
**Tech Stack:** Flutter, Geolocator, Geocoding, Riverpod, OpenStreetMap  
**Architecture:** Single-page, modular, scalable  
**Tier:** Fully free, no paid APIs  

---

## Part 1 — Product Thinking

### 1.1 What Problem This Solves

Most map application tutorials either rely on Google Maps (paid beyond a threshold) or skip the real engineering concerns entirely. This project demonstrates two fundamental capabilities of any location-aware application:

- Knowing where the user is right now, whether they are online or not.
- Letting a user specify a start and end point and visualizing a path between them.

This is the minimal viable feature set of any navigation product. Understanding how to build this from first principles gives a complete picture of how location-aware apps work at the architectural level.

### 1.2 User Mental Model

The user of this application thinks about maps in exactly two modes:

**Mode A — "Where am I?"**  
The user opens the app and expects the map to immediately center on their current position. If they are moving, they expect the marker to move with them. If they lose connectivity, they expect the app to remember where they last were rather than showing an error.

**Mode B — "How do I get from A to B?"**  
The user types or selects two places, and the app draws the route between them. No turn-by-turn is needed at this stage. The visual path on the map is the deliverable.

These two modes are distinct but share the same map surface. The design must accommodate switching between them without confusion.

### 1.3 Why OpenStreetMap

OpenStreetMap (OSM) is a community-maintained, freely licensed geographic database. It has no usage caps, no API keys for tile rendering at small scales, and it is the data source behind many commercial mapping products. For a demonstration project:

- No billing setup required.
- No key rotation or environment variable management.
- Tiles load from public CDN endpoints such as `tile.openstreetmap.org`.
- Routing is available through the OSRM (Open Source Routing Machine) public API, also free.

The trade-off is that tile servers can be slower than commercial alternatives and the routing API has fair-use limits, both of which are acceptable constraints for a demonstration.

---

## Part 2 — Design Thinking

### 2.1 Design Philosophy

The application follows a principle called "map-first design." The map is the primary object. Every other UI element exists to serve the map, not compete with it. This means:

- The map occupies the full screen surface at all times.
- Controls are overlaid on the map, not placed in separate panels.
- Information (current location marker, route line, address labels) appears on the map canvas, not in a sidebar.

This mirrors how professional navigation applications like Google Maps and Apple Maps are structured.

### 2.2 Material Theme System

Flutter's Material 3 design system organizes color into semantic roles. The application will define a centralized theme object so that colors are never hard-coded at the widget level. The roles used in this application are:

**Primary:** The main interactive color. Used for the floating action buttons, the active location marker, and route highlight.

**Secondary:** Supporting interactive color. Used for the origin/destination input chips and secondary buttons.

**Tertiary:** Accent color for emphasis. Used for the destination pin and any active state that needs distinction from primary.

**Surface:** The background of overlay cards such as the search bar panel and route information card.

**Container variants (primaryContainer, secondaryContainer):** Used for the background of chips, badges, and icon buttons to create visual hierarchy without using full primary color saturation.

**Text colors (onPrimary, onSurface, onContainer):** Each surface role has a paired text color that guarantees contrast compliance.

All these values are defined once in a `ThemeData` object and passed to the `MaterialApp`. No widget in the application references a hardcoded `Color(...)` value. This ensures a single point of change for visual redesign.

### 2.3 Screen Composition

The application has one screen. That screen is layered as follows, from bottom to top:

**Layer 1 — Map Widget**  
Occupies 100% of the screen. Listens to a Riverpod state provider that holds the current camera position and any overlays (markers, polylines).

**Layer 2 — Overlaid Controls**  
A `Stack` widget places the following over the map:
- A top search bar for from-to input (slides in when the user activates route mode).
- A bottom sheet or card that displays route summary information after a route is drawn.
- A floating action button cluster in the bottom-right corner for location centering and mode switching.

**Layer 3 — Status Indicators**  
A thin status chip at the top of the screen shows whether the location source is live (online GPS) or cached (last known offline position). This is a critical UX signal.

### 2.4 User Flow

```
App Launch
  |
  v
Request location permission
  |
  +--[Granted]---> Start location stream ---> Center map on live position ---> Idle Mode
  |
  +--[Denied]-----> Show last cached location (if any) ---> Offline Mode
  |
  +--[First run, no cache]---> Default city view ---> Prompt user to enable permission

Idle Mode
  |
  +--[Tap FAB: Route]---> Activate Route Mode
  |
  +--[Auto]--> Location stream updates marker every N seconds

Route Mode
  |
  +--[Enter origin address]---> Geocode to coordinates
  +--[Enter destination address]---> Geocode to coordinates
  +--[Both filled]---> Call OSRM API ---> Decode polyline ---> Draw on map
  +--[Tap FAB: Clear]---> Return to Idle Mode
```

---

## Part 3 — Architecture

### 3.1 Single-Page, Multi-Provider Architecture

The application has one `Scaffold` and one `Route` in its navigation stack. All state is managed through Riverpod providers. This is not a limitation — it is a deliberate architectural choice that avoids the complexity of route management while keeping the code modular.

Each concern in the application maps to one provider. Providers are composable — a higher-level provider can watch a lower-level provider and derive its state from it. This creates a clear dependency graph.

### 3.2 Provider Dependency Graph

```
locationServiceProvider  <-- watches platform GPS stream
        |
        v
locationStateProvider   <-- derives: isOnline, currentLatLng, lastKnownLatLng
        |
        v
mapCameraProvider       <-- moves camera when locationStateProvider emits new position
        |
        v
mapControllerProvider   <-- holds flutter_map controller reference

routeProvider           <-- independent, activated by user
        |
        +-- geocodingProvider (origin input)
        +-- geocodingProvider (destination input)
        +-- routingProvider (calls OSRM, holds decoded polyline)
```

### 3.3 File Structure

```
lib/
  main.dart                    -- App entry, theme, ProviderScope

  theme/
    app_theme.dart             -- ThemeData, ColorScheme definition

  providers/
    location_provider.dart     -- Location stream, online/offline state
    map_provider.dart          -- Map controller, camera state
    route_provider.dart        -- Route state: origin, destination, polyline

  services/
    location_service.dart      -- Geolocator wrapper, permission handling
    geocoding_service.dart     -- Address to LatLng and reverse
    routing_service.dart       -- OSRM API call, polyline decode

  models/
    location_state.dart        -- Data class: LatLng, isOnline, timestamp
    route_state.dart           -- Data class: origin, destination, polyline points

  widgets/
    map_view.dart              -- flutter_map widget, listens to providers
    location_marker.dart       -- Animated marker for current position
    route_overlay.dart         -- Polyline and pin rendering
    search_panel.dart          -- Collapsible from/to input panel
    route_info_card.dart       -- Distance, estimated time display
    status_chip.dart           -- Online/offline indicator
    fab_cluster.dart           -- Floating action button group
```

This structure has eight files outside of `main.dart`. Each file has a single responsibility. Adding a new feature (for example, saved places or traffic overlay) means adding a new provider file and a new widget file without touching existing files.

### 3.4 State Management with Riverpod

Riverpod is chosen over Provider, BLoC, or GetX for three reasons relevant to this project:

**Compile-time safety:** Providers are defined as top-level constants. There is no `context.read()` lookup at runtime that could fail. The analyzer catches missing dependencies.

**No BuildContext dependency for business logic:** Services and providers have no dependency on Flutter's widget tree. Location and routing logic can be tested independently.

**StreamProvider for location:** Geolocator's position stream maps directly to a Riverpod `StreamProvider`. The UI reactively rebuilds whenever a new GPS position arrives, with zero boilerplate.

The key provider types used:

- `StreamProvider<LocationState>` — wraps the Geolocator position stream.
- `StateNotifierProvider<RouteNotifier, RouteState>` — manages the route building lifecycle.
- `Provider<MapController>` — holds a single instance of the flutter_map controller.

---

## Part 4 — Technical Design

### 4.1 Location Handling

The Geolocator plugin provides both one-time position reads and continuous streams. The application uses both:

**On startup:** A single `Geolocator.getCurrentPosition()` call with a short timeout. This gives an immediate position to center the map.

**During app use:** A `Geolocator.getPositionStream()` with configurable accuracy and distance filter. The distance filter (for example, 10 meters) prevents redundant state updates when the user is stationary.

**Offline handling:** When the stream emits an error or connectivity is lost, the application reads the last successfully stored position from local storage (using `SharedPreferences` or a simple file cache). The `LocationState` model carries an `isOnline` flag that the UI uses to display the status chip.

**Permissions:** The Geolocator plugin handles permission requests on both Android and iOS. The application must declare permissions in `AndroidManifest.xml` and `Info.plist`. The permission flow is handled inside `LocationService` so the UI layer never deals with permission status directly.

### 4.2 Map Rendering with flutter_map

`flutter_map` is a pure-Flutter, open-source map widget that renders OSM tiles. It is the standard choice for OSM integration in Flutter. Key concepts:

**TileLayer:** Configured with the OSM tile URL template `https://tile.openstreetmap.org/{z}/{x}/{y}.png`. This loads map tiles from OSM's public CDN.

**MarkerLayer:** Used to display the current location marker. The marker widget is a custom animated widget that pulses to indicate live tracking.

**PolylineLayer:** Used to display the route line between origin and destination. The polyline is a list of `LatLng` points decoded from the OSRM response.

**MapController:** A controller object passed to the `FlutterMap` widget that allows programmatic camera movement — centering on the user's position, fitting the route in view, and setting zoom levels.

### 4.3 Routing with OSRM

The Open Source Routing Machine (OSRM) provides a public routing API at `router.project-osrm.org`. The route endpoint accepts two coordinate pairs and returns a JSON response containing a geometry field encoded as a polyline string.

The request format is:
```
https://router.project-osrm.org/route/v1/driving/{lon1},{lat1};{lon2},{lat2}?overview=full&geometries=polyline
```

The response geometry is encoded using Google's Polyline Encoding Format. The application includes a polyline decoder utility (a small pure-Dart function with no dependencies) that converts this string into a list of `LatLng` points for rendering.

OSRM is used only for demonstration. Its public instance has no uptime guarantee and has fair-use throttling. For production, a self-hosted OSRM instance or an alternative (like Valhalla) would be appropriate.

### 4.4 Geocoding

The `geocoding` Flutter plugin translates between address strings and geographic coordinates. It uses the device's platform geocoder (on Android, this is typically backed by Google's geocoder; on iOS, it uses CoreLocation).

For the demonstration, this is acceptable because the geocoding calls come from the user typing addresses, not from any programmatic flow that would require a commercial geocoding API.

The `GeocodingService` wraps the plugin's `locationFromAddress()` and `placemarkFromCoordinates()` calls and returns typed results to the routing provider.

### 4.5 Theme Implementation

The theme is defined as a single `ThemeData` object in `app_theme.dart`. The `ColorScheme` is constructed using `ColorScheme.fromSeed()` with a chosen seed color, which generates a harmonious Material 3 palette automatically. Individual roles (primary, secondary, tertiary, surface) can be overridden explicitly.

The `TextTheme` is defined with explicit `TextStyle` entries for each Material type scale role (displayLarge, headlineMedium, bodyLarge, labelSmall, etc.).

All widgets use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme` to pull values. This is enforced as a code convention.

---

## Part 5 — Phase-wise Implementation Plan

The application is built in five phases. Each phase produces a working, runnable state of the application. No phase leaves the application in a broken or unrunnable state.

---

### Phase 1 — Project Foundation

**Goal:** A running Flutter application with the correct package dependencies, theme system, and folder structure in place. No map rendering yet.

**Deliverables:**

1. Create a new Flutter project with the standard `flutter create` command.
2. Add all required dependencies to `pubspec.yaml`: `flutter_map`, `latlong2`, `geolocator`, `geocoding`, `flutter_riverpod`, `riverpod_annotation`, `http`, `shared_preferences`.
3. Run `flutter pub get` and confirm zero dependency conflicts.
4. Create the folder structure: `theme/`, `providers/`, `services/`, `models/`, `widgets/`.
5. Create `app_theme.dart` with a complete `ThemeData` definition. Define the color seed and all semantic color overrides. Verify the theme renders correctly by building the app with a simple `Scaffold` and `AppBar`.
6. Wrap the app in `ProviderScope` in `main.dart`. Confirm that `ConsumerWidget` can be used in a test widget.
7. Add permission declarations to `AndroidManifest.xml` (both `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` and `INTERNET`) and to `ios/Runner/Info.plist`.

**Acceptance criteria:** The app runs on a device or emulator, shows a themed scaffold with the correct primary color, and has no compile errors.

---

### Phase 2 — Map Rendering and Camera Control

**Goal:** A full-screen interactive OSM map with working pan, zoom, and programmatic camera control via a Riverpod provider.

**Deliverables:**

1. Create `map_provider.dart` with a `Provider<MapController>` that holds a single `MapController` instance.
2. Create `map_view.dart` with a `FlutterMap` widget using the OSM tile layer URL. The widget reads the `MapController` from the provider.
3. Implement the full-screen `Stack` layout in the main screen widget: `FlutterMap` at the bottom, placeholder overlay containers at the top and bottom.
4. Create `fab_cluster.dart` with a single placeholder FAB that, when tapped, calls `mapController.move()` to animate the camera to a test coordinate.
5. Verify tile loading works — tiles should appear from the OSM CDN when the device has internet.
6. Verify that panning and pinch-to-zoom work as expected.

**Acceptance criteria:** The app shows a full-screen interactive OSM map. A FAB tap moves the camera to a hardcoded coordinate. No location permission is requested yet.

---

### Phase 3 — Live Location and Offline Fallback

**Goal:** The application tracks the user's real-time GPS position, displays an animated marker on the map, handles the offline case gracefully, and shows the online/offline status chip.

**Deliverables:**

1. Create `location_state.dart` model with fields: `latLng`, `isOnline`, `timestamp`, `accuracy`.
2. Create `location_service.dart`:
   - Implement permission request flow using Geolocator.
   - Implement a stream that emits `LocationState` objects from `Geolocator.getPositionStream()`.
   - Implement a `getLastKnownPosition()` method that reads from `SharedPreferences`.
   - Implement a `cachePosition()` method that writes to `SharedPreferences` on each new emission.
3. Create `location_provider.dart`:
   - Define a `StreamProvider<LocationState>` that consumes the location service stream.
   - Handle stream errors by emitting a `LocationState` with `isOnline: false` and the last cached `LatLng`.
4. Update `map_view.dart` to watch the `locationProvider` and move the camera on the first position emission.
5. Create `location_marker.dart`:
   - A pulsing animated circle widget (using `AnimationController` and `AnimatedBuilder`).
   - An inner filled circle representing the user's exact position.
   - An outer expanding ring that indicates live tracking activity.
   - When `isOnline` is false, the animation stops and the marker color changes to a muted variant.
6. Create `status_chip.dart`: a small pill-shaped overlay at the top of the screen showing "Live" with primary color when online, and "Last Known" with a surface color when offline.
7. Add the `MarkerLayer` to the map using the location marker widget.

**Acceptance criteria:** On a physical device, the marker appears at the user's real GPS position. Moving the device updates the marker position. Switching to airplane mode causes the status chip to change to "Last Known" and the marker remains at the last valid position without any crash.

---

### Phase 4 — Route Planning and Rendering

**Goal:** The user can enter an origin and destination address, and the app draws a route polyline on the map connecting them.

**Deliverables:**

1. Create `route_state.dart` model with fields: `originLatLng`, `destinationLatLng`, `originAddress`, `destinationAddress`, `polylinePoints` (list of LatLng), `distanceMeters`, `durationSeconds`, `status` (enum: idle, loading, success, error).
2. Create `geocoding_service.dart`:
   - Wrap `locationFromAddress()` from the geocoding plugin.
   - Return a nullable `LatLng` and surface errors clearly.
3. Create `routing_service.dart`:
   - Build the OSRM URL from two `LatLng` inputs.
   - Call the API using Dart's `http` package.
   - Parse the JSON response, extract the geometry string.
   - Implement a polyline decoder function that converts the encoded string to a list of `LatLng` points.
   - Extract distance and duration from the response legs array.
4. Create `route_provider.dart` as a `StateNotifierProvider<RouteNotifier, RouteState>`:
   - Implement `setOrigin(String address)` — geocodes and stores origin.
   - Implement `setDestination(String address)` — geocodes, stores destination, and automatically triggers routing when both origin and destination are set.
   - Implement `fetchRoute()` — calls the routing service, updates state with polyline and trip summary.
   - Implement `clearRoute()` — resets state to idle.
5. Create `search_panel.dart`:
   - An animated panel that slides down from the top of the screen.
   - Two `TextField` widgets for origin and destination.
   - Each field calls the appropriate provider method on submission.
   - A clear button that resets route state.
6. Create `route_overlay.dart`:
   - A `PolylineLayer` that reads polyline points from route state.
   - Origin pin (secondary color) and destination pin (tertiary color) as `MarkerLayer` entries.
7. Create `route_info_card.dart`:
   - A bottom card that slides up when route state is `success`.
   - Displays formatted distance (km) and estimated duration (minutes).
   - Uses surface color with appropriate text colors from the theme.
8. Update `fab_cluster.dart` to include a route mode toggle button.
9. Update `map_view.dart` to fit the map camera to the route bounding box when a route is successfully loaded.

**Acceptance criteria:** User types two addresses, taps submit, and sees a blue polyline drawn on the map between the two points. The bottom card shows distance and time. Tapping clear removes the route and returns to idle mode.

---

### Phase 5 — Polish, Integration, and Demo Readiness

**Goal:** Unify all features, refine UI interactions, handle edge cases, and prepare the application for a demonstration.

**Deliverables:**

1. **Animation and transitions:**
   - Search panel slides down smoothly with an `AnimatedContainer` or `SlideTransition`.
   - Route info card slides up smoothly on route success.
   - Status chip fades between online and offline states.
   - FAB uses `AnimatedSwitcher` to swap icons between location and route mode.

2. **Edge case handling:**
   - Location permission permanently denied: show a dialog with a link to app settings using `Geolocator.openAppSettings()`.
   - Geocoding fails (unrecognized address): show a `SnackBar` with the error message.
   - OSRM routing fails (no route found, network error): update route status to error, show the error message in the route info card area.
   - Map tiles fail to load (no internet): flutter_map handles this gracefully with blank tiles; add a user-facing message if all tiles fail.

3. **UX refinements:**
   - When route mode is active, the current location FAB moves to a secondary position.
   - Long-press on the map places a destination pin directly (no geocoding needed for the pin, but reverse geocoding fills the destination field).
   - Route info card includes a "Use my location as origin" shortcut button.

4. **Theme validation:**
   - Audit every widget for hardcoded colors. Replace all instances with `Theme.of(context).colorScheme` references.
   - Test the app by changing the seed color in `app_theme.dart` and verifying all surfaces update correctly.

5. **Code cleanup:**
   - Add documentation comments to all public classes and methods.
   - Remove all debug print statements.
   - Verify all providers are correctly scoped and disposed.

6. **Demo preparation:**
   - Test on a physical Android device for authentic GPS behavior.
   - Prepare two test scenarios: current location tracking, and a fixed route between two well-known locations in your city.
   - Verify offline behavior by toggling airplane mode during the demo.

**Acceptance criteria:** The app runs without errors in both online and offline conditions. All animations are smooth (no jank). The theme changes by modifying a single value. The app is demonstrable to a non-technical audience in under two minutes.

---

## Part 6 — Dependency Reference

| Package | Version Range | Purpose |
|---|---|---|
| flutter_map | ^7.0.0 | OSM tile rendering, map widget |
| latlong2 | ^0.9.0 | LatLng type compatible with flutter_map |
| geolocator | ^12.0.0 | GPS stream, permission handling |
| geocoding | ^3.0.0 | Address to coordinate translation |
| flutter_riverpod | ^2.5.0 | State management framework |
| riverpod_annotation | ^2.3.0 | Code generation for providers (optional) |
| http | ^1.2.0 | OSRM API HTTP calls |
| shared_preferences | ^2.2.0 | Last known location cache |

All packages listed are free, open-source, and have no usage caps relevant to a demonstration project.

---

## Part 7 — Key Engineering Decisions Summarized

**Why a single screen:** The feature set does not require navigation. Multiple screens would add complexity (route management, state persistence across routes) without adding user value.

**Why StreamProvider for location:** GPS data is inherently a stream. Riverpod's `StreamProvider` maps this naturally, handles lifecycle automatically, and provides built-in loading and error states without additional boilerplate.

**Why OSRM over alternatives:** It is the only fully free, no-key-required routing API suitable for this use case. GraphHopper and Mapbox both require API keys. Valhalla is an alternative but has less documentation for Flutter integration.

**Why SharedPreferences for offline cache:** The offline requirement is simple — store one coordinate pair. A full local database (Hive, Isar, sqflite) would be over-engineered for this need.

**Why flutter_map over google_maps_flutter:** Google Maps Flutter requires a billing-enabled Google Cloud project. flutter_map with OSM tiles requires no credentials and no billing account.

---

## Part 8 — Scalability Notes

The architecture as designed supports the following future features without structural changes:

- **Search suggestions:** Add a provider that calls a nominatim (OSM geocoder) search endpoint and drives an autocomplete dropdown in the search panel.
- **Multiple waypoints:** Extend `RouteState` with a list of waypoints instead of a single origin-destination pair. OSRM supports multi-stop routing in the same endpoint.
- **Saved places:** Add a provider backed by a local database. The map view adds a new marker layer for saved places.
- **Map style switching:** `flutter_map` supports multiple tile layers. Adding a style picker means swapping the tile URL string in the map provider.
- **Turn-by-turn instructions:** OSRM returns step-by-step instructions in the same API response. Parse and store them in `RouteState`, then surface them in a new widget.

Each of these is additive. No existing file needs to be restructured.

---

*End of Blueprint*