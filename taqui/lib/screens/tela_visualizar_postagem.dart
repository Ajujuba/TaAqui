import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:taqui/models/Localizacao.dart';
import 'package:taqui/models/Usuario.dart';
import 'package:taqui/screens/tela_mensagens.dart';

const _tituloAppBar = 'Detalhes da Postagem';

class VisualizarPostagem extends StatefulWidget {

  String postagem;

  VisualizarPostagem(this.postagem);

  @override
  State<StatefulWidget> createState() {
    return VisualizarPostagemState();
  }
}

class VisualizarPostagemState extends State<VisualizarPostagem> {
  Localizacao _endereco = Localizacao();
  TextEditingController _controllerDescricao = TextEditingController();
  TextEditingController _controllerLocalizacao = TextEditingController();
  String imagem1;
  String imagem2;
  String imagem3;
  String _urlFotoPerfil;
  String userPostagem;
  String nomeUserPostagem;
  String idPostagem;

  _recuperarDadosPostagem() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await db.collection("postagens")
        .doc(idPostagem)
        .get();

    Map<String, dynamic> dados = snapshot.data();
     setState(() {
       _controllerDescricao.text = dados["descricao"];
       _controllerLocalizacao.text = dados["endereco"]["rua"];
       imagem1 = dados["imagem1"];
       imagem2 = dados["imagem2"];
       imagem3 = dados["imagem3"];
       userPostagem = dados["usuario"];
     });
      print(dados["usuario"]);
      recuperarUrlFotoPerfil(userPostagem);
  }

  Future<void> recuperarUrlFotoPerfil(userPostagem) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios")
        .doc(userPostagem)
        .get();

    Map<String, dynamic> dados = snapshot.data();
    setState(() {
      _urlFotoPerfil = dados["foto_perfil"];
      nomeUserPostagem = dados["nome"];
    });
    print(dados['nome']);
    print(dados['foto_perfil']);
  }

  chamarChat(){
    Usuario usuario = Usuario();
    usuario.nome = nomeUserPostagem;
    usuario.urlImagem = _urlFotoPerfil;
    usuario.idUsuario = userPostagem;
    print(userPostagem);
    print(_urlFotoPerfil);
    print(userPostagem);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Mensagens(usuario))
    );
  }

  @override
  void initState() {
    super.initState();
    idPostagem = widget.postagem;
    recuperarUrlFotoPerfil(userPostagem);
    _recuperarDadosPostagem();
    recuperarUrlFotoPerfil(userPostagem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_tituloAppBar)
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
               // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(// foto do user
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.deepOrange,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 40,
                        backgroundImage: _urlFotoPerfil != null
                            ? NetworkImage(_urlFotoPerfil)
                            : NetworkImage(
                            "https://us.123rf.com/450wm/urfandadashov/urfandadashov1809/urfandadashov180901275/109135379-.jpg?ver=6"
                        ),
                      ),
                    ),
                  ),
                 Container(
                   margin: EdgeInsets.only(left: 5),
                   child:  Align( // nome do user
                     alignment: Alignment.center,
                     child: Text(nomeUserPostagem.toString() != null ? nomeUserPostagem.toString() : '',
                         style: TextStyle(
                             color: Colors.black,
                             fontSize: 20.0,
                             fontWeight: FontWeight.bold)
                     ),
                   ),
                 ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Localização:',
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
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
                        enabled: false,
                        keyboardType: TextInputType.text,
                        controller: _controllerLocalizacao,
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
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Descrição:',
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
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
                        maxLines: 6,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        controller: _controllerDescricao,
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
              SizedBox(
                height: 10,
              ),
              Container(
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
                      child: Container(
                        width: 180,
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imagem1 != null
                                ? NetworkImage(imagem1)
                                : NetworkImage("https://www.danny.com.br/wp-content/uploads/2015/12/imagem-branca-grande.png"),
                          ),
                        ),
                      ),
                    ),
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
                      child: Container(
                        width: 180,
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imagem2 != null
                                ? NetworkImage(imagem2)
                                : NetworkImage("https://www.danny.com.br/wp-content/uploads/2015/12/imagem-branca-grande.png"),
                          ),
                        ),
                      ),
                    ),
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
                      child: Container(
                        width: 180,
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:  imagem3 != null
                                ? NetworkImage(imagem3)
                                : NetworkImage("https://www.danny.com.br/wp-content/uploads/2015/12/imagem-branca-grande.png"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Entrar em Contato",
                          style: TextStyle(
                             color: Colors.white,
                             fontSize: 16.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Icon(
                          Icons.chat,
                          color: Colors.white ,
                        )
                      ],
                    ),
                    onPressed: () {
                      chamarChat();
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}