import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:taqui/models/Chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taqui/models/Usuario.dart';
import 'package:taqui/screens/tela_mensagens.dart';

class ListagemChats extends StatefulWidget {
  @override
  _ListagemChatsState createState() => _ListagemChatsState();
}

class _ListagemChatsState extends State<ListagemChats> {
  List<Chat> _listaConversas = [];
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _idUsuarioLogado;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();

    Chat conversa = Chat();
    conversa.nome = "Ana Clara";
    conversa.mensagem = "Olá tudo bem?";
    conversa.caminhoFoto = "https://firebasestorage.googleapis.com/v0/b/taaqui-firebase-backend.appspot.com/o/foto_perfil%2FQBXHNY3s7zdNPygwHb31hlmFv182.jpg?alt=media&token=94acf580-1a31-4405-9dc7-cea476819da7";

    _listaConversas.add(conversa);

  }

  Stream<QuerySnapshot> _adicionarListenerConversas(){

    final stream = db.collection("conversas")
        .doc( _idUsuarioLogado )
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });

  }

  _recuperarDadosUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;

    setState(() {
      _idUsuarioLogado = usuarioLogado.uid;
    });

    _adicionarListenerConversas();
  }
  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                  "Conversas"
              ),
            ),
            Icon(Icons.chat_outlined, color: Colors.white)
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot){
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("Carregando conversas"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text("Erro ao carregar os dados!");
              }else{

                QuerySnapshot querySnapshot = snapshot.data;

                if( querySnapshot.docs.length == 0 ){
                  return Center(
                    child: Text(
                      "Você não tem nenhuma mensagem ainda :( ",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                }

                return ListView.builder(
                    itemCount: querySnapshot.docs.length,
                    itemBuilder: (context, indice){

                      List<DocumentSnapshot> conversas = querySnapshot.docs.toList();
                      DocumentSnapshot item = conversas[indice];

                      String urlImagem  = item["caminhoFoto"];
                      String tipo       = item["tipoMensagem"];
                      String mensagem   = item["mensagem"];
                      String nome       = item["nome"];
                      String idDestinatario  = item["idDestinatario"];

                      Usuario usuario = Usuario();
                      usuario.nome = nome;
                      usuario.urlImagem = urlImagem;
                      usuario.idUsuario = idDestinatario;

                      return ListTile(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Mensagens(usuario))
                          );
                        },
                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: urlImagem!=null
                              ? NetworkImage( urlImagem )
                              : null,
                        ),
                        title: Text(
                          nome,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                        subtitle: Text(
                            tipo=="texto"
                                ? mensagem
                                : "Imagem...",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14
                            )
                        ),
                      );

                    }
                );

              }
          }
        },
      ),
    );
  }
}
