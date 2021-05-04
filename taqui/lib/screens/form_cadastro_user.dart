import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'form_login.dart';

Future<void> showInformationDialog(BuildContext context, String txt) async{
  return await showDialog(context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Aviso!"),
          content: Text(txt),
          actions: <Widget>[
            TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Login();
                  }));
                },
                child: Text("Ok"))
          ],
        );
      });
}

Future<void> showErrorDialog(BuildContext context, String txt) async{
  return await showDialog(context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Erro!"),
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

const _tituloAppBar = 'Cadastro de Usuário';

class CadastroUser extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return CadastroUserState();
  }
}

class CadastroUserState extends State<CadastroUser> {
  GlobalKey<FormState> _key = new GlobalKey(); // chave
  bool _validate = false;

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

  String _validarNome(String value) {
    if (value.length == 0) {
      return "Informe o nome";
    }
    if (value.length < 8) {
      return "Informe o nome completo";
    }
  }

  String _validarData(String value) {
    if (value.length == 0) {
      return "Informe a data de nascimento";
    }
    
  }

  String _validarEmail(String value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Informe o email";
    } else if(!regExp.hasMatch(value)){
      return "Email inválido";
    }else {
      return null;
    }
  }

  String _validarCelular(String value) {
    if (value.length == 0 || value.length < 15) {
      return "Informe o número de celular";
    }
  }

  String _validarTelefone(String value) {
    if (value.length == 0 || value.length < 14) {
      return "Informe o número de telefone";
    }
  }

  String _validarCpf(String value) {
    if (value.length == 0 || value.length < 14) {
      return "Informe o número do CPF";
    }
  }

  String _validarSenha(String value) {
    if (value.length == 0) {
      return "Preencha uma senha";
    }
  }

  String _validarConfirmaSenha(String value) {
    if (value.length == 0) {
      return "Confirme sua senha";
    }
    if (_controllerCampoSenha.text != _controllerCampoConfirmaSenha.text) {
      return "As senhas não coincidem";
    }
  }

  _sendForm() async {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _key.currentState.save();
      try {
        UserCredential user = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: _controllerCampoEmail.text,
            password: _controllerCampoSenha.text));
        //Caso usuario tenha sido cadastrado
        if (user != null){
          String txt = "Usuário cadastrado com sucesso!";
          showInformationDialog(context, txt);
          inserirUsuario();
        }
      } on FirebaseAuthException catch (e){
        String txt = "Email já cadastrado no sistema!";
        if (e.code == 'weak-password'){
          txt = "A senha cadastrada é muito fraca";
          _controllerCampoSenha.text = "";
          _controllerCampoConfirmaSenha.text = "";
        }else if (e.code == "email-already-in-use") {
          txt = "Já existe uma conta cadastrada neste email";
          _controllerCampoEmail.text = "";
        }
        showErrorDialog(context, txt);
      }
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }

  inserirUsuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    String email2 = auth.currentUser.email.toString();
    print(email2);
    var email = _controllerCampoEmail.text;
    CollectionReference user = FirebaseFirestore.instance.collection("usuarios");
    //Alterar nome do doc de email pra UID ao finalizar o prj!!!
    user.doc(email).set({
      'nome': _controllerCampoNome.text,
      'dataNasc': _controllerCampoDataNasc.text,
      'numCell': _controllerCampoNumCel.text,
      'numTelefone': _controllerCampoNumTel.text,
      'cpf': _controllerCampoCpf.text
    });
    print("");
  }

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
        child: Form(
          key: _key,
          autovalidate: _validate,
          child: _formCadastro(),
        ),
      ),
    );
    }

    Widget _formCadastro(){
      return ListView( // inseri um ListView para permitir scroll na tela
        children: <Widget>[
          TextFormField( // Bloco referente ao input do nome
            keyboardType: TextInputType.text,
            controller: _controllerCampoNome,
            validator: _validarNome,
            onSaved: (String val) {
              _controllerCampoNome.text = val;
            },
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
            validator: _validarData,
            onSaved: (String val) {
              _controllerCampoDataNasc.text = val;
            },
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
            validator: _validarEmail,
            onSaved: (String val) {
              _controllerCampoEmail.text = val;
            },
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
            validator: _validarCelular,
            onSaved: (String val) {
              _controllerCampoNumCel.text = val;
            },
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
            validator: _validarTelefone,
            onSaved: (String val) {
              _controllerCampoNumTel.text = val;
            },
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
            validator: _validarCpf,
            onSaved: (String val) {
              _controllerCampoCpf.text = val;
            },
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
            validator: _validarSenha,
            onSaved: (String val) {
              _controllerCampoSenha.text = val;
            },
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
            validator: _validarConfirmaSenha,
            onSaved: (String val) {
              _controllerCampoConfirmaSenha.text = val;
            },
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
                onPressed:  ()async{
                  _sendForm();
                  String email = _controllerCampoEmail.text;
                  String nome = _controllerCampoNome.text;
                  String data = _controllerCampoDataNasc.text;
                  Map map = {'nome': nome,'email': email};
                },
              ),
            ),
          ),
        ],
      );
    }
}