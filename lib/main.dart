import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AJ IPTV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.blueAccent),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(username: _userController.text, password: _passController.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('AJ IPTV', style: TextStyle(fontSize: 40, color: Colors.blueAccent)),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(onPressed: _login, child: const Text('دخول')),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String username, password;
  const HomeScreen({super.key, required this.username, required this.password});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> streams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStreams();
  }

  Future<void> fetchStreams() async {
    final res = await http.get(Uri.parse('http://Maveniptv.tv:2095/player_api.php?username=${widget.username}&password=${widget.password}&action=get_live_streams'));
    if (res.statusCode == 200) setState(() { streams = jsonDecode(res.body); isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قنوات مباشرة')),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: streams.length,
        itemBuilder: (context, index) {
          final item = streams[index];
          return ListTile(
            title: Text(item['name'] ?? ''),
            onTap: () {
              final url = 'http://Maveniptv.tv:2095/live/${widget.username}/${widget.password}/${item['stream_id']}.m3u8';
              Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(url: url)));
            },
          );
        },
      ),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  final String url;
  const PlayerScreen({super.key, required this.url});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    player.open(Media(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Video(controller: controller, controls: MaterialVideoControls)),
    );
  }
}
