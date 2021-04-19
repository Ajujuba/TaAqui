import 'package:flutter/material.dart';
import 'package:taqui/enums/StatusObjeto.dart';
import 'dart:io';

import 'package:taqui/models/Localizacao.dart';

class ObjetoPerdido{
  String _id;
  String _descricao;
  Localizacao _endereco;
  String _imagem1;
  String _imagem2;
  String _imagem3;
  String _status;
  String _usuario;

  Map<String, dynamic> toMap(){
    Map<String, dynamic> endereco = {
      "rua": _endereco.rua,
      "latitude": _endereco.latitude,
      "longitude": _endereco.longitude,
      "cep": _endereco.cep
    };
    Map<String, dynamic> dados = {
      "descricao": _descricao,
      "endereco": endereco,
      "imagem1": _imagem1,
      "imagem2": _imagem2,
      "imagem3": _imagem2,
      "status": _status,
      "usuario": _usuario
    };

    return dados;
  }

  ObjetoPerdido(){

  }

  ObjetoPerdido.con(this._endereco, this._descricao);

  String get usuario => _usuario;

  set usuario(String value) {
    _usuario = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get imagem3 => _imagem3;

  set imagem3(String value) {
    _imagem3 = value;
  }

  String get imagem2 => _imagem2;

  set imagem2(String value) {
    _imagem2 = value;
  }

  String get imagem1 => _imagem1;

  set imagem1(String value) {
    _imagem1 = value;
  }

  Localizacao get endereco => _endereco;

  set endereco(Localizacao value) {
    _endereco = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  @override
  String toString() {
    return 'ObjetoPerdido{_id: $_id, _descricao: $_descricao, _endereco: $_endereco, _imagem1: $_imagem1, _imagem2: $_imagem2, _imagem3: $_imagem3, _status: $_status, _usuario: $_usuario}';
  }
}