import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taqui/models/Mensagem.dart';
import 'package:taqui/models/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/Chat.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  File _imagem;
  bool _subindoImagem = false;
  final picker = ImagePicker();
  String _idUsuarioLogado;
  String _idUsuarioDestinatario;
  Usuario _usuarioLogado = Usuario();
  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController _controllerMensagem = TextEditingController();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = new Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.urlImagem = "";
      mensagem.data = Timestamp.now().toString();
      mensagem.mensagem = textoMensagem;
      mensagem.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
      _salvarConversa(mensagem);
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    _controllerMensagem.clear();
  }

  _salvarConversa(Mensagem mensagem){
    Chat cRemetente = Chat();
    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = mensagem.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipoMensagem = mensagem.tipo;
    cRemetente.salvar();

    Chat cDestinatario = Chat();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = mensagem.mensagem;
    cDestinatario.nome = _usuarioLogado.nome;
    cDestinatario.caminhoFoto = _usuarioLogado.urlImagem;
    cDestinatario.tipoMensagem = mensagem.tipo;
    cDestinatario.salvar();
  }

  _enviarFoto() async {
    File imagemSelecionada;
    final img = await picker.getImage(source: ImageSource.gallery);
    imagemSelecionada =  File(img.path);
    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz.child("mensagens")
                                 .child(_idUsuarioLogado)
                                 .child(nomeImagem + ".jpg");
    UploadTask task = arquivo.putFile(imagemSelecionada);

    task.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      if(taskSnapshot.state == TaskState.running){
        setState(() {
          _subindoImagem = true;
        });
      } else if(taskSnapshot.state == TaskState.success){
        setState(() {
          _subindoImagem = false;
          _recuperarUrlImagem(taskSnapshot);
        });
      }
    });
  }
  Future _recuperarUrlImagem(TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();

    Mensagem mensagem = new Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.urlImagem = url;
    mensagem.data = Timestamp.now().toString();
    mensagem.mensagem = "";
    mensagem.tipo = "imagem";

    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
  }

   _recuperarDadosUsuario({Function onTap}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;

    DocumentSnapshot snapshot = await db.collection("usuarios")
        .doc(usuarioLogado.email).get();

    var user = snapshot.data();

    setState(() {
      _idUsuarioLogado = usuarioLogado.email;
      _idUsuarioDestinatario = widget.contato.idUsuario;
      _usuarioLogado.nome = user["nome"];
      _usuarioLogado.urlImagem = user["foto_perfil"];
      _usuarioLogado.email = usuarioLogado.email;
    });
    _adicionarListenerMensagens();
  }

  Stream<QuerySnapshot> _adicionarListenerMensagens(){

    final stream = db
        .collection("mensagens")
        .doc(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario)
        .orderBy("data", descending: false)
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  void initState()  {
    _recuperarDadosUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   /* _idUsuarioLogado = "fzrI52XLCwMbIpx8XeuwHtuPTbk1";
    _idUsuarioDestinatario = "QBXHNY3s7zdNPygwHb31hlmFv182";*/
    var stream = StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text("Carregando mensagens"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data;
              if (snapshot.hasError) {
                return Text("Erro ao carregar os dados");
              } else {
                return Expanded(
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (context, index) {
                          List<DocumentSnapshot> mensagens = querySnapshot.docs.toList();
                          DocumentSnapshot item = mensagens[index];
                          double larguraContainer = MediaQuery.of(context).size.width * 0.8;
                          Alignment alinhamento = (_idUsuarioLogado == item ["idUsuario"])
                              ? Alignment.centerRight
                              : Alignment.centerLeft;
                          Color cor = (_idUsuarioLogado == item ["idUsuario"])
                              ? Color(0xffffd699)
                              : Colors.white;
                          return Align(
                            alignment: alinhamento,
                            child: Padding(
                              padding: EdgeInsets.all(6),
                              child: Container(
                                width: larguraContainer,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: cor,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                                child: item["tipo"] == "texto" ?
                                Text(item["mensagem"], style: TextStyle(fontSize: 16),) :
                                Image.network(item["urlImagem"])
                              ),
                            ),
                          );
                        }));
              }
              break;
          }
        });

    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon: _subindoImagem ? CircularProgressIndicator() :
                    IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.deepOrange,
                      ),
                      onPressed: (){
                        _enviarFoto();
                      }
                    )),
              ),
            ),
          ),
          FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              child: Icon(Icons.send, color: Colors.white),
              mini: true,
              onPressed: () {
                _enviarMensagem();
              })
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                  maxRadius: 20,
                  backgroundColor: Colors.grey,
                  backgroundImage: widget.contato.urlImagem != null
                      ? NetworkImage(widget.contato.urlImagem)
                      : null),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(widget.contato.nome),
              )
            ],
          )),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [stream, caixaMensagem],
              ),
            )),
      ),
    );
  }
}
