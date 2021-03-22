import 'package:flutter/material.dart';

import 'ObjetoPerdido.dart';

class Chat{
  String _nome1; //vai alterar depois
  String _nome2;
  String _mensagem;
  String _caminhoFoto;
  DateTime _dataCriacao;
  List<String> _mensagens; //vai alterar depois
  ObjetoPerdido _objetoPerdido;

  Chat(this._nome1, this._nome2, this._dataCriacao, this._objetoPerdido, this._mensagem, this._caminhoFoto);

  ObjetoPerdido get objetoPerdido => _objetoPerdido;

  set objetoPerdido(ObjetoPerdido value) {
    _objetoPerdido = value;
  }

  List<String> get mensagens => _mensagens;

  set mensagens(List<String> value) {
    _mensagens = value;
  }

  DateTime get dataCriacao => _dataCriacao;

  set dataCriacao(DateTime value) {
    _dataCriacao = value;
  }

  String get nome2 => _nome2;

  set nome2(String value) {
    _nome2 = value;
  }

  String get nome1 => _nome1;

  set nome1(String value) {
    _nome1 = value;
  }
  String get caminhoFoto => _caminhoFoto;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }
}