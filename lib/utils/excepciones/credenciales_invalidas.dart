/// Clase para controlar la excepcion de contraseña incorrecta
class CredenciaslesInvalidasException implements Exception {
  final String message;
  CredenciaslesInvalidasException(this.message);
  @override
  String toString() => message;
}

