// Packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

// Local imports
import './constants.dart';
// Providers
import './providers/auth.dart';
import './providers/items.dart';
import './routes.dart';
import 'providers/address.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'providers/payment_methods.dart';
import 'providers/restaurants.dart';
// Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future main() async {
  await DotEnv().load('.env');
  await Firebase.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  print("Server: $server");
  runApp(EatApp());
}

class EatApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(
            auth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Restaurants(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CategoriesProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SelectedAddress(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PaymentMethods(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Orders(),
        ),
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
