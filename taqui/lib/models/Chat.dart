import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Chat{
  String _idRemetente; //vai alterar depois
  String _idDestinatario;
  String _nome;
  String _mensagem;
  String _caminhoFoto;
  String _tipoMensagem;

  Chat();

  Chat.named(this._idRemetente, this._idDestinatario, this._nome,  this._mensagem, this._caminhoFoto, this._tipoMensagem);

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "idRemetente": this._idRemetente,
      "idDestinatario": this._idDestinatario,
      "nome": this._nome,
      "mensagem": this._mensagem,
      "caminhoFoto": this._caminhoFoto,
      "tipoMensagem": this._tipoMensagem
    };
    return map;
  }

  salvar() async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("conversas")
      .doc(this.idRemetente)
      .collection("ultima_conversa")
      .doc(this.idDestinatario)
      .set(this.toMap());
  }

  String get caminhoFoto => _caminhoFoto;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idDestinatario => _idDestinatario;

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  String get idRemetente => _idRemetente;

  set idRemetente(String value) {
    _idRemetente = value;
  }

  String get tipoMensagem => _tipoMensagem;

  set tipoMensagem(String value) {
    _tipoMensagem = value;
  }
}