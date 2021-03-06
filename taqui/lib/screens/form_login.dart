import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taqui/screens/form_cadastro_user.dart';
import 'package:taqui/screens/tela_perfil_usuario.dart';

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

  _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _key.currentState.save();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) {
        return PerfilUsuario();
      }));
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
        child: Form(
            key: _key,
            autovalidate: _validate,
            child: _formUI(),
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

