import 'package:flutter/material.dart';
import 'quran_audio_player.dart';
import 'api_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Quran Sync App")),
        body: LinkInputPage(),
      ),
    );
  }
}

class LinkInputPage extends StatefulWidget {
  @override
  _LinkInputPageState createState() => _LinkInputPageState();
}

class _LinkInputPageState extends State<LinkInputPage> {
  final controller = TextEditingController();
  bool loading = false;
  String? audioUrl;
  List<Map<String, dynamic>> segments = [];

  @override
  Widget build(context) => Padding(
    padding: EdgeInsets.all(16),
    child: Column(children: [
      TextField(controller: controller, decoration: InputDecoration(labelText: "YouTube URL")),
      SizedBox(height: 10),
      ElevatedButton(
        onPressed: loading ? null : () async {
          setState(() => loading = true);
          final res = await ApiClient().process(controller.text);
          setState(() {
            audioUrl = res["audio_url"];
            segments = List<Map<String, dynamic>>.from(res["ayah_segments"]);
            loading = false;
          });
        },
        child: loading ? CircularProgressIndicator() : Text("Process")
      ),
      if (audioUrl != null) Expanded(child: QuranAudioPlayer(audioUrl: audioUrl!, ayahSegments: segments)),
    ]),
  );
}
