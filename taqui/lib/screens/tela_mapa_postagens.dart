import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapaPostagens extends StatefulWidget {
  @override
  _MapaPostagensState createState() => _MapaPostagensState();
}

class _MapaPostagensState extends State<MapaPostagens> {

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
      target: LatLng(-23.5639999, -46.653256),
      zoom: 16
  );

  _onMapCreated(GoogleMapController controller){
    _controller.complete(controller);
  }

  _adicionarListenerLocalizacao(){
    var geolocator = Geolocator();
    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    );
    geolocator.getPositionStream(locationOptions).listen((Position position) {
      _posicaoCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19
      );
      _movimentarCamera(_posicaoCamera);
    });
  }

  _recuperarUltimaLocalizacaoConhecida() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      if(position != null){
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 19
        );
        _movimentarCamera(_posicaoCamera);
      }
    });
  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
          cameraPosition
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _recuperarUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();
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
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          //onLongPress: _adicionarMarcador,
          //myLocationButtonEnabled: true,
        ),
      ),
    );
  }
}
