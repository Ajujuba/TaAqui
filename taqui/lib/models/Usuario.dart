class Usuario{
  String _idUsuario;
  String _nome;
  String _email;
  String _urlImagem;
  String _senha;

  Usuario();

  Usuario.named(this._nome, this._email, this._urlImagem, this._idUsuario);

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "nome": this._nome,
      "email": this._email
    };
    return map;
  }
  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }
}