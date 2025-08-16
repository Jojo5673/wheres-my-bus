class LocationServiceDisabledException implements Exception {
  final String message;
  
  const LocationServiceDisabledException([this.message = 'Location services are disabled']);
  
  @override
  String toString() => message;
}

class LocationPermissionException implements Exception {
  final String message;
  final bool isPermanentlyDenied;
  
  const LocationPermissionException(this.message, {this.isPermanentlyDenied = false});
  
  @override
  String toString() => message;
}