import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:taqui/CustomSearchDelegate.dart';
import 'package:taqui/Menu.dart';
import 'package:taqui/enums/StatusObjeto.dart';
import 'package:taqui/models/Localizacao.dart';
import 'package:taqui/models/ObjetoPerdido.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:taqui/screens/tela_perfil_usuario.dart';

import 'tela_postagens.dart';

class ObjetoDetalhe extends StatefulWidget {

  ObjetoPerdido objetoPerdido;
  ObjetoDetalhe(this.objetoPerdido);

  @override
  _ObjetoDetalheState createState() => _ObjetoDetalheState();
}

class _ObjetoDetalheState extends State<ObjetoDetalhe> {
  Localizacao _endereco = Localizacao();
  FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _subindoImagem = false;

  TextEditingController _controllerLocalizacao = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();

  final _controller = StreamController<DocumentSnapshot>.broadcast();
  final laranja = Colors.deepOrange;
  final picker = ImagePicker();

  bool _network1 = false;
  bool _network2 = false;
  bool _network3 = false;

  File _imagem1 = null;
  File _imagem2 = null;
  File _imagem3 = null;

  //função para acessar as mídias da galeria
  Future _pegarImgGaleria(int numeroImagem) async {
    if(widget.objetoPerdido.status != StatusObjeto.ENCONTRADO){
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          switch(numeroImagem){
            case 1:
              this._imagem1 = File(pickedFile.path);
              this._network1 = false;
              break;
            case 2:
              this._imagem2 = File(pickedFile.path);
              this._network2 = false;
              break;
            case 3:
              this._imagem3 = File(pickedFile.path);
              this._network3 = false;
              break;
          }
        } else {
          print('No image selected.');
        }
      });
    }
  }
  void _removeImage(int numeroImagem){
    setState(() {
      switch(numeroImagem){
        case 1:
          this._imagem1 = null;
          this._network1 = false;
          break;
        case 2:
          this._imagem2 = null;
          this._network2 = false;
          break;
        case 3:
          this._imagem3 = null;
          this._network3 = false;
          break;
      }
    });
  }
  void _preencheImagens(){
    if(widget.objetoPerdido.imagem1 != null){
      this._imagem1 = File(widget.objetoPerdido.imagem1);
      this._network1 = true;
    }
    if(widget.objetoPerdido.imagem2 != null){
      this._imagem2 = File(widget.objetoPerdido.imagem2);
      this._network2 = true;
    }
    if(widget.objetoPerdido.imagem3 != null){
      this._imagem3 = File(widget.objetoPerdido.imagem3);
      this._network3 = true;
    }
  }

  void _defineLocalizacao() async {
    String res = await showSearch(context: context, delegate: CustomSearchDelegate());
    if(res != null && res != ""){
      final endereco = jsonDecode(res) as Map<String, dynamic>;
      _endereco.rua = endereco["rua"];
      _endereco.cep = endereco["cep"];
      _endereco.latitude = endereco["latitude"];
      _endereco.longitude = endereco["longitude"];
      _controllerLocalizacao.text = endereco["rua"];
    }
  }

  _validaForm(){
    if (_controllerDescricao.text.isNotEmpty && _controllerLocalizacao.text.isNotEmpty) {
      _saveInfos();
    } else {
      _exibirMensagem(
          "Aviso",
          "Preencha todos os campos de texto para cadastrar a postagem!",
          "erro");
    }
  }

  void _saveInfos() async{

    String imagem1 = null;
    String imagem2 = null;
    String imagem3 = null;

    if(this._imagem1 != null && this._network1 == false){
      await this._enviarFoto(this._imagem1, 1);
    }
    if(this._imagem2 != null && this._network2 == false){
      await this._enviarFoto(this._imagem2, 2);
    }
    if(this._imagem3 != null && this._network3 == false){
      await this._enviarFoto(this._imagem3, 3);
    }
    if(this._imagem1 == null && this._network1 == false){
      imagem1 = "imagem1";
    }
    if(this._imagem2 == null && this._network2 == false){
      imagem2 = "imagem2";
    }
    if(this._imagem3 == null && this._network3 == false){
      imagem3 = "imagem3";
    }

    if(imagem1 == null && imagem2 == null && imagem3 == null){
      _db.collection("postagens").doc(widget.objetoPerdido.id)
          .update({
        "endereco": {
          "latitude": _endereco.latitude,
          "longitude": _endereco.longitude,
          "rua": _endereco.rua,
          "cep": _endereco.cep
        },
        "descricao": _controllerDescricao.text
      }).then((value) => _exibirMensagem("Sucesso","Os dados desse objeto foram atualizados com êxito!", "atualizar"));
    } else {
      Map<String, dynamic> dados = Map();
      Map<String, dynamic> endereco = Map();

      endereco["latitude"] = _endereco.latitude;
      endereco["longitude"] = _endereco.longitude;
      endereco["rua"] = _endereco.rua;
      endereco["cep"] = _endereco.cep;

      dados["endereco"] = endereco;
      dados["descricao"] = _controllerDescricao.text;

      if(imagem1 != null){
        dados["imagem1"] = "";
      }
      if(imagem2 != null){
        dados["imagem2"] = "";
      }
      if(imagem3 != null){
        dados["imagem3"] = "";
      }

      _db.collection("postagens").doc(widget.objetoPerdido.id)
          .update(dados).then((value) =>
          _exibirMensagem(
              "Sucesso", "Os dados desse objeto foram atualizados com êxito!",
              "atualizar"));
    }
  }

  void _excluirObjeto() async {
    _exibirMensagem("Objeto excluído", "Posha, esperamos que não tenha desistido da sua busca. Seja forte!", "excluir");
    _controller.close().then((value) {
      _db.collection("postagens").doc(widget.objetoPerdido.id)
          .delete();
    });

  }

  void _finalizarBusca() async {
    widget.objetoPerdido.status = StatusObjeto.ENCONTRADO.toString();
    _db.collection("postagens").doc(widget.objetoPerdido.id)
        .update({
      "status": StatusObjeto.ENCONTRADO
    }).then((value) => _exibirMensagem("Busca Finalizada","Parabéns por ter encontrado seu objeto!", "finalizar"));
  }

  _exibirMensagem(String title, String mensagem, String tipo){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(
              "${title}",
              style: TextStyle(
                  color: Colors.deepOrange
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${mensagem}",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    if(tipo == "excluir"){
                      Navigator.pop(context);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                            return Menu(indice: 2);
                          }));
                    } else {
                      // _carregaDados();
                      _preencheImagens();
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Ok")
              ),
            ],
          );
        }
    );
  }

  Stream<DocumentSnapshot> _adicionarListenerPostagem(){
    print("LISTENER");
    final stream = _db
        .collection("postagens")
        .doc("${widget.objetoPerdido.id}")
        .snapshots();

    stream.listen((dados){
      _controller.add(dados);
    });
  }

  _carregaDadosPostagem(DocumentSnapshot dados){
    widget.objetoPerdido.status = dados["status"];
  }

  _enviarFoto(File imagemSelecionada, int numeroImagem) async {
    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz.child("postagens")
        .child("${widget.objetoPerdido.id}")
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
          _recuperarUrlImagem(taskSnapshot, numeroImagem);
        });
      }
    });
  }
  Future _recuperarUrlImagem(TaskSnapshot taskSnapshot, int numeroImagem) async {
    String url = await taskSnapshot.ref.getDownloadURL();
    String campo;
    switch(numeroImagem){
      case 1:
        campo = "imagem1";
        break;
      case 2:
        campo = "imagem2";
        break;
      default:
        campo = "imagem3";
    }
    _db.collection("postagens").doc(widget.objetoPerdido.id)
        .update({
      campo: url,
    });
    //this._preencheImagens();
  }

  @override
  void initState() {
    super.initState();

    this._controllerLocalizacao.text = widget.objetoPerdido.endereco.rua;
    this._controllerDescricao.text = widget.objetoPerdido.descricao;

    _endereco.rua = widget.objetoPerdido.endereco.rua;
    _endereco.latitude = widget.objetoPerdido.endereco.latitude;
    _endereco.longitude = widget.objetoPerdido.endereco.longitude;
    _endereco.cep = widget.objetoPerdido.endereco.cep;

    _adicionarListenerPostagem();
    this._preencheImagens();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD");
    var stream = StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text("Carregando postagem"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              DocumentSnapshot docSnapshot = snapshot.data;
              if (snapshot.hasError) {
                return Text("Erro ao carregar os dados");
              } else {
                this._carregaDadosPostagem(docSnapshot);
                // this._preencheImagens();
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
                                        readOnly: widget.objetoPerdido.status == StatusObjeto.ENCONTRADO ? true : false,
                                        onTap: () {
                                          if(widget.objetoPerdido.status != StatusObjeto.ENCONTRADO){
                                            _defineLocalizacao();
                                          }
                                        },
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
                                    Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.search,
                                              color: laranja,
                                              size: 35,
                                            ),
                                            onPressed: (){
                                              if(widget.objetoPerdido.status != StatusObjeto.ENCONTRADO){
                                                _defineLocalizacao();
                                              }
                                            }
                                        )
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
                                        readOnly: widget.objetoPerdido.status == StatusObjeto.ENCONTRADO ? true : false,
                                        maxLines: 4,
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
                                        child: this._imagem1 == null ?
                                        GestureDetector(
                                          onTap: (){
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
                                                  image: this._network1 ? NetworkImage(this._imagem1.path) : FileImage(this._imagem1),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 10,
                                              child: widget.objetoPerdido.status == StatusObjeto.ENCONTRADO ? Container():
                                              Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepOrange,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      _removeImage(1);
                                                    },
                                                    child: Icon(Icons.delete_forever_outlined, color: Colors.white,),
                                                  )
                                              ),
                                            ),
                                          ],
                                        )
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
                                      child: this._imagem2 == null ?
                                      GestureDetector(
                                        onTap: (){
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
                                                image: this._network2 ? NetworkImage(this._imagem2.path) : FileImage(this._imagem2),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 10,
                                            child: widget.objetoPerdido.status == StatusObjeto.ENCONTRADO ? Container():
                                            Container(
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepOrange,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    _removeImage(2);
                                                  },
                                                  child: Icon(Icons.delete_forever_outlined, color: Colors.white,),
                                                )
                                            ),
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
                                      child: this._imagem3 == null ?
                                      GestureDetector(
                                        onTap: (){
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
                                                image: this._network3 ? NetworkImage(this._imagem3.path) : FileImage(this._imagem3),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 10,
                                            child: widget.objetoPerdido.status == StatusObjeto.ENCONTRADO ? Container():
                                            Container(
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepOrange,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    _removeImage(3);
                                                  },
                                                  child: Icon(Icons.delete_forever_outlined, color: Colors.white,),
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              widget.objetoPerdido.status == StatusObjeto.ENCONTRADO ?
                              Container(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 16),
                                        child: Text(
                                          "Top! Esse objeto já foi encontrado.",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.green,
                                            // fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.where_to_vote_outlined,
                                        color: Colors.deepOrange,
                                        size: 75,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 16),
                                        child: Text(
                                          "Se perdeu esse objeto novamente, crie uma nova postagem.",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            // fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ) :
                              Column(
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
                                      child:FlatButton(
                                          child: Text(
                                            "Finalizar busca",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () {
                                            _finalizarBusca();
                                          }
                                      ),
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
                                          child: Text(
                                            "Salvar informações",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: (){
                                            _validaForm();
                                          }
                                      ),
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
                                          child: Text(
                                            "Excluir",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () {
                                            _excluirObjeto();
                                          }
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                    )
                );
              }
              break;
          }
        });


    return Scaffold(
        appBar: AppBar(
            title: Text("Detalhes do objeto")
        ),
        body: Container(
          child: SafeArea(
            child: Column(
              children: [
                stream
              ],
            ),
          ),
        )
    );
  }
}