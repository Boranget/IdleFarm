import 'package:my_flutter/entity/crop_data.dart';
import 'package:my_flutter/state/global_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class IdleFarmApp extends StatelessWidget {
  const IdleFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: MaterialApp(
        title: '挂机种地',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var globalState = context.watch<GlobalState>();
    return Scaffold(
      body: Column(
        children: [
          Text('A random idea:'),
          ElevatedButton(
            onPressed: () {
              globalState.ripeList.printPlantList();
            },
            child: Text('print'),
          ),
          ElevatedButton(
            onPressed: () {
              globalState.plantCrop(apple, 5);
              globalState.plantCrop(banana, 3);
              globalState.plantCrop(orange, 2);
            },
            child: Text('plant'),
          ),
        ],

      ),
    );
  }
}
