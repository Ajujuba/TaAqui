import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taqui/screens/form_cadastro_postagem.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';


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
                        child: ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 50.0,
                              margin: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                  color: laranja,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15))
                              ),
                              child: TextButton(
                                child: Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Postagem ${posts[index]}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(Icons.edit),
                                    )
                                  ],
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Botão ${posts[index]} pressionado! "),
                                      ));
                                },
                              ),
                            );
                          },
                        ),
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