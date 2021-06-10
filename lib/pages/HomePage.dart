import 'package:anglesensor/pages/LinesPage.dart';
import 'package:anglesensor/pages/MeasuringPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _googleMapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;

  late Position currentPostition;

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPostition = position;

    LatLng latLngPostition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPostition, zoom: 15);
    _googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance.collection('lines').snapshots().listen((event) {
      if (event.docs.length != markers.length) markers = <MarkerId, Marker>{};
      event.docChanges.forEach((element) {
        final lineTitle = element.doc.data()!['title'];
        final pillars = element.doc.data()!['pillars'];
        pillars.forEach((e) => _addMarkers(e, lineTitle));
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(53.34357, 83.67072),
              zoom: 14.0,
            ),
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            markers: Set<Marker>.of(markers.values),
            zoomControlsEnabled: false,
            compassEnabled: false,
            onMapCreated: (controller) => _googleMapController = controller,
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10, right: 10, top: 30),
              child: Row(
                children: [
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.all(Radius.circular(50)),
                  //   ),
                  //   child: IconButton(
                  //     onPressed: () {},
                  //     icon: Icon(Icons.menu_outlined),
                  //     iconSize: 26,
                  //   ),
                  // ),
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => LinesPage())),
                      icon: Icon(Icons.bar_chart_rounded),
                      iconSize: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: IconButton(
                onPressed: () => locatePosition(),
                icon: Icon(Icons.near_me),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MeasuringPage()));
        },
        icon: Icon(Icons.add, size: 26),
        label: Text(
          'Добавить новую линию',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _addMarkers(e, lineTitle) {
    final pillarId = e['id'].toString();
    final MarkerId markerId = MarkerId(lineTitle + pillarId);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(e['lat'], e['lng']),
      infoWindow: InfoWindow(
        title: '${lineTitle}(${e['id']})',
        snippet: 'x: ${e['x']}, y: ${e['y']}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(e['status'] == 'invalid'
          ? BitmapDescriptor.hueRed
          : BitmapDescriptor.hueGreen),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }
}
