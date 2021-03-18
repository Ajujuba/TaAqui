import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _tituloAppBar = 'Cadastro de Postagem';

class CadastroPostagem extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return CadastroPostagemState();
  }
}

class CadastroPostagemState extends State<CadastroPostagem> {
  GlobalKey<FormState> _key = new GlobalKey(); // chave
  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // define um titulo pra tela
        title: Text(_tituloAppBar),
      ),
      body: Container( // inseri o container para delimitar o posicioamento dos widgets na tela
        padding: EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
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

    Widget _formPostagem(){
      return ListView( // inseri um ListView para permitir scroll na tela
        children: <Widget>[
          TextFormField( // Bloco referente ao input da localização
            keyboardType: TextInputType.text,
            onSaved: (String val) { },
            decoration: InputDecoration(
              labelText: "Localização",
              icon: Icon(Icons.zoom_in),
              labelStyle: TextStyle(
                color: Colors.black38,
                fontSize: 18.0,
              ),
            ),
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
              child: TextFormField( // Bloco referente ao input da descrição
                keyboardType: TextInputType.text,
                onSaved: (String val) { },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 150),
                  labelText: "Descrição do objeto...",
                  labelStyle: TextStyle(
                    color: Colors.black38,
                    fontSize: 18.0,
                  ),
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              )
          ),
          SizedBox(
            height: 5,
          ),
          Container( // container que define o fundo do botão
            height: 50,
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.3,1],
                colors: [
                  Color(0xFFF58524), //decidir cores posteriormente
                  Color(0xFFF92B7F),
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: SizedBox.expand(
              child:TextButton(
                child: Container(
                  child:
                  Text('Cadastrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                onPressed: () { },
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.lightBlue,
                  side: BorderSide(color: Colors.grey, width: 2),
                ),)
            ),
          ),
        ],
      );
    }
}