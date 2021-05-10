import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taqui/screens/tela_visualizar_postagem.dart';

class MapaPostagens extends StatefulWidget {
  @override
  _MapaPostagensState createState() => _MapaPostagensState();
}

class _MapaPostagensState extends State<MapaPostagens> {

  Set<Marker> _marcadores ={};

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
      target: LatLng(-23.5639999, -46.653256),
      zoom: 19
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
            zoom: 18.5,
            tilt: 30
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

  //.where("endereco.latitude", isEqualTo: -23.680072998476323).get();

  _recuperaPostagem() async {
    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    var maxLat = (position.latitude + 0.003500);
    var minLat = (position.latitude - 0.003500);
    var minLon = (position.longitude - 0.003500);
    var maxLon = (position.longitude + 0.003500);
    var cont = 0;
    Set<Marker> local = {};
    print("startou");
    FirebaseFirestore.instance
      .collection('postagens')
      .where("endereco.latitude", isGreaterThan: minLat)
      .where("endereco.latitude", isLessThanOrEqualTo: maxLat)
      .get()
      .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          cont++;
          var long = (doc["endereco.longitude"]);
          var lat = (doc["endereco.latitude"]);
          if (long >= minLon && long <= maxLon){
            print(doc["descricao"]);
            Marker marker = Marker(
              markerId: MarkerId(cont.toString()),
              position: LatLng(lat,long),
              infoWindow: InfoWindow(
                title: doc.id,
                onTap: () {
                  print("Infowindow clicada");
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VisualizarPostagem(doc.id))
                  );
                }
              ),
              onTap: (){
                print("Marker clicado");
              }
            );
            local.add(marker);
          }
        });
        setState(() {
          _marcadores = local;
        });
      });
  }


  @override
  void initState() {
    super.initState();
    _recuperarUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();
    _recuperaPostagem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
        backgroundColor: Color.fromRGBO(246, 120, 46, 1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: _recuperaPostagem,
      ),
      body: Container(
        child: GoogleMap(
          //markers: _marcadores,
          mapType: MapType.normal,
          initialCameraPosition: _posicaoCamera,
          onMapCreated: _onMapCreated,
          markers: _marcadores,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          //onLongPress: _adicionarMarcador,
        ),
      ),
    );
  }
}
