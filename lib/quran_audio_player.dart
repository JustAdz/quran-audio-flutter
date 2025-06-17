import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class QuranAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final List<Map<String, dynamic>> ayahSegments;

  const QuranAudioPlayer({
    required this.audioUrl,
    required this.ayahSegments,
    Key? key,
  }) : super(key: key);

  @override
  _QuranAudioPlayerState createState() => _QuranAudioPlayerState();
}

class _QuranAudioPlayerState extends State<QuranAudioPlayer> {
  late AudioPlayer _player;
  int _currentAyahIndex = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    await _player.setUrl(widget.audioUrl);
    _player.positionStream.listen((position) {
      _updateCurrentAyah(position.inMilliseconds / 1000.0);
    });
  }

  void _updateCurrentAyah(double positionSeconds) {
    for (int i = 0; i < widget.ayahSegments.length; i++) {
      final segment = widget.ayahSegments[i];
      if (positionSeconds >= segment['start'] && positionSeconds <= segment['end']) {
        if (_currentAyahIndex != i) {
          setState(() {
            _currentAyahIndex = i;
          });
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAyah = widget.ayahSegments[_currentAyahIndex];

    return Column(
      children: [
        // Audio Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (_player.playing) {
                  _player.pause();
                } else {
                  _player.play();
                }
              },
            ),
            StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Text(
                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                    );
                  },
                );
              },
            ),
          ],
        ),

        // Display Current Ayah Info
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Surah ${currentAyah['surah']}, Ayah ${currentAyah['ayah']}:\n${currentAyah['ayah_text']}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Scrollable list of all ayahs with highlight on current
        Expanded(
          child: ListView.builder(
            itemCount: widget.ayahSegments.length,
            itemBuilder: (context, index) {
              final ayah = widget.ayahSegments[index];
              final isActive = index == _currentAyahIndex;
              return ListTile(
                title: Text(
                  'Surah ${ayah['surah']}, Ayah ${ayah['ayah']}: ${ayah['ayah_text']}',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.black,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  _player.seek(Duration(milliseconds: (ayah['start'] * 1000).toInt()));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
