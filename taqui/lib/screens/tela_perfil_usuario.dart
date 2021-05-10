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
  final TextEditingController _controllerCampoNumCel = TextEditingController();
  final TextEditingController _controllerCampoNumTel = TextEditingController();

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
      String usuarioLogado = auth.currentUser.uid.toString();
      _idUsuarioLogado = usuarioLogado;
      print(" uid: $usuarioLogado");
      final ext = ".jpg";
      String nome_img = ("$_idUsuarioLogado" + ext);
      String fileName = basename(
          imagem.path); //pegando apenas o nome da img e não o caminho inteiro
      firebase_storage.Reference firebaseStorageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('foto_perfil')
          .child(nome_img); //obtem referencia ao nome do arquivo
      firebase_storage.UploadTask uploadTask =
          firebaseStorageRef.putFile(imagem); // inserindo o arquivo no firebase
      firebase_storage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => setState(() {
                if (uploadTask != null) {
                  FirebaseAuth auth = FirebaseAuth.instance;
                  String email = auth.currentUser.email.toString();
                  CollectionReference user =
                      FirebaseFirestore.instance.collection("usuarios");
                  //Alterar nome do doc de email pra UID ao finalizar o prj!!!
                  user.doc(email).update({'foto_perfil': nome_img});
                }
                print("Foto de perfil atualizada");
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Foto de perfil atualizada')));
              }));
      //Recuperar url da imagem
      taskSnapshot.ref.getDownloadURL().then((value) => print("Done: $value"));
      recuperarUrlFotoPerfil();
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao Atualizar foto de perfil')));
    }
  }

  Future<void> recuperarUrlFotoPerfil() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String usuarioLogado = auth.currentUser.uid.toString();
    _idUsuarioLogado = usuarioLogado;
    final ext = ".jpg";
    String caminho = ("foto_perfil/$_idUsuarioLogado"+ ext);
    String url = await firebase_storage.FirebaseStorage.instance
        .ref(caminho)
        .getDownloadURL();
    _atualizarUrlImagemFirestore( url );
    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarUrlImagemFirestore(String url){

    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    String email = auth.currentUser.email.toString();
    Map<String, dynamic> dadosAtualizar = {
      "foto_perfil" : url
    };

    db.collection("usuarios")
        .doc(email)
        .update( dadosAtualizar );
  }

  _atualizarNomeFirestore(BuildContext context){
    String nome = _controllerCampoNome.text;
    FirebaseAuth auth = FirebaseAuth.instance;
    String email = auth.currentUser.email.toString();
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> dadosAtualizar = {
      "nome" : nome
    };
    db.collection("usuarios")
        .doc(email)
        .update( dadosAtualizar );

    print("Nome de perfil atualizado");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nome atualizado!')));
  }

  _atualizarCelularFirestore(BuildContext context){
    String celular = _controllerCampoNumCel.text;
    FirebaseAuth auth = FirebaseAuth.instance;
    String email = auth.currentUser.email.toString();
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> dadosAtualizar = {
      "numCell" : celular
    };
    db.collection("usuarios")
        .doc(email)
        .update( dadosAtualizar );

    print("Celular de perfil atualizado");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nº de celular atualizado!')));
  }

  _recuperarDadosUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    String usuarioLogado = auth.currentUser.uid.toString();
    _idUsuarioLogado = usuarioLogado;
    String email = auth.currentUser.email.toString();
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios")
        .doc(email)
        .get();

    Map<String, dynamic> dados = snapshot.data();
    _controllerCampoNome.text = dados["nome"];
    _controllerCampoNumCel.text = dados["numCell"];

    if( dados["foto_perfil"] != null ){
      _urlImagemRecuperada = dados["foto_perfil"];
      print(_urlImagemRecuperada);
    }

  }

  getEmail(_controllerCampoEmail) {
    FirebaseAuth auth = FirebaseAuth.instance;
    String email = auth.currentUser.email.toString();
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference docRef = db.collection("usuarios").doc(email);
    docRef.get();
    this._controllerCampoEmail.text = email;
    return _controllerCampoEmail;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    recuperarUrlFotoPerfil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // define um titulo pra tela
        title: Text(_tituloAppBar),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app_outlined,
              color: Colors.white,
            ),
            onPressed: () {

            },
          )
        ],
      ),
      body: Builder(
          builder: (context) => SingleChildScrollView(
                child: Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          // define o retangulo laranja onde a foto vai aparecer
                          width: MediaQuery.of(context).size.width,
                          height: 270,
                          decoration: BoxDecoration(
                            // define que a cor é laranja
                            color: laranja,
                            borderRadius: BorderRadius.only(
                              // define bordas inferiores arredondadas
                              bottomRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                // linha onde estão os elementos do container de fundo laranja
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    // define icone e função da galeria
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
                                  Align(
                                    // posicionamento/layout da img de perfil
                                    alignment: Alignment.center,
                                    child: CircleAvatar(
                                      // define a borda da img
                                      radius: 100,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 90,
                                          backgroundImage: _urlImagemRecuperada != null
                                          ? NetworkImage(_urlImagemRecuperada)
                                          : NetworkImage(
                                            "https://us.123rf.com/450wm/urfandadashov/urfandadashov1809/urfandadashov180901275/109135379-.jpg?ver=6"
                                          ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    // define icone e função  da camera
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
                              Row(
                                //botão pra salvar a foto de perfil
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
                        Row(
                          //definindo os dados do perfil
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              // email do user
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Align(
                                  // título
                                  alignment: Alignment.center,
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Email',
                                            style: TextStyle(
                                                color: laranja,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0),
                                          ),
                                        ),
                                        Container(
                                          width: 250,
                                          child: Align(
                                            // conteúdo
                                            alignment: Alignment.center,
                                            child: SizedBox(

                                              child: Row(
                                                children: <Widget>[
                                                  Flexible(
                                                    child: TextFormField(
                                                      enabled: false,
                                                      keyboardType:
                                                      TextInputType.text,
                                                      controller:
                                                      getEmail(_controllerCampoEmail),
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: "Informe o Email",
                                                        hintStyle: TextStyle(
                                                            color: Colors.grey),
                                                        contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 8),
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  // ícone que vai chamar a tela pra editar
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.email,
                                          color: laranja,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                        }
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
                        Row(
                          //definindo os dados do perfil
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              // nome do user
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Align(
                                  // título
                                  alignment: Alignment.center,
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Nome',
                                            style: TextStyle(
                                                color: laranja,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0),
                                          ),
                                        ),
                                        Container(
                                          child: Align(
                                            // conteúdo
                                            alignment: Alignment.centerLeft,
                                            child: SizedBox(
                                              width: 250,
                                              child: Row(
                                                children: <Widget>[
                                                  Flexible(
                                                    child: TextFormField(
                                                      keyboardType:
                                                      TextInputType.text,
                                                      controller:
                                                      _controllerCampoNome,
                                                      decoration: InputDecoration(
                                                        //border: InputBorder.none,
                                                        hintText: "Informe o Nome",
                                                        hintStyle: TextStyle(
                                                            color: Colors.grey),
                                                        contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 8),
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  // ícone que vai chamar a tela pra editar
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: laranja,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        _atualizarNomeFirestore(context);
                                      }
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
                        Row(
                          //numero do celular do user
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Align(
                                  //título
                                  alignment: Alignment.center,
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text('Nº Celular',
                                              style: TextStyle(
                                                  color: laranja,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0)),
                                        ),
                                        Align(
                                          // conteúdo
                                          alignment: Alignment.centerLeft,
                                          child: SizedBox(
                                            width: 250,
                                            child: Row(
                                              children: <Widget>[
                                                Flexible(
                                                  child: TextField(
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    _controllerCampoNumCel,
                                                    decoration: InputDecoration(
                                                      //border: InputBorder.none,
                                                      hintText: "Informe o Nº Celular",
                                                      hintStyle: TextStyle(
                                                          color: Colors.grey),
                                                      contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 8,
                                                          horizontal: 8),
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
                                Align(
                                  // ícone que vai chamar a tela pra editar
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: laranja,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        _atualizarCelularFirestore(context);
                                      }
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                  ),
                ),

              )),
    );
  }
}
