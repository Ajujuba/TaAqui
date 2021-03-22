import 'package:flutter/material.dart';
import 'package:taqui/models/Chat.dart';
import '../models/ObjetoPerdido.dart';

class ListagemChats extends StatefulWidget {
  @override
  _ListagemChatsState createState() => _ListagemChatsState();
}

class _ListagemChatsState extends State<ListagemChats> {

  Future<List<Chat>> _recuperarChats() async {

    List<Chat> chats = [];
    Chat chat1 = Chat("Nicolas","Raya", DateTime.now(), ObjetoPerdido("Fatec Ipiranga", "Guarda-chuve lilás"), "Fechou. Vamos nos falando", "null");
    Chat chat2 = Chat("Nicolas","Pietro", DateTime.now(), ObjetoPerdido("Avenida Paulista", "Corta-vento azul claro"), "Obrigado você!", "null");
    Chat chat3 = Chat("Nicolas","John", DateTime.now(), ObjetoPerdido("Estação da Luz", "Carteira de Trabalho com capa do Ciclope"), "Desculpa me enganei", "null");

    chats.add(chat1);
    chats.add(chat2);
    chats.add(chat3);
    //programar verficação se o objeto é meu ou não. Se for meu mostrar o nome da outra pessoa, senõa mostrar meu nome
    //isso serve porque tanto o dono quanto o procurador podem listar os chats. Pra saber o nome de quem mostrar com prioridade,
    //entao deve realizar essa checagem, partindo do principio que o usuario 1 sempre é o dono e o usuario 2 quem achou

    //esse codigo sera substituido pela busca no Firebase, por isso é uma Future
    return chats;
    //print( postagens.toString() );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats Ativos')
      ),
      body: FutureBuilder<List<Chat>>(
        future: _recuperarChats(),
        builder: (context, snapshot){
          switch( snapshot.connectionState ){
            case ConnectionState.none :
            case ConnectionState.waiting :
              return Center(
                child: CircularProgressIndicator(),
              );
              break;
            case ConnectionState.active :
            case ConnectionState.done :
              if( snapshot.hasError ){
                print("lista: Erro ao carregar ");
              }else {

                print("lista: carregou!! ");
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index){

                      List<Chat> lista = snapshot.data;
                      Chat chat = lista[index];

                      return ListTile(
                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.deepOrange,
                          backgroundImage: NetworkImage(chat.caminhoFoto),
                        ),
                        title: Text(
                          chat.nome2,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                        subtitle: Text(
                            chat.mensagem,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14
                          ),
                        ),
                      );

                    }
                );

              }
              break;
          }
        },
      ),
    );
  }
}
