import 'package:flutter_modular/flutter_modular.dart';
import 'landing_page.dart';
import 'landing_store.dart';

class LandingModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.lazySingleton((i) => LandingStore()),
  ];

  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (_, __) => const LandingPage()),
  ];
}