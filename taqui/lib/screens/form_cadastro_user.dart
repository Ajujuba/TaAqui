import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
const _tituloAppBar = 'Cadastro de Usuário';

class CadastroUser extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return CadastroUserState();
  }
}

class CadastroUserState extends State<CadastroUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppBar),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
          bottom: 20,
        ),
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.text,
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
            SizedBox(
              height: 5,
            ),
            TextFormField(
              keyboardType: TextInputType.text,
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
            SizedBox(
              height: 5,
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
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
            SizedBox(
              height: 5,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
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
            SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
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
            SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
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
            SizedBox(
              height: 5,
            ),
            TextFormField(
              keyboardType: TextInputType.text,
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
            SizedBox(
              height: 5,
            ),
            TextFormField(
              keyboardType: TextInputType.text,
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
            SizedBox(
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
                  onPressed: () => {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
    }
}