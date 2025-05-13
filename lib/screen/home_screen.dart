import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vid_player/const/style.dart';
import 'package:vid_player/component/custom_video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: video != null ? renderVideo() : renderEmpty(),
    );
  }

  Widget renderEmpty() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A3A7C), Color(0xFF000118)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Logo(onTap: onNewVideoPressed),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('VIDEO', style: logoTxt),
              Text(
                'PLAYER',
                style: logoTxt.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget renderVideo() {
    return Center(
      child: CustomVideoPlayer(
        video: video,
        onNewVideoPressed: onNewVideoPressed,
      ),
    );
  }

  void onNewVideoPressed() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        this.video = video;
      });
    }
  }
}

class _Logo extends StatelessWidget {
  final GestureTapCallback onTap;

  const _Logo({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset('asset/img/logo.png'),
    );
  }
}
