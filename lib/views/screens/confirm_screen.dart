import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:tiktok_tutorial/controllers/upload_video_controller.dart';
import 'package:tiktok_tutorial/views/screens/home_screen.dart';
import 'package:tiktok_tutorial/views/widgets/text_input_field.dart';
import 'package:video_player/video_player.dart';

class ConfirmScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  const ConfirmScreen({
    Key? key,
    required this.videoFile,
    required this.videoPath,
  }) : super(key: key);

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController controller;
  TextEditingController _songController = TextEditingController();
  TextEditingController _captionController = TextEditingController();

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 2))
        ..repeat();

  String uploadVideoStatus = 'initial';

  String errorMessage = '';

  UploadVideoController uploadVideoController =
      Get.put(UploadVideoController());

  onUploadVideo() async {
    uploadVideoStatus = 'loading';
    try {
      await uploadVideoController.uploadVideo(
          _songController.text, _captionController.text, widget.videoPath);
      setState(() {
        uploadVideoStatus = "success";
      });

      showGeneralDialog(
        context: context,
        barrierColor: Colors.black38,
        barrierLabel: 'Label',
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => WillPopScope(
          onWillPop: () async {
            Get.back();
            Get.back();
            controller.pause();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomeScreen(pageIndex: 4),
            ));
            return true;
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Vídeo salvo com sucesso.",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 40, bottom: 40),
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (_, child) {
                                  return const Icon(Icons.recommend,
                                      size: 100, color: Colors.green);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        uploadVideoStatus = "error";
      });
      Get.snackbar(
        'Error Uploading Video',
        e.toString(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      controller = VideoPlayerController.file(widget.videoFile);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);
    controller.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.5,
              child: VideoPlayer(controller),
            ),
            const SizedBox(
              height: 30,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width - 20,
                    child: TextInputField(
                      controller: _songController,
                      labelText: 'Song Name',
                      icon: Icons.music_note,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width - 20,
                    child: TextInputField(
                      controller: _captionController,
                      labelText: 'Caption',
                      icon: Icons.closed_caption,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        onUploadVideo();
                        showGeneralDialog(
                          context: context,
                          barrierColor: Colors.black38,
                          barrierLabel: 'Label',
                          barrierDismissible: uploadVideoStatus != "loading",
                          pageBuilder: (_, __, ___) => WillPopScope(
                            onWillPop: () async =>
                                uploadVideoStatus != "loading",
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                uploadVideoStatus == "loading"
                                                    ? "O vídeo tá carregando."
                                                    : uploadVideoStatus ==
                                                            "error"
                                                        ? "Erro ao salvar vídeo."
                                                        : "Vídeo salvo com sucesso.",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    top: 40, bottom: 40),
                                                child: AnimatedBuilder(
                                                  animation: _controller,
                                                  builder: (_, child) {
                                                    return uploadVideoStatus ==
                                                            "loading"
                                                        ? Transform.rotate(
                                                            angle: _controller
                                                                    .value *
                                                                2 *
                                                                math.pi,
                                                            child: const Icon(
                                                                Icons.autorenew,
                                                                size: 100,
                                                                color: Colors
                                                                    .black87),
                                                          )
                                                        : uploadVideoStatus ==
                                                                "error"
                                                            ? const Icon(
                                                                Icons.warning,
                                                                size: 100,
                                                                color: Colors
                                                                    .black87)
                                                            : const Icon(
                                                                Icons.recommend,
                                                                size: 100,
                                                                color: Colors
                                                                    .black87);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Enviar saporra!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
