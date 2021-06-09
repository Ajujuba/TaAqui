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
    //->
    _recuperaPostagem();
  }


  //.where("endereco.latitude", isEqualTo: -23.680072998476323).get();

  _recuperaPostagem() async {
    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    var maxLat = (position.latitude + 0.003500);
    var minLat = (position.latitude - 0.003500);
    var minLon = (position.longitude - 0.003500);
    var maxLon = (position.longitude + 0.003500);
    var cont = 0;
    var rangecont = 0.000030;

    String type = "X";
    Set<Marker> local = {};
    print("startou");
    FirebaseFirestore.instance
      .collection('postagens')
      .where("endereco.latitude", isGreaterThan: minLat)
      .where("endereco.latitude", isLessThanOrEqualTo: maxLat)
      .get()
      .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          if (doc["status"] != "ENCONTRADO") {
            cont++;

            String title = (doc["descricao"]);
            int tam = title.length;
            if (tam < 13) {
              for(int c = tam; c < 18; c++){
                title = title + " ";
              }
            }else{
              title = title.substring(0,15);
              title = ("$title...");
            }

            var long = (doc["endereco.longitude"]);
            var lat = (doc["endereco.latitude"]);

            if (long >= minLon && long <= maxLon){
              if (type == "X"){
                long = (doc["endereco.longitude"]);
                lat = (doc["endereco.latitude"]);
                type = "A";
              }else if (type == "A"){
                long = (doc["endereco.longitude"] + rangecont );
                lat = (doc["endereco.latitude"]);
                type = "B";
              }else if (type == "B"){
                long = (doc["endereco.longitude"]);
                lat = (doc["endereco.latitude"] + rangecont );
                type = "C";
              }else if (type == "C"){
                long = (doc["endereco.longitude"] - rangecont );
                lat = (doc["endereco.latitude"]);
                type = "D";
              }else if (type == "D"){
                long = (doc["endereco.longitude"]);
                lat = (doc["endereco.latitude"] - rangecont );
                type = "E";
              }else if (type == "E"){
                long = (doc["endereco.longitude"] + rangecont/2);
                lat = (doc["endereco.latitude"] + rangecont/2);
                type = "F";
              }else if (type == "F") {
                long = (doc["endereco.longitude"] + rangecont/2);
                lat = (doc["endereco.latitude"] - rangecont/2);
                type = "G";
              }else if (type == "G") {
                long = (doc["endereco.longitude"] - rangecont/2);
                lat = (doc["endereco.latitude"] + rangecont/2);
                type = "H";
              }else if (type == "H") {
                long = (doc["endereco.longitude"] - rangecont/2);
                lat = (doc["endereco.latitude"] - rangecont/2);
                type = "A";
                rangecont = rangecont + 0.000030;
              }
              print(doc["descricao"]);
              Marker marker = Marker(
                  markerId: MarkerId(cont.toString()),
                  position: LatLng(lat,long),
                  infoWindow: InfoWindow(
                      title: title,
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
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                  "Mapa"
              ),
            ),
            Icon(Icons.map_outlined, color: Colors.white)
          ],
        ),
        backgroundColor: Color.fromRGBO(246, 120, 46, 1),
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
