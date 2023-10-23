import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_fluttter/repo/repos_maps.dart' as mapsRepo;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> _markers = <Marker>{};
  
  Map<PolylineId, Polyline> Polylines = {};
  List<LatLng> polylineCoodinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyCN4MAbenq2HNxGOyLVGtXbeTrTz90ytVA";
  LatLng destination = LatLng(11.576298, 104.870875);
  _getPolyine()async{
    Position pos = await mapsRepo.getCurrentPosition();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey, 
      PointLatLng(pos.latitude, pos.longitude),
      PointLatLng(mapsRepo.myPoLatLng[0].latitude, mapsRepo.myPoLatLng[0].longitude),
      travelMode: TravelMode.driving
      );
      if(result.points.isEmpty)
      {
        result.points.forEach((PointLatLng points) {
          polylineCoodinates.add(LatLng(points.latitude,points.longitude));
        });
      }
     _addPolyLine(); 
  }

  _addPolyLine (){
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id, color: Colors.red, points: polylineCoodinates);
    Polylines[id] = polyline;
    setState(() {
      
    });
  }

  Future<Set<Marker>> _initMarkers ()async{
    final Uint8List byteIcon = await mapsRepo.getbyteFromAsset('asset/images.png',100);
    final icon = BitmapDescriptor.fromBytes(byteIcon);
    List<Marker> markers  = <Marker>[];
    for (final location in mapsRepo.myPoLatLng ){
      print("${location.latitude}, ${location.longitude}");
      final marker = Marker(
        markerId: MarkerId(location.toString()),
        infoWindow: InfoWindow(
          title:"some company", snippet: "some Company branch",
          onTap: ()=> print("tapped ${location.latitude}, ${location.longitude}") 
          ),
          position: location, icon: icon,
      );
      markers.add(marker);
    }
    return markers.toSet();
  }
@override
void initState(){
  super.initState();
  _initMarkers().then((marker){
    setState((){
      _markers = marker;
    });
  });
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Page"),
        actions: [
          IconButton(
            onPressed: ()async{
              _getPolyine();
            },
             icon: Icon(Icons.map))
        ],
      ),
      body: _buildbody,
      floatingActionButton: _buildCurrentLocationButton(),
      //floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // final bool _cameraLoading = false;
  // get _buildFloating {
  //   return IgnorePointer(
  //     ignoring: _cameraLoading,
  //     child: FloatingActionButton(
  //       child: _cameraLoading
  //       ? const Center(child: CircularProgressIndicator(),)
  //       :const Icon(Icons.person_pin),
  //       onPressed: () async{
  //       final controller = await _completer.future;
  //       mapsRepo.getCurrentCameraPosition().then((cameraPos){
  //         controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
  //       } );
  //     },
  //       ),
        
  //   );
  // }

  final Completer<GoogleMapController> _completer = Completer();
  get _buildbody{
    return Container(
      alignment: Alignment.center,
      child: _buildmap,
    );
  }

  get _buildmap{
    return GoogleMap(
      mapType: MapType.normal,
      markers: _markers,
      polylines: Set<Polyline>.of(Polylines.values),
      initialCameraPosition:
      const CameraPosition(target: LatLng(11.5734025, 104.9196285), zoom: 16.5),
      onMapCreated:(controller){
        _completer.complete(controller);
      }, 
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      );
  }

  bool _cameraLoading = false;
  _buildCurrentLocationButton(){
     return IgnorePointer(
      ignoring: _cameraLoading,
      child: FloatingActionButton(
        child: _cameraLoading
        ? const Icon(Icons.refresh)
        :const Icon(Icons.person_pin),
        onPressed: () async{
          setState(() => _cameraLoading = true);
        final controller = await _completer.future;
        mapsRepo.getCurrentCameraPosition().then((cameraPos){
          if(CameraPosition != null){
          controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
          setState(() => _cameraLoading = false);
          }
        } );
      },
        ),
        
    );
  }

}
