//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:taqui/screens/tela_objeto_detalhe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _tituloAppBar = 'Cadastro de Postagem';

class CadastroPostagem extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return CadastroPostagemState();
  }
}

class CadastroPostagemState extends State<CadastroPostagem> {
  GlobalKey<FormState> _key = new GlobalKey(); // chave
  bool _validate = false;

  String postagem = "";
  String localizacao = "";
  String desc = "";

  final picker = ImagePicker();
  File _imagem1 = null;
  File _imagem2 = null;
  File _imagem3 = null;

  List<File> _imagens = [];

  //função para acessar as mídias da galeria
  Future _pegarImgGaleria(int numeroImagem) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        switch(numeroImagem){
          case 1:
            this._imagem1 = File(pickedFile.path);
            break;
          case 2:
            this._imagem2 = File(pickedFile.path);
            break;
          case 3:
            this._imagem3 = File(pickedFile.path);
            break;
        }
      } else {
        print('No image selected.');
      }
    });
  }
  void _removeImage(int numeroImagem){
    setState(() {
      switch(numeroImagem){
        case 1:
          this._imagem1 = null;
          break;
        case 2:
          this._imagem2 = null;
          break;
        case 3:
          this._imagem3 = null;
          break;
      }
    });
  }

  criarPostagem() async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    String usuarioLogado = auth.currentUser.uid.toString();

    DocumentReference documento = db.collection("postagens")
        .doc(postagem);
    
    documento.set({
      "usuario" : usuarioLogado,
      "postagem" : postagem,
      "localizacao" : localizacao,
      "descricao" : desc,
      "imagem1" : _imagem1,
      "imagem2" : _imagem2,
      "imagem3" : _imagem3,
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // define um titulo pra tela
        title: Text(_tituloAppBar),
      ),
      body: Container( // inseri o container para delimitar o posicioamento dos widgets na tela
        padding: EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
          bottom: 20,
        ),
        color: Colors.white,
        child: Form(
          key: _key,
          child: _formPostagem(),
        ),
      ),
    );
    }

    Widget _formPostagem(){
      return ListView( // inseri um ListView para permitir scroll na tela
        children: <Widget>[
          TextFormField( // Bloco referente ao input da localização
            keyboardType: TextInputType.text,
            onSaved: (String val) {
              localizacao = val;
            },
            decoration: InputDecoration(
              labelText: "Localização",
              icon: Icon(Icons.zoom_in),
              labelStyle: TextStyle(
                color: Colors.black38,
                fontSize: 18.0,
              ),
            ),
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
              child: TextFormField( // Bloco referente ao input da postagem
                keyboardType: TextInputType.text,
                onSaved: (String val) {
                  postagem = val;
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 150),
                  labelText: "Nome da postagem",
                  labelStyle: TextStyle(
                    color: Colors.black38,
                    fontSize: 18.0,
                  ),
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              )
          ),

          Container(
              child: TextFormField( // Bloco referente ao input da descrição
                keyboardType: TextInputType.text,
                onSaved: (String val) {
                  desc = val;
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 150),
                  labelText: "Descrição do objeto...",
                  labelStyle: TextStyle(
                    color: Colors.black38,
                    fontSize: 18.0,
                  ),
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              )
          ),
          SizedBox(
            height: 5,
          ),

         // Adicionar container de imagens
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: this._imagem1 == null ?
                    GestureDetector(
                      onTap: (){
                        _pegarImgGaleria(1);
                      },
                      child: Icon(Icons.add, color: Colors.deepOrange),
                    )
                        : Stack(
                      children: <Widget>[
                        Container(
                          width: 180,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(this._imagem1),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 10,
                          child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                shape: BoxShape.circle,
                              ),
                              child: GestureDetector(
                                onTap: (){
                                  _removeImage(1);
                                },
                                child: Icon(Icons.delete_forever_outlined, color: Colors.white,),
                              )
                          ),
                        ),
                      ],
                    )
                ),
                Container(
                  //color: Colors.deepOrange,
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: this._imagem2 == null ?
                  GestureDetector(
                    onTap: (){
                      _pegarImgGaleria(2);
                    },
                    child: Icon(Icons.add, color: Colors.deepOrange),
                  )
                      : Stack(
                    children: <Widget>[
                      Container(
                        width: 180,
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(this._imagem2),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 10,
                        child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                            ),
                            child: GestureDetector(
                              onTap: (){
                                _removeImage(2);
                              },
                              child: Icon(Icons.delete_forever_outlined, color: Colors.white,),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  //color: Colors.deepOrange,
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: this._imagem3 == null ?
                  GestureDetector(
                    onTap: (){
                      _pegarImgGaleria(3);
                    },
                    child: Icon(Icons.add, color: Colors.deepOrange),
                  )
                      : Stack(
                    children: <Widget>[
                      Container(
                        width: 180,
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(this._imagem3),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 10,
                        child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                            ),
                            child: GestureDetector(
                              onTap: (){
                                _removeImage(3);
                              },
                              child: Icon(Icons.delete_forever_outlined, color: Colors.white,),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Container( // container que define o fundo do botão
            height: 50,
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.3,1],
                colors: [
                  Color(0xFFF58524), //decidir cores posteriormente
                  Color(0xFFF92B7F),
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: SizedBox.expand(
              child:TextButton(
                child: Container(
                  child:
                  Text('Cadastrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                onPressed: () {
                  criarPostagem();

                },
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.lightBlue,
                  side: BorderSide(color: Colors.grey, width: 2),
                ),)
            ),
          ),
        ],
      );
    }
}