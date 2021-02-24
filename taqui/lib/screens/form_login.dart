import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taqui/screens/form_cadastro_user.dart';



class Login extends StatelessWidget{

  final TextEditingController _controllerCampoEmail = TextEditingController(); //os TextEditingController estão pegando os valores dos TextFormFields para posteror manipulação
  final TextEditingController _controllerCampoSenha = TextEditingController();

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
        child: ListView( // inseri um ListView para permitir scroll na tela
          children: <Widget>[
            TextFormField( // Bloco referente ao imput do email
              keyboardType: TextInputType.emailAddress,
              controller: _controllerCampoEmail,
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
                  onPressed: () => {
                   debugPrint(_controllerCampoEmail.text), //testando pegar e mostrar o valor do controlador no console
                   debugPrint(_controllerCampoSenha.text)

                  },
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
        ),
      ),
    );
  }
}