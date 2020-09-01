import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import './home.dart';
import './store/workout_store.dart';

Future<void> main() async {
  await DotEnv().load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => WorkoutStore(),
        child: MaterialApp(
          title: 'Timer Xrd',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routes: <String, WidgetBuilder>{
            '/': (_) => EntrancePage(),
            '/home': (_) => HomePage(),
          },
        ));
  }
}

class EntrancePage extends StatefulWidget {
  @override
  _EntrancePageState createState() => _EntrancePageState();
}

class _EntrancePageState extends State<EntrancePage> {
  bool hasError;

  @override
  void initState() {
    super.initState();
    hasError = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        await Provider.of<WorkoutStore>(context, listen: false).loadValue();
        Navigator.of(context).pushReplacementNamed("/home");
      } catch (_) {
        setState(() {
          hasError = true;
        });
        rethrow;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Timer Xrd'));

    if (hasError) {
      return Scaffold(
        appBar: appBar,
        body: const Center(
            child: Text('Failed to load.', style: TextStyle(fontSize: 36))),
      );
    }

    return Scaffold(
        appBar: appBar,
        body: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(children: const [
            Center(
              widthFactor: 20.0,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Loading...',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ]),
        ));
  }
}
