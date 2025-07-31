import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'app_module.dart';
import 'app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 // runApp(ModularApp(module: AppModule(), child: const AppWidget()));
 runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Where's My Bus?",
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.green[800],
        colorScheme: ColorScheme.dark(
          primary: Colors.green[800]!,
          secondary: Colors.amber[600]!, // Gold/yellow
//onSurface: Colors.black,
          surface: Colors.black,
          onPrimary: Colors.black, // Text color on green
          onSecondary: Colors.black, // Text color on gold
          onSurface: Colors.white,
         // onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: SignInPage(),
      debugShowCheckedModeBanner: false,
      //theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
     // ),
    //  home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Text(
                  "Where's My Bus?",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Arial', // You can change the font
                  ),
                ),
              ),
            ),

            // Spacer
            SizedBox(),

            // Buttons at the bottom

            Padding(
               padding: const EdgeInsets.only(bottom: 40.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                 // Image.asset(
                 //   'assets/wheresmybuslogo.jpg',
                  // height: 120, 
                  // fit: BoxFit.contain,
//),
                  Expanded(
                    child: SizedBox(
                       height: MediaQuery.of(context).size.height * 0.45, // half of the screen
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                           Navigator.push(
                            context,
                          MaterialPageRoute(builder: (context) => const PassengerPage()),
  );
                        },
                        child: Text(
                          "Sign in as a     Passenger",
                          style: TextStyle(fontSize:24, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                       height: MediaQuery.of(context).size.height * 0.45, // half of the screen
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                             MaterialPageRoute(builder: (context) => const BusDriverSignInPage()),
                          
                          );
                        },
                        child: Text(
                          "Sign in as a Bus Driver",
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  } 
}

class BusDriverSignInPage extends StatelessWidget {
  const BusDriverSignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Bus Driver Page"),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                    ),
                    onPressed: () {},
                    child: const Text("Depart",  style: TextStyle(fontSize: 24, color: Colors.black),),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[500],
                        ),
                    onPressed: () {},
                    child: const Text("Full Bus",  style: TextStyle(fontSize: 24, color: Colors.white),),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                        ),
                    onPressed: () {},
                    child: const Text("Report Road Closure",  style: TextStyle(fontSize: 24, color: Colors.black),),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                    onPressed: () {},
                    child: const Text("Settings",  style: TextStyle(fontSize: 24, color: Colors.black),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class PassengerPage extends StatefulWidget {
  const PassengerPage({Key? key}) : super(key: key);

  @override
  _PassengerPageState createState() => _PassengerPageState();
}

class _PassengerPageState extends State<PassengerPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _favoriteRoutes = [];

  void _addRouteToFavorites(String route) {
    if (route.isNotEmpty && !_favoriteRoutes.contains(route)) {
      setState(() {
        _favoriteRoutes.add(route);
      });
    }
    _searchController.clear();
  }

  void _removeRoute(String route) {
    setState(() {
      _favoriteRoutes.remove(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Passenger Dashboard"),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Passenger!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search bus routes...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          _addRouteToFavorites(_searchController.text.trim());
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              "Favourite Routes:",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: _favoriteRoutes.isEmpty
                  ? const Center(
                      child: Text(
                        "No favourite routes yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _favoriteRoutes.length,
                      itemBuilder: (context, index) {
                        final route = _favoriteRoutes[index];
                        return Card(
                          color: Colors.green[900],
                          child: ListTile(
                            title: Text(route,
                                style: const TextStyle(color: Colors.white)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _removeRoute(route),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Settings floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to settings page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings tapped!')),
          );
        },
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.settings, color: Colors.black),
      ),
    );
  }
}



/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

*/
