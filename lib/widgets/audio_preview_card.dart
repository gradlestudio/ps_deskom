import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPreviewCard extends StatefulWidget {
  final String caminhoArquivo;
  final String nomeArquivo;

  const AudioPreviewCard({
    super.key,
    required this.caminhoArquivo,
    required this.nomeArquivo,
  });

  @override
  State<AudioPreviewCard> createState() => _AudioPreviewCardState();
}

class _AudioPreviewCardState extends State<AudioPreviewCard> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isMuted = false;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _durationSubscription = _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _positionSubscription = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _playerStateSubscription = _player.onPlayerStateChanged.listen((s) {
      if (mounted) {
        setState(() {
          _isPlaying = s == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.caminhoArquivo));
    }
  }

  Future<void> _toggleMute() async {
    final nextMute = !_isMuted;
    await _player.setVolume(nextMute ? 0.0 : 1.0);
    if (mounted) setState(() => _isMuted = nextMute);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF3F3F46)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.music_note, color: Color(0xFF0078D4), size: 28),
              SizedBox(width: 6),
              Text(
                'Reprodutor de Áudio',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 3,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: Color(0xFF0078D4),
              inactiveTrackColor: Color(0xFF333333),
              thumbColor: Color(0xFF0078D4),
            ),
            child: Slider(
              min: 0.0,
              max: _duration.inMilliseconds.toDouble() > 0
                  ? _duration.inMilliseconds.toDouble()
                  : 1.0,
              value: _position.inMilliseconds.toDouble().clamp(
                    0.0,
                    _duration.inMilliseconds.toDouble() > 0
                        ? _duration.inMilliseconds.toDouble()
                        : 1.0,
                  ),
              onChanged: (val) async {
                final pos = Duration(milliseconds: val.toInt());
                await _player.seek(pos);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(fontSize: 9, color: Color(0xFF888888)),
                ),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(fontSize: 9, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: const Color(0xFF0078D4),
                  size: 32,
                ),
                onPressed: _togglePlay,
                tooltip: _isPlaying ? 'Pausar' : 'Reproduzir',
              ),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: const Color(0xFFCCCCCC),
                  size: 20,
                ),
                onPressed: _toggleMute,
                tooltip: _isMuted ? 'Ativar som' : 'Mudar volume (Mute)',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
