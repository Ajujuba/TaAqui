import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPostagens extends StatefulWidget {
  @override
  _MapaPostagensState createState() => _MapaPostagensState();
}

class _MapaPostagensState extends State<MapaPostagens> {

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
      target: LatLng(-23.5639999, -46.653256),
      zoom: 18
  );

  _onMapCreated(GoogleMapController controller){
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa")
      ),
      body: Container(
        child: GoogleMap(
          //markers: _marcadores,
          mapType: MapType.normal,
          initialCameraPosition: _posicaoCamera,
          onMapCreated: _onMapCreated,
          //onLongPress: _adicionarMarcador,
          //myLocationButtonEnabled: true,
        ),
      ),
    );
  }
}
