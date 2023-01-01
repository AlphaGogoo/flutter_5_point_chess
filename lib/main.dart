import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_syncer/model/network_model.dart';
import 'package:sms_syncer/model/server_model.dart';
import 'package:sms_syncer/pages/game_client_page.dart';
import 'package:sms_syncer/pages/game_server_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'utils/wp_http.dart';
void main() {
  DioHttpUtil().init();
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(NetworkSvc());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chess Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '下棋游戏'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String choices = "";
  TextEditingController promptController =
      TextEditingController(text: "你好");
  TextEditingController choicesController = TextEditingController();

  //使用audio_player 1.0版本播放音乐

  AudioPlayer audioPlayer = AudioPlayer();

  late final AnimationController _controller;

  late final Animation<double> _animation;
  // AudioCache audioCache = AudioCache();
  double _x = 100;
  double _y = 100;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    audioPlayer.play(AssetSource("audio/music.mp3"));
    audioPlayer.setReleaseMode(ReleaseMode.loop);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context)?.insert(_entry());
    });
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Text(
                "游戏菜单",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
              ),
              Expanded(
                child: Column(
                  children: [
                    // 文字输入框
                    LimitedBox(
                        maxHeight: 200,
                        child: TextField(
                          controller: promptController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: '请输入文字',
                          ),
                        )),
//                  按钮
                    ElevatedButton(
                      onPressed: () async {
                        var res =
                            await DioHttpUtil().post("/completions", data: {
                          "model": "text-davinci-003",
                          "prompt": promptController.text,
                          "temperature": 1,
                          "max_tokens": 1024,
                        });
                        if (res.data["choices"] != null) {
                          choicesController.text =
                              res.data["choices"][0]["text"];
                        }
                      },
                      child: const Text("提问"),
                    ),
                    // 显示 json 数据
                    Expanded(
                      child: TextField(
                        controller: choicesController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: '显示数据',
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add_circle_outline),
                      label: Text("创建房间", style: TextStyle(fontSize: 30)),
                      onPressed: () {
                        _handleOpenRoom();
                      },
                    ),
                    //高度为10的透明组件
                    SizedBox(
                      height: 10,
                    ),

                    OutlinedButton.icon(
                      icon: Icon(Icons.search_outlined),
                      label: Text("加入房间", style: TextStyle(fontSize: 30)),
                      onPressed: () {
                        _handleJoinGame();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  //全局可拖拽悬浮按钮
  OverlayEntry _entry() {
    return OverlayEntry(builder: (context) {
      return Positioned(
          width: 48,
          height: 48,
          left: _x,
          top: _y,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _x += details.delta.dx;
                _y += details.delta.dy;
              });
            },

            //悬浮按钮 控制音乐
            child: FloatingActionButton(
              onPressed: _handleMusic,
              //删除阴影style
              elevation: 0,
              child: RotationTransition(
                turns: _animation,
                child: Icon(Icons.music_note),
              ),
            ),
          ));
    });
  }

  void _handleMusic() {
    if (audioPlayer.state == PlayerState.playing) {
      audioPlayer.pause();
      _controller.stop();
    } else {
      audioPlayer.resume();
      _controller.repeat();
    }
  }

  void _handleJoinGame() {
    Get.to(() => const GameClientPage());
  }

  void _handleOpenRoom() {
    var serverName = "";
    Get.defaultDialog(
        title: '请输入房间名',
        content: Container(
          child: Column(
            children: [
              TextField(
                onChanged: (s) {
                  serverName = s;
                },
              )
            ],
          ),
        ),
        onConfirm: () {
          if (serverName.isEmpty) {
            Get.snackbar('错误', '房间名不能为空');
            return;
          }
          Get.back();
          Get.defaultDialog(
              title: '正在创建房间，请稍等',
              content: Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ));
          ServerModel.start(serverName).then((model) async {
            Get.back();
            if (model == null) {
              Get.snackbar('错误', '创建房间失败，请重试');
            } else {
              Get.put<ServerModel>(model);
              Get.to(() => const GameServerPage());
            }
          });
        });
  }
}
