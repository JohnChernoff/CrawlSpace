import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:space_fugue/fugue_model.dart';
import 'package:space_fugue/views/ascii_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'galaxy.dart';
import 'views/galaxy_view.dart';
import 'options.dart';

/*
TODO: savefiles, autoscroll tweaks, mobile imgs, organize costs/etc.,
!trade mission generation rnd bug (also investigate amounts)
!missing plugin error for url_launcher
~fix scrolling
~victory handling
distance to homeworld influence,
special planets (all - => lower heat, all +++ => higher heat)
find system feature, center system when clicked?
system notes
system shapes
 */

final AudioPlayer fuguePlayer = AudioPlayer();
PlayerOptions fugueOptions = PlayerOptions();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, // Left-side Landscape]);
  runApp(const FugueApp());
}

class FugueApp extends StatelessWidget {
  const FugueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: CustomScrollBehavior(),
      title: 'Space Fugue',
      theme: ThemeData(colorSchemeSeed: Colors.brown), //ThemeData.dark(useMaterial3: true),
      home: const FugueHome(title: 'Space Fugue'),
    );
  }
}

enum ViewState {game,map,options}

class FugueHome extends StatefulWidget {
  const FugueHome({super.key, required this.title});
  final String title;

  @override
  State<FugueHome> createState() => _FugueHomeState();
}

class _FugueHomeState extends State<FugueHome> {
  FugueModel? fugueModel; //GalaxyView? galaxyView;
  bool loading = false;
  ViewState view = ViewState.game;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }
  
  @override
  Widget build(BuildContext context) { //print("Building Main Widget");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(widget.title, style: const TextStyle(color: Colors.white)),
          helpButton(),
          optionButton(),
        ])
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("img/splash_land.png"),fit: BoxFit.fill),
        ),
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (fugueModel == null)
              ? preGameColumn()
              : gameColumn(),
        ),
      ),
    ));
  }

  List<Widget> gameColumn() {
    return [
      Expanded(child: ListenableBuilder(
        listenable: fugueModel!,
        builder: (BuildContext context, Widget? child) => Column(children: [
          if (fugueModel!.gameOver) gameOver(),
          //Expanded(child: GalaxyView(fugueModel!,key: ValueKey(fugueModel))),
          Expanded(child: AsciiView(fugueModel!,key: ValueKey(fugueModel))),
        ]),
      )),
    ];
  }

  List<Widget> preGameColumn() {
    return [
      const SizedBox(height: 24),
      newGameButton(),
    ];
  }

  Widget newGameButton() {
    return ElevatedButton(
        onPressed: _initGame,
        child: const Text('New Game')
    );
  }

  Widget helpButton({isNewTab = true}) {
    return ElevatedButton(
        onPressed: () => launchUrl(Uri.parse('https://spacefugue.online/help/overview.html'),webOnlyWindowName: isNewTab ? '_blank' : '_self',),
        child: kIsWeb ? const Text('Help') : const Icon(Icons.help)
    );
  }

  Widget optionButton() {
    return ElevatedButton(
      onPressed: _editPlayerOptions,
      child: kIsWeb ? const Text('Options') : const Icon(Icons.settings),
    );
  }

  void _updateSound() { //print("Updating sound... ${fugueOptions.getBool(FugueOption.sound)}");
    if (fugueOptions.getBool(FugueOption.sound)) {
      if (fuguePlayer.state != PlayerState.playing) fuguePlayer.play(AssetSource("audio/tracks/intro1.mp3"));
    } else {
      fuguePlayer.stop();
    }
  }

  void _editPlayerOptions() async {
    if (!context.mounted) return; // Check if widget is still in the tree
    final updated = await showPlayerOptionsDialog(context, fugueOptions);
    if (updated != null) {
      await updated.save();
      if (!context.mounted) return;
      setState(() {
        fugueOptions = updated;
      }); //print("Saved: ${fugueOptions.map}");
      _updateSound();
    }
  }

  void _loadOptions() async {
    setState(() { loading = true; });
    await fugueOptions.load();
    setState(() { loading = false; });
  }

  Widget gameOver() {
    return ColoredBox(color: Colors.black, child:
        Column(children: [
          Text("You were ${fugueModel?.result}",
              style: const TextStyle(color: Colors.white)), //const Text("*** SCORE ***"),
          Text("Turns (1 pt each): ${fugueModel?.auTick}",
              style: const TextStyle(color: Colors.green)),
          Text("Discovered ${fugueModel?.galaxy.discoveredSystems()} systems (2 pts each)",
              style: const TextStyle(color: Colors.blue)),
          Text("Pirates vanquished (3 pts each): ${fugueModel?.player.piratesVanquished}",
              style: const TextStyle(color: Colors.grey)),
          Text("Found Star One (500 pts): ${fugueModel?.player.starOne}",
              style: const TextStyle(color: Colors.orange)),
          Text("Victory (1000 pts): ${fugueModel?.victory}",
              style: const TextStyle(color: Colors.purpleAccent),),
          Text("Score: ${fugueModel?.score()}"
              ,style: const TextStyle(color: Colors.white)),
          newGameButton(),
      ]));
  }

  void _initGame() {
    _updateSound();
    fugueModel = FugueModel(Galaxy("FooBar"), "Zug");
    setState(() {
      view = ViewState.game;
    });
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
