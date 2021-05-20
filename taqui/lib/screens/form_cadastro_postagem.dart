import 'dart:async';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:taqui/models/Localizacao.dart';
import 'package:taqui/models/ObjetoPerdido.dart';
import 'package:taqui/screens/tela_mapa_postagens.dart';
import 'package:taqui/screens/tela_objeto_detalhe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../CustomSearchDelegate.dart';
import '../Menu.dart';

const _tituloAppBar = 'Cadastro de Postagem';

class CadastroPostagem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CadastroPostagemState();
  }
}

class CadastroPostagemState extends State<CadastroPostagem> {
  String _id;
  bool _bool = false;

  bool _subindoImagem = false;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  GlobalKey<FormState> _key = new GlobalKey(); // chave
  Localizacao _endereco = Localizacao();
  bool _validate = false;
  final laranja = Colors.deepOrange;
  final picker = ImagePicker();
  final _controller = StreamController<DocumentSnapshot>.broadcast();

  TextEditingController _controllerLocalizacao = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();
  var endereco;
  bool _network1 = false;
  bool _network2 = false;
  bool _network3 = false;

  File _imagem1 = null;
  File _imagem2 = null;
  File _imagem3 = null;

  List<File> _imagens = [];

  //função para acessar as mídias da galeria
  Future _pegarImgGaleria(int numeroImagem) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        switch (numeroImagem) {
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

  void _removeImage(int numeroImagem) {
    setState(() {
      switch (numeroImagem) {
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

  _exibirMensagem(String title, String mensagem, String tipo) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "${title}",
              style: TextStyle(color: Colors.deepOrange),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${mensagem}",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    if (tipo == "excluir") {
                      _retorna();
                      Navigator.pop(context);
                    } else if (tipo == "atualizar") {
                      Navigator.pop(context);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return Menu();
                      }));
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Ok")),
            ],
          );
        });
  }

  _retorna() {
    Timer(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
  }

  void _defineLocalizacao() async {
    String res =
        await showSearch(context: context, delegate: CustomSearchDelegate());
    if (res != null && res != "") {
      final endereco = jsonDecode(res) as Map<String, dynamic>;
      _endereco.rua = endereco["rua"];
      _endereco.cep = endereco["cep"];
      _endereco.latitude = endereco["latitude"];
      _endereco.longitude = endereco["longitude"];
      _controllerLocalizacao.text = endereco["rua"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // define um titulo pra tela
        title: Text(_tituloAppBar),
      ),
      body: Container(
        // inseri o container para delimitar o posicioamento dos widgets na tela
        padding: EdgeInsets.only(
          top: 20,
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

   _validaForm(){
    if (_controllerDescricao != "" && _controllerLocalizacao != "") {
      _saveInfos();
    } else {
      _exibirMensagem(
          "Aviso",
          "Preencha todos os campos de texto para cadastrar a postagem!",
          "erro");
      _bool = false;
    }
  }

  _saveInfos() async {

    String imagem1 = null;
    String imagem2 = null;
    String imagem3 = null;

    if (this._imagem1 == null && this._network1 == false) {
      imagem1 = "imagem1";
    }
    if (this._imagem2 == null && this._network2 == false) {
      imagem2 = "imagem2";
    }
    if (this._imagem3 == null && this._network3 == false) {
      imagem3 = "imagem3";
    }

    var usuarioLogado = auth.currentUser.email.toString();
    var _dataPostagem = DateTime.now();

    Map<String, dynamic> dados = Map();
    Map<String, dynamic> endereco = Map();

    endereco["latitude"] = _endereco.latitude;
    endereco["longitude"] = _endereco.longitude;
    endereco["rua"] = _endereco.rua;
    endereco["cep"] = _endereco.cep;

    dados["endereco"] = endereco;
    dados["descricao"] = _controllerDescricao.text;
    dados["usuario"] = usuarioLogado;
    dados["dataPostagem"] = _dataPostagem;
    dados["status"] = "PERDIDO";

    if (imagem1 != null && imagem2 != null && imagem3 != null) {
      dados["imagem1"] = "";
      dados["imagem2"] = "";
      dados["imagem3"] = "";
    } else if (imagem1 != null && imagem2 != null && imagem3 == null) {
      dados["imagem1"] = "";
      dados["imagem2"] = "";
    } else if (imagem1 != null && imagem2 == null && imagem3 != null) {
      dados["imagem1"] = "";
      dados["imagem3"] = "";
    } else if (imagem1 == null && imagem2 != null && imagem3 != null) {
      dados["imagem2"] = "";
      dados["imagem3"] = "";
    } else if (imagem1 != null && imagem2 == null && imagem3 == null) {
      dados["imagem1"] = "";
    } else if (imagem1 == null && imagem2 != null && imagem3 == null) {
      dados["imagem2"] = "";
    } else if (imagem1 == null && imagem2 == null && imagem3 != null) {
      dados["imagem3"] = "";
    }
    print(dados.toString());

    DocumentReference docRef = await _db.collection("postagens").add(dados);

    _id = docRef.id;
    if (this._imagem1 == null &&
        this._imagem2 == null &&
        this._imagem3 == null) {
      _exibirMensagem("Aviso", "Postagem cadastrada com sucesso!", "atualizar");
    } else {
      if (this._imagem1 != null && this._network1 == false) {
        await this._enviarFoto(this._imagem1, 1);
      }
      if (this._imagem2 != null && this._network2 == false) {
        await this._enviarFoto(this._imagem2, 2);
      }
      if (this._imagem3 != null && this._network3 == false) {
        await this._enviarFoto(this._imagem3, 3);
      }
    }

  }


  _enviarFoto(File imagemSelecionada, int numeroImagem) async {
    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("postagens")
        //->
        .child(_id)
        .child(nomeImagem + ".jpg");
    UploadTask task = arquivo.putFile(imagemSelecionada);

    task.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      if (taskSnapshot.state == TaskState.running) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (taskSnapshot.state == TaskState.success) {
        setState(() {
          _subindoImagem = false;
          _insereImagem(taskSnapshot, numeroImagem);
        });
      }
    });
  }

  Future _insereImagem(
      TaskSnapshot taskSnapshot, int numeroImagem) async {
    String url = await taskSnapshot.ref.getDownloadURL();
    String campo;
    switch (numeroImagem) {
      case 1:
        campo = "imagem1";
        break;
      case 2:
        campo = "imagem2";
        break;
      default:
        campo = "imagem3";
    }

    _db.collection("postagens").doc(_id).update({
      campo: url,
    });

    _exibirMensagem("Aviso", "Postagem cadastrada com sucesso!", "atualizar");
  }

  Widget _formPostagem() {
    return Expanded(
        child: Container(
            child: SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
                    readOnly: false,
                    onTap: () async {
                      _defineLocalizacao();
                    },
                    keyboardType: TextInputType.text,
                    controller: _controllerLocalizacao,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Localização",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                        onPressed: () {})),
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
                    readOnly: false,
                    maxLines: 6,
                    keyboardType: TextInputType.text,
                    controller: _controllerDescricao,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Descrição",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                    child: this._imagem1 == null
                        ? GestureDetector(
                            onTap: () {
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
                                    image: this._network1
                                        ? NetworkImage(this._imagem1.path)
                                        : FileImage(this._imagem1),
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
                                      onTap: () {
                                        _removeImage(1);
                                      },
                                      child: Icon(
                                        Icons.delete_forever_outlined,
                                        color: Colors.white,
                                      ),
                                    )),
                              ),
                            ],
                          )),
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
                  child: this._imagem2 == null
                      ? GestureDetector(
                          onTap: () {
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
                                  image: this._network2
                                      ? NetworkImage(this._imagem2.path)
                                      : FileImage(this._imagem2),
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
                                    onTap: () {
                                      _removeImage(2);
                                    },
                                    child: Icon(
                                      Icons.delete_forever_outlined,
                                      color: Colors.white,
                                    ),
                                  )),
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
                  child: this._imagem3 == null
                      ? GestureDetector(
                          onTap: () {
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
                                  image: this._network3
                                      ? NetworkImage(this._imagem3.path)
                                      : FileImage(this._imagem3),
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
                                    onTap: () {
                                      _removeImage(3);
                                    },
                                    child: Icon(
                                      Icons.delete_forever_outlined,
                                      color: Colors.white,
                                    ),
                                  )),
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
                    stops: [0.3, 1],
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
                  child: FlatButton(
                      child: Text(
                        "Cadastrar postagem!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        _validaForm();
                      }),
                ),
              ),
            ],
          )
        ],
      ),
    )));
  }
}
