// Packages
import 'package:EatSalad/providers/restaurants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Local imports
import './constants.dart';
import './routes.dart';

// Providers
import './providers/auth.dart';
import './providers/items.dart';

// Screens
import './screens/HomeScreen.dart';
import './screens/LoginScreen.dart';

Future main() async {
  await DotEnv().load('.env');
  await Firebase.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  print("Server: ${Constants.server}");
  runApp(EatApp());
}

class EatApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProvider(create: (ctx) => RestaurantProvider()),
        ChangeNotifierProvider(create: (ctx) => CategoriesProvider()),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          theme: ThemeData(
            primaryColor: Color(0xff00c853),
            accentColor: Colors.lightGreen,
            buttonTheme: ButtonThemeData(
              buttonColor: Color(0xff00c853),
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          debugShowCheckedModeBanner: false,
          //Theme
          home: auth.isLoggedIn ? HomeScreen() : LoginScreen(),
          routes: routes,
        ),
      ),
    );
  }
}
