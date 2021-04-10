import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

const _tituloAppBar = 'Perfil do usuário';

class PerfilUsuario extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return PerfilUsuarioState();
  }
}

class PerfilUsuarioState extends State<PerfilUsuario> {
  final laranja = Colors.deepOrange;

  final TextEditingController _controllerCampoEmail = TextEditingController();
  final TextEditingController _controllerCampoNome = TextEditingController();

  //variáveis para manipular img
  File imagem;
  final picker = ImagePicker();
  String _idUsuarioLogado;
  String _urlImagemRecuperada;

  //função para acessar as mídias da galeria
  Future pegarImgGaleria() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imagem = File(pickedFile.path);
        print('Image Path $imagem');
      }
    });
  }

  //função para acessar a camera do celular
  Future pegarImgCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        imagem = File(pickedFile.path);
        print('Image Path $imagem');
      }
    });
  }

  //função para acessar o Storage, salvar a foto de perfil e adicionar uma referencia em Usuários
 Future salvarFoto(BuildContext context) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      String  usuarioLogado = auth.currentUser.uid.toString();
      _idUsuarioLogado = usuarioLogado;
      print(" uid: $usuarioLogado");
      final ext = ".jpg";
      String nome_img=("$_idUsuarioLogado"+ext);
      String fileName = basename(
          imagem.path); //pegando apenas o nome da img e não o caminho inteiro
      firebase_storage.Reference firebaseStorageRef = firebase_storage
          .FirebaseStorage.instance.ref().child('foto_perfil').child(nome_img); //obtem referencia ao nome do arquivo
      firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(imagem); // inserindo o arquivo no firebase
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask
          .whenComplete(() =>
          setState(() {
            if (uploadTask !=
                null) {
              FirebaseAuth auth = FirebaseAuth.instance;
              String email = auth.currentUser.email.toString();
              CollectionReference user = FirebaseFirestore.instance.collection(
                  "usuarios");
              //Alterar nome do doc de email pra UID ao finalizar o prj!!!
              user.doc(email).update({
                'foto_perfil': fileName
              });
            }
            print("Foto de perfil atualizada");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Foto de perfil atualizada')));
          }));
      //Recuperar url da imagem
      taskSnapshot.ref.getDownloadURL().then(
            (value) => print("Done: $value")
      );
    } on FirebaseException catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao Atualizar foto de perfil')));
    }
  }

  getEmail(_controllerCampoEmail){
    FirebaseAuth auth = FirebaseAuth.instance;
    String email = auth.currentUser.email.toString();
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference docRef = db.collection("usuarios").doc(email);
    docRef.get();
    this._controllerCampoEmail.text = email;
    return _controllerCampoEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // define um titulo pra tela
        title: Text(_tituloAppBar),
        elevation: 0,
      ),
      body: Builder(
        builder: (context) =>
            SingleChildScrollView(
              child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container( // define o retangulo laranja onde a foto vai aparecer
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 270,
                        decoration: BoxDecoration( // define que a cor é laranja
                          color: laranja,
                          borderRadius: BorderRadius
                              .only( // define bordas inferiores arredondadas
                            bottomRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Row( // linha onde estão os elementos do container de fundo laranja
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding( // define icone e função da galeria
                                  padding: EdgeInsets.only(top: 120.0),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.image,
                                      size: 30.0,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      pegarImgGaleria();
                                    },
                                  ),
                                ),
                                Align( // posicionamento/layout da img de perfil
                                  alignment: Alignment.center,
                                  child: CircleAvatar( // define a borda da img
                                    radius: 100,
                                    backgroundColor: Colors.white,
                                    child: ClipOval( // define onde a img aparece
                                      child: new SizedBox( //define o tamanho da img
                                        width: 180.0,
                                        height: 180.0,
                                        child: (imagem != null) ? Image
                                            .file( //se a pessoa escolher um arquivo
                                          imagem,
                                          //o arquivo será exibido no perfil
                                          fit: BoxFit.fill,
                                        ) : Image.network(
                                          "https://images.unsplash.com/photo-1502164980785-f8aa41d53611?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                                          fit: BoxFit
                                              .fill, //senao, uma img default irá ser exibida
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding( // define icone e função  da camera
                                  padding: EdgeInsets.only(top: 120.0),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.camera_alt,
                                      size: 30.0,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      pegarImgCamera();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row( //botão pra salvar a foto de perfil
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RaisedButton(
                                  color: Colors.white,
                                  onPressed: () {
                                    salvarFoto(context);
                                  },
                                  elevation: 0.0,
                                  splashColor: Colors.deepOrange[100],
                                  child: Text(
                                    'Salvar Foto',
                                    style: TextStyle(
                                        color: laranja, fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row( //definindo os dados do perfil
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row( // nome do user
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Align( // título
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Nome',
                                         style: TextStyle(
                                           color: laranja,
                                             fontWeight: FontWeight.bold,
                                           fontSize: 18.0),
                                         ),
                                      ),
                                      Align( // conteúdo
                                        alignment: Alignment.centerLeft,
                                        child:  SizedBox(
                                          width: 200,
                                          child: Row(
                                            children: <Widget>[
                                              Flexible(
                                                child: TextField(
                                                  keyboardType: TextInputType.text,
                                                  controller: _controllerCampoNome,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Nome",
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align( // ícone que vai chamar a tela pra editar
                                alignment: Alignment.centerRight,
                                child: Container(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: laranja,
                                      size: 30,
                                    ),
                                    //onPressed: PREENCHER ,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row( //numero do celular do user
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Align( //título
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Celular do user',
                                            style: TextStyle(
                                                color: laranja,
                                                fontSize: 18.0)),
                                      ),
                                      Align( // conteudo
                                        alignment: Alignment.centerLeft,
                                        child: Text('11 99999-9999',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align( // ícone que vai chamar a tela pra editar
                                alignment: Alignment.centerRight,
                                child: Container(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: laranja,
                                      size: 30,
                                    ),
                                    //onPressed: PREENCHER ,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row( // email do user
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Align( // título
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Email',
                                          style: TextStyle(
                                              color: laranja,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                      Align( // conteúdo
                                        alignment: Alignment.centerLeft,
                                        child:  SizedBox(
                                          width: 150,
                                          child: Row(
                                            children: <Widget>[
                                              Flexible(
                                                child: TextField(
                                                  enabled: false,
                                                  keyboardType: TextInputType.text,
                                                  controller: getEmail(_controllerCampoEmail),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Email",
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ]
                ),
              ),
            )
      ),
    );
  }
}