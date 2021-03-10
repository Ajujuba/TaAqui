import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const _tituloAppBar = 'Perfil do usuário';

class PerfilUsuario extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return PerfilUsuarioState();
  }
}

class PerfilUsuarioState extends State<PerfilUsuario>{
  final laranja = Colors.deepOrange;
  
  //variáveis para manipular img
  File imagem;
  final picker = ImagePicker();
  
  //função para acessar as mídias da galeria
  Future pegarImgGaleria() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imagem = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  //função para acessar a camera do celular
  Future pegarImgCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
         return imagem = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppBar),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            decoration: BoxDecoration(
              color: laranja,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10
                  ),
                  child: Text("Edite aqui sua foto de perfil",
                    style: TextStyle(
                        color: Colors.white70
                    ),
                  ),
                ),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.camera_alt, color: Colors.white,),
                            onPressed: pegarImgCamera,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20,),
                      width: 180,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: imagem == null
                          ? Text('No image selected.')
                          : Image.file(imagem, width: 180, height: 150,),
                    ),
                    Padding(
                      padding:  const EdgeInsets.only(right: 20,  top: 20,),
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.image,  color: Colors.white,),
                            onPressed: pegarImgGaleria,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height/3,
            padding: EdgeInsets.only(top: 40, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Icon(Icons.person_pin, color: laranja, size: 35,),
                        Text('Editar dados pessoais',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: laranja,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Icon(Icons.highlight_off, color: laranja, size: 35,),
                        Text('Sair',
                          style: TextStyle(
                              color: laranja,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}