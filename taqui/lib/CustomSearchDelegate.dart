import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CustomSearchDelegate extends SearchDelegate<String>{
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: (){
            query = "";
          }
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return
      IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            close(context, "");
          }
      );
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return Container();
  }

  Future<List<Placemark>> _recuperar(String endereco) async {
    List<Placemark> _listaEnderecos = [];
    _listaEnderecos = await Geolocator()
        .placemarkFromAddress(endereco);

    //_listaEnderecos = _listaEnderecos.where((texto) => endereco.toLowerCase().startsWith(texto.thoroughfare.toLowerCase())).toList();

    for(Placemark endereco in _listaEnderecos){
      print(endereco.postalCode + " " + endereco.thoroughfare + " " + endereco.position.latitude.toString() + " " + endereco.position.longitude.toString());
    }

    return _listaEnderecos;
  }

  @override
  Widget buildSuggestions(BuildContext context)  {
    List<Placemark> _listaEnderecos = [];
    if(query.isNotEmpty){
      return FutureBuilder<List<Placemark>>(
          future: _recuperar(query),
          builder: (context, snapshot){
            switch(snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.active:
              case ConnectionState.done:
                if(snapshot.hasData){
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index){
                        _listaEnderecos = snapshot.data;
                        Placemark endereco = _listaEnderecos[index];
                        return ListTile(
                          onTap: (){
                            Map<String, dynamic> map = Map();
                            map["rua"] = endereco.thoroughfare;
                            map["bairro"] = endereco.subLocality;
                            map["cep"] = endereco.postalCode;
                            map["latitude"] = endereco.position.latitude.toString();
                            map["longitude"] = endereco.position.longitude.toString();
                            var a = jsonEncode(map);
                            close(context, a);
                          },
                          title: Text(endereco.thoroughfare + " - " + endereco.subLocality),
                          subtitle: Text(endereco.postalCode + " - " + " " + endereco.subAdministrativeArea + ", " + endereco.administrativeArea),
                        );
                      }
                  );
                } else {
                  return Center(
                    child: Text("Nenhum dado a ser exibido"),
                  );
                }
                break;
            }
          }
      );

    } else {
      return Center(
        child: Text("Nenhuma localização para a pesquisa"),
      );
    }
  }

}