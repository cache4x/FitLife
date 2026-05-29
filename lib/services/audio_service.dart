import 'package:audioplayers/audioplayers.dart';

// Serviço para reprodução de efeitos sonoros no aplicativo
class AudioService {
  // Padrão Singleton para ter uma única instância controlando a reprodução de áudio
  static final AudioService _instance = AudioService._();
  AudioService._();
  factory AudioService() => _instance;

  // Instancia o player de áudio do pacote audioplayers
  final AudioPlayer _player = AudioPlayer();

  // Toca o som de treino finalizado (deve haver arquivo em assets/sounds/)
  Future<void> playWorkoutDone()  async => _play('workout_done.mp3');
  
  // Toca o som de novo recorde de carga batido
  Future<void> playNewRecord()    async => _play('new_record.mp3');
  
  // Toca o som de sucesso ao realizar login
  Future<void> playLoginSuccess() async => _play('login_success.mp3');

  // Método genérico privado que para o áudio atual e inicia o novo áudio do asset
  Future<void> _play(String fileName) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (_) {
      // Ignora silenciosamente se o arquivo de áudio não for encontrado nos assets
    }
  }

  // Libera os recursos de memória do player quando não for mais usado
  void dispose() => _player.dispose();
}
