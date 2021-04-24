import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taqui/CustomSearchDelegate.dart';
import 'package:taqui/enums/StatusObjeto.dart';
import 'package:taqui/models/Localizacao.dart';
import 'package:taqui/models/ObjetoPerdido.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:taqui/screens/tela_perfil_usuario.dart';

class ObjetoDetalhe extends StatefulWidget {

  ObjetoPerdido objetoPerdido;
  ObjetoDetalhe(this.objetoPerdido);

  @override
  _ObjetoDetalheState createState() => _ObjetoDetalheState();
}

class _ObjetoDetalheState extends State<ObjetoDetalhe> {
  Localizacao _endereco = Localizacao();
  FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController _controllerLocalizacao = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();

  final laranja = Colors.deepOrange;
  final picker = ImagePicker();

  File _imagem1 = null;
  File _imagem2 = null;
  File _imagem3 = null;
  
  //função para acessar as mídias da galeria
  Future _pegarImgGaleria(int numeroImagem) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        switch(numeroImagem){
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
  void _removeImage(int numeroImagem){
    setState(() {
      switch(numeroImagem){
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
  void preencheImagens(){
    setState(() {
      if(widget.objetoPerdido.imagem1 != null){
        this._imagem1 = File(widget.objetoPerdido.imagem1);
      }
      if(widget.objetoPerdido.imagem2 != null){
        this._imagem2 = File(widget.objetoPerdido.imagem2);
      }
      if(widget.objetoPerdido.imagem3 != null){
        this._imagem3 = File(widget.objetoPerdido.imagem3);
      }
    });
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
  void _saveInfos() async{
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
  }

  void _excluirObjeto() async {
    _db.collection("postagens").doc(widget.objetoPerdido.id)
       .delete()
       .then((value) {
          _exibirMensagem("Objeto excluído", "Posha, esperamos que não tenha desistido da sua busca. Seja forte!", "excluir");
       }
    );
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
                      _retorna();
                      Navigator.pop(context);
                    } else {
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

  _retorna(){
    Timer(Duration(milliseconds: 500), (){
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {

    this._controllerLocalizacao.text = widget.objetoPerdido.endereco.rua;
    this._controllerDescricao.text = widget.objetoPerdido.descricao;

    _endereco.rua = widget.objetoPerdido.endereco.rua;
    _endereco.latitude = widget.objetoPerdido.endereco.latitude;
    _endereco.longitude = widget.objetoPerdido.endereco.longitude;
    _endereco.cep = widget.objetoPerdido.endereco.cep;

    this.preencheImagens();

    return Scaffold(
      appBar: AppBar(
          title: Text("Detalhes do objeto")
      ),
      body: Container(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
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
                          onTap: () {
                            _defineLocalizacao();
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
                              _defineLocalizacao();
                            }
                        )
                      ),
                    ],
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
                                    image: NetworkImage(this._imagem1.path),
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
                                  image: FileImage(this._imagem2),
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
                                  image: FileImage(this._imagem3),
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
                  height: 20,
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
                          _saveInfos();
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
            ),
          )
      ),
    );
  }
}