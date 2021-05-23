import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taqui/CustomSearchDelegate.dart';
import 'package:taqui/Menu.dart';
import 'package:taqui/enums/StatusObjeto.dart';
import 'package:taqui/models/Localizacao.dart';
import 'package:taqui/models/ObjetoPerdido.dart';
import 'package:taqui/models/Usuario.dart';
import 'package:taqui/screens/form_cadastro_user.dart';
import 'package:taqui/screens/tela_listagem_chats.dart';
import 'package:taqui/screens/tela_mensagens.dart';
import 'package:taqui/screens/tela_objeto_detalhe.dart';
import 'package:taqui/screens/tela_perfil_usuario.dart';
import 'package:taqui/screens/tela_postagens.dart';
import 'package:taqui/screens/tela_visualizar_postagem.dart';
import 'package:taqui/screens/form_cadastro_postagem.dart';

Future<void> showInformationDialog(BuildContext context, String txt) async{
  return await showDialog(context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Aviso"),
          content: Text(txt),
          actions: <Widget>[
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("Ok"))
          ],
        );
      });
}

class Login extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login>{

  GlobalKey<FormState> _key = new GlobalKey(); //chave
  bool _validate = false;

  //os TextEditingController estão pegando os valores dos TextFormFields para posteror manipulação
  final TextEditingController _controllerCampoEmail = TextEditingController();
  final TextEditingController _controllerCampoSenha = TextEditingController();

  String _validarEmail(String value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Informe o Email";
    } else if(!regExp.hasMatch(value)){
      return "Email inválido";
    }else {
      return null;
    }
  }

  String _validarSenha(String value) {
    if (value.length == 0) {
      return "Informe a senha";
    }
  }

  _sendForm() async {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _key.currentState.save();
      try{
        UserCredential userCred =
        (await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _controllerCampoEmail.text,
                password: _controllerCampoSenha.text));

        if (userCred != null){
          print("Foi");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) {
            return Menu();
          }));
        }
      } on FirebaseAuthException catch (e){
        String txt = "Usuário ou senha não encontrados!";
        if (e.code == 'user-not-found'){
           txt = "Nenhum usuário encontrado com esse email.";
        }else if (e.code == "wrong-password") {
           txt = "Senha inválida";
        }
        showInformationDialog(context, txt);
      }
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container( // inseri o container para delimitar o posicioamento dos widgets na tela
        padding: EdgeInsets.only(
          top: 60,
          left: 30,
          right: 30,
        ),
        color: Colors.white,
        child: Column(
          children: [
            Image.asset("imagens/logo_colorido.png"),
            Expanded(child: Form(
              key: _key,
              autovalidate: _validate,
              child: _formUI(),
            ),
            )
          ],
        ),
      ),
    );
  }

  Widget _formUI() {
    return ListView(
      children: <Widget>[
        TextFormField( // Bloco referente ao input do email
          keyboardType: TextInputType.emailAddress,
          controller: _controllerCampoEmail,
          validator: _validarEmail,
          onSaved: (String val) {
            _controllerCampoEmail.text = val;
          },
          decoration: InputDecoration(
            labelText: "Email",
            labelStyle: TextStyle(
              color: Colors.black38,
              fontSize: 18.0,
            ),
          ),
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
        SizedBox( // bloco referente ao espaço entre o input do email e o da senha
          height: 10,
        ),
        TextFormField( // bloco referente ao input da senha
          keyboardType: TextInputType.text,
          controller: _controllerCampoSenha,
          validator: _validarSenha,
          onSaved: (String val) {
            _controllerCampoSenha.text = val;
          },
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Senha",
            labelStyle: TextStyle(
              color: Colors.black38,
              fontSize: 18.0,
            ),
          ),
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
        SizedBox( // bloco que da espaço entre a senha e o botão de Login
          height: 40,
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
            child:FlatButton( // bloco do botão de Login
              child: Row(
                children: <Widget>[
                  Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 21.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              onPressed: _sendForm,
            ),
          ),
        ),
        SizedBox( // espaço entre o botão de login e o de cadastro
          height: 20,
        ),
        Container( //tamanho do botão de cadastro
          height: 45,
          child: FlatButton( // botão de cadastro
            child: Text(
              "Cadastre-se",
              textAlign: TextAlign.center,
            ),
            onPressed: () { // ação do botão
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) {
                return CadastroUser();
              }));
            },
          ),
        ),
      ],
    );

  }
}

