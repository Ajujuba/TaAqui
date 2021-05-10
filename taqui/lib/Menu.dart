import 'package:flutter/material.dart';
import 'package:taqui/screens/tela_listagem_chats.dart';
import 'package:taqui/screens/tela_mapa_postagens.dart';
import 'package:taqui/screens/tela_perfil_usuario.dart';
import 'package:taqui/screens/tela_postagens.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _indice = 0;
  @override
  Widget build(BuildContext context) {

    List<Widget> telas = [
      PerfilUsuario(),
      /*Container(
        child: Center(
          child: Text(
            "Lista de Postagens",
            style: TextStyle(
              fontSize: 25
            ),
          )
        ),
      ),*/
      MapaPostagens(),
      ListagemChats(),
      PostagensUsuario()
    ];
    return Scaffold(
      body: telas[_indice],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _indice,
        onTap: (indice){
          setState(() {
            _indice = indice;
          });
        },
        fixedColor: Colors.white,
        items: [
          BottomNavigationBarItem(
              backgroundColor: Colors.deepOrange,
              title: Text("Perfil"),
              icon: Icon(Icons.account_circle)
          ),
          BottomNavigationBarItem(
              backgroundColor: Color.fromRGBO(246, 120, 46, 1),
              title: Text("Postagens"),
              icon: Icon(Icons.search)
          ),
          BottomNavigationBarItem(
              backgroundColor: Color.fromRGBO(247, 89, 80, 1),
              title: Text("Chats"),
              icon: Icon(Icons.chat)
          ),
          BottomNavigationBarItem(
              backgroundColor: Color.fromRGBO(249, 46, 123, 1),
              title: Text("Minhas postagens"),
              icon: Icon(Icons.folder)
          ),
        ],
      ),
    );
  }
}
