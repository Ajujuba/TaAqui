import 'package:flutter/material.dart';
import 'package:taqui/models/ObjetoPerdido.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ObjetoDetalhe extends StatefulWidget {

  ObjetoPerdido objetoPerdido;
  ObjetoDetalhe(this.objetoPerdido);

  @override
  _ObjetoDetalheState createState() => _ObjetoDetalheState();
}

class _ObjetoDetalheState extends State<ObjetoDetalhe> {

  TextEditingController _controllerLocalizacao = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();

  final laranja = Colors.deepOrange;
  final picker = ImagePicker();

  File _imagem1 = null;
  File _imagem2 = null;
  File _imagem3 = null;

  List<File> _imagens = [];

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
      if(this._imagens.length > 0){
        this._imagem1 = this._imagens[0];
      }
      if(this._imagens.length > 1){
        this._imagem1 = this._imagens[1];
      }
      if(this._imagens.length > 2){
        this._imagem1 = this._imagens[2];
      }
    });
  }
  void saveInfos(){
    this._imagens = [];
    if(this._imagem1 != null){
      this._imagens.add(this._imagem1);
    }
    if(this._imagem2 != null){
      this._imagens.add(this._imagem2);
    }
    if(this._imagem3 != null){
      this._imagens.add(this._imagem3);
    }
    print(this._imagens.length);
  }

  @override
  Widget build(BuildContext context) {

    this._controllerLocalizacao.text = widget.objetoPerdido.localizacao;
    this._controllerDescricao.text = widget.objetoPerdido.descricao;
    this._imagens = widget.objetoPerdido.imagens;
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
                        child: Icon(
                          Icons.search,
                          color: laranja,
                          size: 35,
                        ),
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
                                    image: FileImage(this._imagem1),
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
                        onPressed: saveInfos
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