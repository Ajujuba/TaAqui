import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                                    Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                    ConstrainedBox(constraints: BoxConstraints.tightFor(width: 250, height: 40),
                                      child: ElevatedButton.icon(
                                          onPressed: () {
                                            ObjetoPerdido objeto = ObjetoPerdido(); //ObjetoPerdido.con("Endereço da Postagem ${posts[index]}", "Descrição da Postagem ${posts[index]}");
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => ObjetoDetalhe(objeto))
                                            );
                                          },
                                          icon: Text('Postagem ${posts[index]}',
                                              style: TextStyle(color: Colors.black)
                                          ),
                                          label: Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                          )
                                      ),
                                    ),
                                  ],
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