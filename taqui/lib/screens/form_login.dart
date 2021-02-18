import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taqui/screens/form_cadastro_user.dart';

class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: 60,
          left: 40,
          right: 40,
        ),
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 20.0,
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
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 20.0,
                ),
              ),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
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
                child:FlatButton(
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
                  onPressed: () => {},
                ),
                ),
              ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 45,
              child: FlatButton(
                child: Text(
                  "Cadastre-se",
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
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