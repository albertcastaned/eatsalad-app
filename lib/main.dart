// Packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Local imports
import './constants.dart';
import './routes.dart';

// Providers
import './providers/auth.dart';

// Screens
import './screens/HomeScreen.dart';
import './screens/LoginScreen.dart';

Future main() async {
  await DotEnv().load('.env');
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
      providers: [ChangeNotifierProvider(create: (ctx) => Auth())],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.green,
            accentColor: Colors.lightGreen,
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.green,
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          debugShowCheckedModeBanner: false,
          //Theme
          home: FutureBuilder(
            future: auth.isLoggedIn(),
            builder: (ctx, authResult) =>
                authResult.connectionState == ConnectionState.waiting
                    ? CircularProgressIndicator()
                    : authResult.data
                        ? HomeScreen()
                        : LoginScreen(),
          ),
          routes: routes,
        ),
      ),
    );
  }
}
