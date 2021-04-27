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

  final laranja = Colors.deepOrange;
  final picker = ImagePicker();

  bool _network1 = false;
  bool _network2 = false;
  bool _network3 = false;

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
      return Expanded(
          child: Container(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              readOnly: false,
                              onTap: () { },
                              keyboardType: TextInputType.text,
                              //controller: _controllerLocalizacao,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Localização",
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              ),
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: laranja,
                                    size: 35,
                                  ),
                                  onPressed: (){ }
                              )
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              readOnly: false,
                              maxLines: 6,
                              keyboardType: TextInputType.text,
                              //controller: _controllerDescricao,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Descrição",
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              ),
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                        image: this._network1 ? NetworkImage(this._imagem1.path) : FileImage(this._imagem1),
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
                                      image: this._network2 ? NetworkImage(this._imagem2.path) : FileImage(this._imagem2),
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
                                      image: this._network3 ? NetworkImage(this._imagem3.path) : FileImage(this._imagem3),
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
                      height: 20,
                    ),
                    Column(
                      children: [
                        Container(
                          height: 40,
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.3,1],
                              colors: [
                                Color(0xFFF58524),
                                Color(0xFFF92B7F),
                              ],
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: SizedBox.expand(
                            child:FlatButton(
                                child: Text(
                                  "Cadastrar postagem!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () { }
                            ),
                          ),
                        ),
                        
                      ],
                    )
                  ],
                ),
              )
          )
      );
    }
}