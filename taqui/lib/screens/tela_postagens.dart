import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void _novapostagem(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CadastroPostagem()));
  }

  @override
  Widget build(BuildContext context) {


    List<int> posts = [for (var i = 1; i <= 23; i++) i]; // Resultados do DB
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
                            itemCount: posts.length,
                            itemBuilder: (BuildContext context, int index) {
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
                                            "Postagem ${posts[index]}",
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
                                          onPressed: () async {

                                            QuerySnapshot doc = await db.collection("postagens")
                                                .where("endereco.latitude", isEqualTo: -23.680298999999998).get();

                                            DocumentSnapshot dados = doc.docs[0];

                                            ObjetoPerdido objeto = ObjetoPerdido();
                                            Localizacao endereco = Localizacao();
                                            endereco.rua = dados["endereco"]["rua"];
                                            endereco.cep = dados["endereco"]["cep"];
                                            endereco.latitude = dados["endereco"]["latitude"];
                                            endereco.longitude = dados["endereco"]["longitude"];
                                            objeto.id = "7fsH5J5GNbt9xyTbc0Zh";
                                            objeto.endereco = endereco;
                                            objeto.descricao = dados["descricao"];
                                            objeto.usuario = dados["usuario"];
                                            objeto.status = dados["status"];
                                            objeto.imagem1 = dados["imagem1"] != "" ? dados["imagem1"] : null;
                                            objeto.imagem2 = dados["imagem2"] != "" ? dados["imagem2"] : null;
                                            objeto.imagem3 = dados["imagem3"] != "" ? dados["imagem3"] : null;

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
                              ),),)]))));}}