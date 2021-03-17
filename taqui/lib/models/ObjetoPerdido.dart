import 'package:flutter/material.dart';
import 'package:taqui/enums/StatusObjeto.dart';
import 'dart:io';

class ObjetoPerdido{

  String _localizacao; //Posteriormente haverá uma classe especifica para localizaco
  String _descricao;
  List<File> _imagens = [];
  StatusObjeto _status;

  ObjetoPerdido(this._localizacao, this._descricao);

  StatusObjeto get status => _status;

  set status(StatusObjeto value) {
    _status = value;
  }

  List<File> get imagens => _imagens;

  set imagens(List<File> value) {
    _imagens = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get localizacao => _localizacao;

  set localizacao(String value) {
    _localizacao = value;
  }
}