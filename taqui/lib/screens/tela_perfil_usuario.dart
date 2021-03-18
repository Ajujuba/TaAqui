import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';


const _tituloAppBar = 'Perfil do usuário';

class PerfilUsuario extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return PerfilUsuarioState();
  }
}

class PerfilUsuarioState extends State<PerfilUsuario> {
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
        print('Image Path $imagem');
      }
    });
  }

  //função para acessar a camera do celular
  Future pegarImgCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        imagem = File(pickedFile.path);
        print('Image Path $imagem');
      }
    });
  }

  //função para acessar o Storage e salvar a foto de perfil
  Future salvarFoto(BuildContext context) async {
    String fileName = basename(
        imagem.path); //pegando apenas o nome da img e não o caminho inteiro
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        fileName); //obtem referencia ao nome do arquivo
    StorageUploadTask uploadTask = firebaseStorageRef.child("fotos_perfil/")
        .putFile(imagem); // inserindo o arquivo no firebase
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      print("Foto de perfil atualizada");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto de perfil atualizada')));
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
        builder: (context) =>
            Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container( // define o retangulo laranja onde a foto vai aparecer
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: 270,
                      decoration: BoxDecoration( // define que a cor é laranja
                        color: laranja,
                        borderRadius: BorderRadius
                            .only( // define bordas inferiores arredondadas
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row( // linha onde estão os elementos do container
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding( // define icone e função da galeria
                                padding: EdgeInsets.only(top: 120.0),
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
                              Align( // posicionamento/layout da img de perfil
                                alignment: Alignment.center,
                                child: CircleAvatar( // define a borda da img
                                  radius: 100,
                                  backgroundColor: Colors.white,
                                  child: ClipOval( // define onde a img aparece
                                    child: new SizedBox( //define o tamanho da img
                                      width: 180.0,
                                      height: 180.0,
                                      child: (imagem != null) ? Image
                                          .file( //se a pessoa escolher um arquivo
                                        imagem,
                                        //o arquivo será exibido no perfil
                                        fit: BoxFit.fill,
                                      ) : Image.network(
                                        "https://images.unsplash.com/photo-1502164980785-f8aa41d53611?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                                        fit: BoxFit
                                            .fill, //senao, uma img default irá ser exibida
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding( // define icone e função  da camera
                                padding: EdgeInsets.only(top: 120.0),
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
                            height: 10.0,
                          ),
                          Row( //botão pra salvar a foto de perfil
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                color: Colors.white,
                                onPressed: () {
                                  salvarFoto(context);
                                },
                                elevation: 0.0,
                                splashColor: Colors.deepOrange[100],
                                child: Text(
                                  'Salvar Foto',
                                  style: TextStyle(
                                      color: laranja, fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row( //definindo os dados do perfil
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row( // nome do user
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Align( // título
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Nome',
                                          style: TextStyle(
                                              color: laranja,
                                              fontSize: 18.0)),
                                    ),
                                    Align( // conteúdo
                                      alignment: Alignment.centerLeft,
                                      child: Text('Nome do user',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align( // ícone que vai chamar a tela pra editar
                              alignment: Alignment.centerRight,
                              child: Container(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: laranja,
                                    size: 30,
                                  ),
                                  //onPressed: PREENCHER ,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row( //numero do celular do user
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Align( //título
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Celular do user',
                                          style: TextStyle(
                                              color: laranja,
                                              fontSize: 18.0)),
                                    ),
                                    Align( // conteudo
                                      alignment: Alignment.centerLeft,
                                      child: Text('11 99999-9999',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align( // ícone que vai chamar a tela pra editar
                              alignment: Alignment.centerRight,
                              child: Container(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: laranja,
                                    size: 30,
                                  ),
                                  //onPressed: PREENCHER ,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row( // email do user
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Align( //título
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Email do user',
                                          style: TextStyle(
                                              color: laranja,
                                              fontSize: 18.0)),
                                    ),
                                    Align(// conteudo
                                      alignment: Alignment.centerLeft,
                                      child: Text('email@user.com',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align( // ícone que vai chamar a tela pra editar
                              alignment: Alignment.centerRight,
                              child: Container(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: laranja,
                                    size: 30,
                                  ),
                                  //onPressed: PREENCHER ,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]
              ),
            ),
      ),
    );
  }
}