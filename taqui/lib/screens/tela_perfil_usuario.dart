import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';


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
      if(pickedFile != null){
        imagem = File(pickedFile.path);
        print('Image Path $imagem');
      }
    });
  }

  //função para acessar a camera do celular
  Future pegarImgCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if(pickedFile != null){
        imagem = File(pickedFile.path);
        print('Image Path $imagem');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // define um titulo pra tela
        title: Text(_tituloAppBar),
        elevation: 0,
      ),
      body: Builder(
        builder: (context) =>  Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container( // define o retangulo laranja onde a foto vai aparecer
                width: MediaQuery.of(context).size.width,
                height: 220,
                decoration: BoxDecoration( // define que a cor é laranja
                  color: laranja,
                  borderRadius: BorderRadius.only( // define bordas inferiores arredondadas
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                    children: <Widget>[
                      Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 60.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.image,
                                size: 30.0,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                pegarImgGaleria();
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: new SizedBox(
                                  width: 180.0,
                                  height: 180.0,
                                  child: (imagem!=null)?Image.file(
                                    imagem,
                                    fit: BoxFit.fill,
                                  ):Image.network(
                                    "https://images.unsplash.com/photo-1502164980785-f8aa41d53611?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 60.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                size: 30.0,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                pegarImgCamera();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),

                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

  }

}