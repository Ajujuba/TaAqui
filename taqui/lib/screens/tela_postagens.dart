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
import 'package:intl/intl.dart';

const _tituloAppBar = 'Minhas postagens';

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
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                  "Minhas postagens"
              ),
            ),
            Icon(Icons.folder_outlined, color: Colors.white)
          ],
        ),
        backgroundColor: Color.fromRGBO(249, 46, 123, 1),
      ),
      body: StreamBuilder(
        stream: db.collection('postagens').where("usuario", isEqualTo: usuarioLogado).snapshots(),
        builder: (context, dados) {
          switch (dados.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("Carregando suas postagens"),
                    CircularProgressIndicator()
                  ],
                ),
              );
            break;
            case ConnectionState.active:
            case ConnectionState.done:
            if (dados.hasError) {
              return Text("Erro ao carregar os dados!");
            } else{
              QuerySnapshot querySnapshot = dados.data;
              if(querySnapshot.docs.length == 0){
                return Center(
                  child: Text(
                    "Você ainda não tem postagens :( ",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey
                    ),
                  ),
                );
              }
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: ListView.separated(
                            itemCount: dados.data.docs.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 2,
                              color: Colors.grey,
                            ),
                            itemBuilder: (context, index) {
                              DocumentSnapshot data = dados.data.docs[index];
                              var date = DateTime.fromMicrosecondsSinceEpoch(data["dataPostagem"].microsecondsSinceEpoch);
                              return ListTile(
                                onTap: () {
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
                                },
                                title: Text(
                                  data["descricao"],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFFF92B7F)

                                  ),
                                ),
                                subtitle: Text(
                                    DateFormat('dd/MM/yyyy hh:MM:ss').format(date),
                                  style: TextStyle(
                                     // color: Color(0xFFF92B7F)
                                  ),
                                ),
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
                      child:
                      TextButton(
                          child: Container(
                            child:
                            Text('Criar nova postagem',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          onPressed: () { _novapostagem(context); }
                      ),

                    )
                  ],
                ),
              );
            }
          }
        }
      ),
    );
  }
}