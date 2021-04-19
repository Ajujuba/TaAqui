class Localizacao{
  String _rua;
  double _latitude;
  double _longitude;
  String _cep;

  Localizacao(){

  }

  String get cep => _cep;

  set cep(String value) {
    _cep = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  String get rua => _rua;

  set rua(String value) {
    _rua = value;
  }
}