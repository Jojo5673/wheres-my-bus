import 'package:flutter_modular/flutter_modular.dart';
import 'modules/landing/landing_module.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ModuleRoute('/', module: LandingModule()),
  ];
}