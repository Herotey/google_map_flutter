

// ignore_for_file: unnecessary_null_comparison

import 'dart:ui'as ui;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double Zoom = 16.5;

Future<Position> getCurrentPosition()async{
  final permissions = await Geolocator.checkPermission();
  if (permissions == LocationPermission.always || 
  permissions == LocationPermission.whileInUse){
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
  }else{
    final request = await Geolocator.requestPermission();
    if(request == LocationPermission.always || 
    request== LocationPermission.whileInUse){
      return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
    }else {
      throw Exception("Access to location permissions was denied.");
    }
  }

}

Future<CameraPosition> getCurrentCameraPosition()async{
  Position? currentPos = await getCurrentPosition();
  if (currentPos != null){
    return CameraPosition(
      target:LatLng(currentPos.latitude, currentPos.longitude),
      zoom: Zoom, 
    );
  }else{
    throw Exception('Error current location because Google Maps Permission was denied.');
  }
}

Future<Uint8List> getbyteFromAsset(String path, int width) async{
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
  targetWidth: width);
  ui.FrameInfo info = await codec.getNextFrame();
  return (await info.image.toByteData(format: ui.ImageByteFormat.png))!
  .buffer
  .asUint8List();

}
List<LatLng> myPoLatLng = [
 const LatLng(11.5835259, 104.89811097),
  const LatLng(11.5839396,104.8917697)
];