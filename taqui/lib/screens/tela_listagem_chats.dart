import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:taqui/models/Chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taqui/models/Mensagem.dart';
import 'package:taqui/models/Usuario.dart';
import 'package:taqui/screens/tela_mensagens.dart';

class ListagemChats extends StatefulWidget {
  @override
  _ListagemChatsState createState() => _ListagemChatsState();
}

class _ListagemChatsState extends State<ListagemChats> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _idUsuarioLogado;
  DocumentSnapshot _ultimaRemovida;
  QuerySnapshot _mensagensRemovidasUsuario;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
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
      _idUsuarioLogado = usuarioLogado.email;
    });

    _adicionarListenerConversas();
  }
  _removeConversa(String idUsuarioDestinatario) async {
    QuerySnapshot _query = await db
        .collection("mensagens")
        .doc(_idUsuarioLogado)
        .collection(idUsuarioDestinatario)
        .orderBy("data", descending: false)
        .get()
        .then((query) {

      setState(() {
        _mensagensRemovidasUsuario = query;
      });

      db
          .collection("mensagens")
          .doc(_idUsuarioLogado)
          .collection(idUsuarioDestinatario)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs){
          ds.reference.delete();
        };
      });

      db
          .collection("conversas")
          .doc(_idUsuarioLogado)
          .collection("ultima_conversa")
          .doc(idUsuarioDestinatario)
          .get()
          .then((snapshot) {
        snapshot.reference.delete();
      });
    });

  }
  _recuperaConversa(String idUsuarioDestinatario) async {

    Mensagem m = Mensagem();

    for(DocumentSnapshot mensagem in _mensagensRemovidasUsuario.docs){

      setState(() {
        m.idUsuario = mensagem["idUsuario"];
        m.urlImagem = mensagem["urlImagem"];
        m.data = mensagem["data"];
        m.mensagem = mensagem["mensagem"];
        m.tipo = mensagem["tipo"];
      });

      await db
          .collection("mensagens")
          .doc(_idUsuarioLogado)
          .collection(idUsuarioDestinatario)
          .add(m.toMap());

    }

    Chat cRemetente = Chat();
    cRemetente.idRemetente = _ultimaRemovida["idRemetente"];
    cRemetente.idDestinatario = _ultimaRemovida["idDestinatario"];
    cRemetente.mensagem = _ultimaRemovida["mensagem"];
    cRemetente.nome = _ultimaRemovida["nome"];
    cRemetente.caminhoFoto = _ultimaRemovida["caminhoFoto"];
    cRemetente.tipoMensagem = _ultimaRemovida["tipoMensagem"];
    cRemetente.salvar();

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
        backgroundColor: Color.fromRGBO(247, 89, 80, 1),
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
                      "Você ainda não tem conversas :( ",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey
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

                      return Dismissible(
                          key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction){
                            _ultimaRemovida = item;
                            conversas.removeAt(indice);
                            //função firebase
                            _removeConversa(usuario.idUsuario);
                            final snackBar = SnackBar(
                              duration: Duration(seconds: 5),
                              content: Text("Conversa apagada"),
                              action: SnackBarAction(
                                  label: "Desfazer",
                                  onPressed: (){
                                    setState(() {
                                      conversas.insert(indice, _ultimaRemovida);
                                      _recuperaConversa(usuario.idUsuario);
                                    });
                                  }
                              ),
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                          },
                          background: Container(
                            color: Colors.red,
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                          child: ListTile(
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
                                  fontSize: 16,
                                  color: Color.fromRGBO(247, 89, 80, 1)
                              ),
                            ),
                            subtitle: Text(
                                tipo=="texto"
                                    ? mensagem
                                    : "Foto",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14
                                )
                            ),
                          )
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
