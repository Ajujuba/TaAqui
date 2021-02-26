import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const _tituloAppBar = 'Cadastro de Usuário';

class CadastroUser extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return CadastroUserState();
  }
}

class CadastroUserState extends State<CadastroUser> {

  // os TextEditingController estão pegando os valores dos TextFormFields para posteror manipulação
  final TextEditingController _controllerCampoNome = TextEditingController();
  final TextEditingController _controllerCampoDataNasc = TextEditingController();
  final TextEditingController _controllerCampoEmail = TextEditingController();
  final TextEditingController _controllerCampoNumCel = TextEditingController();
  final TextEditingController _controllerCampoNumTel = TextEditingController();
  final TextEditingController _controllerCampoCpf = TextEditingController();
  final TextEditingController _controllerCampoSenha = TextEditingController();
  final TextEditingController _controllerCampoConfirmaSenha = TextEditingController();

  // as mascaras a seguir estão sendo criadas aqui e aplicadas nos respectivos campos
  var macaraDataNasc = new MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]') });
  var macaraNumCel = new MaskTextInputFormatter(mask: '(##) #####-####', filter: { "#": RegExp(r'[0-9]') });
  var macaraNumTel = new MaskTextInputFormatter(mask: '(##) ####-####', filter: { "#": RegExp(r'[0-9]') });
  var macaraCpf = new MaskTextInputFormatter(mask: '###.###.###-##', filter: { "#": RegExp(r'[0-9]') });

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
        child: ListView( // inseri um ListView para permitir scroll na tela
          children: <Widget>[
            TextFormField( // Bloco referente ao input do nome
              keyboardType: TextInputType.text,
              controller: _controllerCampoNome,
              decoration: InputDecoration(
                labelText: "Nome",
                icon: Icon(Icons.person),
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(  // bloco referente ao espaço entre o input do nome e o da data de nascimento
              height: 5,
            ),
            TextFormField( // Bloco referente ao input da data de nascimento
              keyboardType: TextInputType.text,
              controller: _controllerCampoDataNasc,
              inputFormatters: [macaraDataNasc],
              decoration: InputDecoration(
                labelText: "Data de Nascimento",
                icon: Icon(Icons.calendar_today),
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox( // bloco referente ao espaço entre o input da data de nascimento e o do email
              height: 5,
            ),
            TextFormField( // Bloco referente ao input do email
              keyboardType: TextInputType.emailAddress,
              controller: _controllerCampoEmail,
              decoration: InputDecoration(
                labelText: "Email",
                icon: Icon(Icons.email),
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox( // bloco referente ao espaço entre o input  do email e do numero de celular
              height: 5,
            ),
            TextFormField( // Bloco referente ao input do numero de celular
              keyboardType: TextInputType.number,
              controller: _controllerCampoNumCel,
              inputFormatters: [macaraNumCel],
              decoration: InputDecoration(
                labelText: "Número de Celular",
                icon: Icon(Icons.phone_iphone),
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox( // bloco referente ao espaço entre o input  do numero de celular e o numero de telefone
              height: 10,
            ),
            TextFormField( // Bloco referente ao input do numero de telefone
              keyboardType: TextInputType.number,
              controller: _controllerCampoNumTel,
              inputFormatters: [macaraNumTel],
              decoration: InputDecoration(
                labelText: "Número de Telefone",
                icon: Icon(Icons.phone),
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox( // bloco referente ao espaço entre o input  do numero de telefone e do cpf
              height: 10,
            ),
            TextFormField( // Bloco referente ao imput do cpf
              keyboardType: TextInputType.number,
              controller: _controllerCampoCpf,
              inputFormatters: [macaraCpf],
              decoration: InputDecoration(
                labelText: "CPF",
                icon: Icon(Icons.perm_identity),
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox( // bloco referente ao espaço entre o input  do cpf e a senha
              height: 5,
            ),
            TextFormField( // Bloco referente ao input da senha
              keyboardType: TextInputType.text,
              controller: _controllerCampoSenha,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                icon: Icon(Icons.lock_open),
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox( // bloco referente ao espaço entre o input  da senha e da confirmação de senha
              height: 5,
            ),
            TextFormField( // Bloco referente ao input da confirmação da senha
              keyboardType: TextInputType.text,
              controller: _controllerCampoConfirmaSenha,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirme sua Senha",
                icon: Icon(Icons.lock),
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox( // espaço entre campo de confirmação de senha e o botão pra submeter o form
              height: 20,
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
                child:FlatButton( // bloco do botão de cadastro
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Salvar Informações",
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
                    debugPrint(_controllerCampoNome.text), //testando pegar e mostrar o valor do controlador no console
                    debugPrint(_controllerCampoDataNasc.text),
                    debugPrint(_controllerCampoEmail.text),
                    debugPrint(_controllerCampoNumCel.text),
                    debugPrint(_controllerCampoNumTel.text),
                    debugPrint(_controllerCampoCpf.text),
                    debugPrint(_controllerCampoSenha.text),
                    debugPrint(_controllerCampoConfirmaSenha.text)
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
    }
}