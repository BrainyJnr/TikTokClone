import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoFileUrl;
  final bool autoPlay;

  CustomVideoPlayer({required this.videoFileUrl, this.autoPlay = false});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? playerController;
  bool isVideoReady = false; // To track if the video is ready
  bool isMuted = false;

  @override
  void initState() {
    super.initState();

    // Initialize video player controller with the video URL
    playerController = VideoPlayerController.network(widget.videoFileUrl)
      ..initialize().then((_) {
        // Once the video is initialized, update the state
        setState(() {
          isVideoReady = true; // Video is ready to play
        });

        if (widget.autoPlay) {
          playerController!.play(); // Automatically play the video if autoPlay is true
        }

        playerController!.setVolume(isMuted ? 0.0 : 1.0); // Set volume
      });
  }

  @override
  void dispose() {
    // Dispose the video player controller to free up resources
    playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Toggle play/pause on tap
        setState(() {
          playerController!.value.isPlaying
              ? playerController!.pause()
              : playerController!.play();
        });
      },
      onDoubleTap: () {
        // Mute/unmute on double tap
        setState(() {
          isMuted = !isMuted;
          playerController!.setVolume(isMuted ? 0.0 : 1.0);
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Show black background until video is ready
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black, // Placeholder black background
          ),

          // Display video when it's ready
          if (isVideoReady)
            Center(
              child: AspectRatio(
                aspectRatio: playerController!.value.aspectRatio,
                child: VideoPlayer(playerController!),
              ),
            ),

          // Display play/pause icon over the video
          if (!playerController!.value.isPlaying && isVideoReady)
            const Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 80,
            ),
        ],
      ),
    );
  }
}


