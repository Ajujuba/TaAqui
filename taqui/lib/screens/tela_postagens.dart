import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taqui/models/Localizacao.dart';
import 'package:taqui/models/ObjetoPerdido.dart';
import 'package:taqui/screens/form_cadastro_postagem.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:taqui/screens/tela_objeto_detalhe.dart';


const _tituloAppBar = 'Postagens do Usuario';

class PostagensUsuario extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return PostagensUsuarioState();
  }
}

class PostagensUsuarioState extends State<PostagensUsuario> {
  final laranja = Colors.deepOrange;
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  void _novapostagem(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CadastroPostagem()));
  }

  @override
  Widget build(BuildContext context) {
    var usuarioLogado = auth.currentUser.email.toString();
    return Scaffold(
      appBar: AppBar( // define um titulo pra tela
        title: Text(_tituloAppBar),
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: db.collection('postagens').where("usuario", isEqualTo: usuarioLogado).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> dados) =>
        dados.connectionState == ConnectionState.none
        ? Center(child: CircularProgressIndicator(),)
        : Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Minhas postagens',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline4,
                ),
              ),
              Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: ListView.builder(
                      itemCount: dados.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot data = dados.data.docs[index];
                        return Column(
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
                              child:ElevatedButton.icon(
                                  icon: Text(
                                    "Postagem ${index+1}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  label: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                  onPressed: ()  {



                                    ObjetoPerdido objeto = ObjetoPerdido();
                                    Localizacao endereco = Localizacao();
                                    endereco.rua = data["endereco"]["rua"];
                                    endereco.cep = data["endereco"]["cep"];
                                    endereco.latitude = data["endereco"]["latitude"];
                                    endereco.longitude = data["endereco"]["longitude"];
                                    objeto.id = dados.data.docs[index].id;
                                    objeto.endereco = endereco;
                                    objeto.descricao = data["descricao"];
                                    objeto.usuario = data["usuario"];
                                    objeto.status = data["status"];
                                    objeto.imagem1 = data["imagem1"] != "" ? data["imagem1"] : null;
                                    objeto.imagem2 = data["imagem2"] != "" ? data["imagem2"] : null;
                                    objeto.imagem3 = data["imagem3"] != "" ? data["imagem3"] : null;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ObjetoDetalhe(objeto))
                                    );
                                  }
                              ),
                            ),
                          ),
                          SizedBox(height: 10)
                        ]
                      );
                      },
                    ),
                  )
              ),
              Container(
                height: 50.0,
                width: 300.0,
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: laranja,
                    borderRadius: BorderRadius.all(Radius.circular(15))
                ),
                child:
                TextButton(
                  child: Container(
                    child:
                    Text('Criar nova postagem',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  onPressed: () { _novapostagem(context); },
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.lightBlue,
                    side: BorderSide(color: Colors.grey, width: 2),
                  ),
                ),
              )
            ],
          ),
        )

      ),
    );
  }
}