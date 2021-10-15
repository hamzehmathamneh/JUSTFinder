// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gmaps/directions_model.dart';
import 'package:flutter_gmaps/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:group_button/group_button.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/* import 'package:google_directions_api/google_directions_api.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:getwidget/getwidget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
 */
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 8,
      navigateAfterSeconds: new MapScreen(),
      title: new Text(
        'تطوير الطالب حمزة عثامنة \n -قسم هندسة البرمجيات',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: new TextStyle(
            height: 1.7,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            fontFamily: 'Tajawal'),
      ),
      image: new Image.asset('assets/IET.png'),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 160.0,
      onClick: () => print("Flutter Egypt"),
      loaderColor: Colors.red,
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(32.49521523038226, 35.991118397321735),
    zoom: 16.0,
  );

  static const zoomedOutPosition = CameraPosition(
    target: LatLng(32.49521523038226, 35.991118397321735),
    zoom: 13.0,
  );

  String _mapStyle;
  GoogleMapController _googleMapController;
  Marker _origin;
  Marker _destination;
  Marker _currentLocationMarker;
  Directions _info;
  LatLng _initialcameraposition2 = LatLng(32.49530654250149, 35.99137100884432);
  Set<Marker> _markers = Set();
  List<GlobalKey> _markerIconKeys = List();
  Set<String> renderedMarkers = Set();
  int SelectedIndex = -1;
  ScrollController _scrollController;
  PanelController _slidingPanelCotnroller = new PanelController();
  var endTimeOfDay;
  String DirectionTo;

  List<String> selectedSectionText = [
    "A1",
    "A2",
    "A3",
    "A4",
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
  ];

  switchIndexCases() {
    switch (SelectedIndex) {
      case 0:
        {
          _addMarker(LatLng(32.493459850851764, 35.98918775985838));
        }
        break;
      case 1:
        {
          _addMarker(LatLng(32.49330919038912, 35.98767584108872));
        }
        break;
    }
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  Location _location = Location();

  void _onMapCreated(GoogleMapController _cntlr) async {
    _googleMapController = _cntlr;

    _googleMapController.animateCamera(
      // CameraUpdate.newLatLngZoom(_initialcameraposition2, 15.0),
      CameraUpdate.newCameraPosition(_initialCameraPosition),
    );

    _googleMapController.setMapStyle(_mapStyle);

    _location.onLocationChanged.listen((l) {
      _currentLocationMarker = Marker(
        markerId: const MarkerId('current'),
        infoWindow: const InfoWindow(title: 'current'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: LatLng(l.latitude, l.longitude),
      );
    });
  }

  Future<void> GetDirection1() async {
    // Get directions
    final directions = await DirectionsRepository().getDirections(
      origin: _currentLocationMarker.position,
      destination: LatLng(32.497428113723785, 35.98958418567603),
    );
    setState(() => _info = directions);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((_string) {
      _mapStyle = _string;
    });
  }

  ReturnDirectionTo() {
    if (SelectedIndex == -1) {
      return "يرجى تحديد القسِم\ الوجهه";
    } else {
      return "تم تحديد الوجهة ${selectedSectionText[SelectedIndex]}";
    }
  }

  addMinutes(var minutes) {
    var timeNow = new DateTime.now();
    return timeNow.add(new Duration(minutes: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        backgroundColor: Colors.grey[850],
        centerTitle: false,
        title: const Text('JUST Finder'),
      ), */
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    zoomGesturesEnabled: true,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    buildingsEnabled: true,
                    compassEnabled: true,
                    indoorViewEnabled: true,
                    initialCameraPosition:
                        CameraPosition(target: _initialcameraposition2),
                    onMapCreated: _onMapCreated,
                    markers: {
                      if (_origin != null) _origin,
                      if (_destination != null) _destination
                    },
                    polylines: {
                      if (_info != null)
                        Polyline(
                          polylineId: const PolylineId('overview_polyline'),
                          color: Colors.red,
                          width: 5,
                          points: _info.polylinePoints
                              .map((e) => LatLng(e.latitude, e.longitude))
                              .toList(),
                        ),
                    },
                    // onLongPress: _addMarker,
                  ),
                  if (_info != null)
                    Positioned(
                      top: 20.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            )
                          ],
                        ),
                        child: Text(
                          // '${_info.totalDistance},الوصول بعد ${_info.totalDuration}',
                          'الوصول إلى ${selectedSectionText[SelectedIndex]} بعد ${_info.totalDuration}',
                          softWrap: true,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SlidingUpPanel(
              maxHeight: MediaQuery.of(context).size.height / 1.8,
              controller: _slidingPanelCotnroller,
              collapsed: Container(
                color: Colors.blue,
                child: Center(
                  child: Text(
                    "اسحب للأعلى لاختيار الوجهه",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Tajawal",
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              panel: Container(
                decoration: BoxDecoration(
                    color: Color(0xFFF2F1F0),
                    border: Border.all(color: Colors.blue, width: 3.0)),
                width: double.infinity,
                height: 300.0,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        child: Card(
                          margin: EdgeInsets.all(25.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Center(
                            child: Text(
                              SelectedIndex == -1
                                  ? "يرجى تحديد القسِم\ الوجهه"
                                  : "تم تحديد الوجهة ${selectedSectionText[SelectedIndex]}",
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: "Tajawal",
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          child: Container(
                            child: Column(
                              children: [
                                GroupButton(
                                  isRadio: true,
                                  spacing: 10,
                                  selectedButton: SelectedIndex,
                                  onSelected: (index, isSelected) {
                                    setState(() async {
                                      _slidingPanelCotnroller.close();

                                      await Future.delayed(
                                          Duration(seconds: 1));

                                      SelectedIndex = index;
                                      switchIndexCases();
                                    });
                                  },
                                  buttons: selectedSectionText,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: Center(
                child: Text("This is the Widget behind the sliding panel"),
              ),
            ),
          ],
        ),
      ),
      /*   floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          _info != null
              ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
              : CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ), */
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartDocked,
    );
  }

  void _addMarker(LatLng pos) async {
    // Get directions
    final directions = await DirectionsRepository().getDirections(
      origin: _currentLocationMarker.position,
      destination: pos,
    );

    // Origin is already set
    // Set destination
    setState(() {
      _info = directions;

      /*  _googleMapController.animateCamera(
        _info != null
            ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
            : CameraUpdate.newCameraPosition(zoomedOutPosition),
      ); */

      _destination = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarker,
        position: pos,
      );

      _googleMapController.animateCamera(
        _info != null
            ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
            : CameraUpdate.newCameraPosition(_initialCameraPosition),
      );
    });
  }
}
