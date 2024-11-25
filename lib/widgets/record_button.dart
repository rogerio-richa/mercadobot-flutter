import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/widgets/flow_shader.dart';
import 'package:messaging_ui/widgets/lottie_animation.dart';
import 'package:record/record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final AnimationController controller;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  static const double size = 46;

  final double lockerHeight = 200;
  double timerWidth = 0;

  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;

  DateTime? startTime;
  Timer? timer;
  String recordDuration = "00:00";
  final record = AudioRecorder();
  final List<int> audioDataBuffer = [];
  late Stream<Uint8List> audioStream;
  
  bool isLocked = false;
  bool showLottie = false;

  @override
  void initState() {
    super.initState();
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticInOut),
      ),
    );
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth = 300;
    timerAnimation = Tween<double>(begin: timerWidth + 25, end: 0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
    lockerAnimation = Tween<double>(begin: lockerHeight + 25, end: 0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {}); // Ensure the listener is removed
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        lockSlider(),
        cancelSlider(),
        audioButton(),
        if (isLocked) timerLocked(),
      ],
    );
  }

  Widget lockSlider() {
    return Positioned(
      bottom: -lockerAnimation.value,
      child: Container(
        height: lockerHeight,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          color: Colors.grey[800],
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const FaIcon(FontAwesomeIcons.lock, size: 20, color: Colors.white),
            const SizedBox(height: 8),
            FlowShader(
              direction: Axis.vertical,
              child: const Column(
                children: [
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cancelSlider() {
    return Positioned(
      right: -timerAnimation.value,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          color: Colors.grey[800],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              showLottie
                    ? const LottieAnimation()
                    : Row(
                        mainAxisSize: MainAxisSize
                            .min, // Ensures the row only takes up as much space as needed
                        children: [
                          const Icon(
                            Icons.radio_button_on, // Recording icon
                            color:
                                Colors.red, // Red color for the recording icon
                            size: 20, // Icon size
                          ),
                          const SizedBox(
                              width: 5), // Space between the icon and text
                          Text(
                            recordDuration,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              

              const SizedBox(width: 30),
              FlowShader(
                duration: const Duration(seconds: 3),
                flowColors: const [Colors.white, Colors.grey],
                child: Row(
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_left,
                      color: Colors.white,
                    ),
                    Text(
                      AppLocalizations.of(context)!.slideToCancel,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: size),
            ],
          ),
        ),
      ),
    );
  }

  Widget timerLocked() {
    return Positioned(
      right: 0,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          color: Colors.grey[800],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 25),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              //Vibrate.feedback(FeedbackType.success);
              timer?.cancel();
              timer = null;
              startTime = null;
              recordDuration = "00:00";

              // var filePath = await record.stop();
              // debugPrint(filePath);
              await record.cancel();

              setState(() {
                isLocked = false;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  recordDuration,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                FlowShader(
                  duration: const Duration(seconds: 3),
                  flowColors: const [Colors.white, Colors.grey],
                  child: Text(
                      AppLocalizations.of(context)!.tapLockToStop,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Center(
                  child: FaIcon(
                    FontAwesomeIcons.lock,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget audioButton() {
    return GestureDetector(
      child: Transform.scale(
        scale: buttonScaleAnimation.value,
        child: Container(
          height: size,
          width: size,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.mic, size: 30, color: Colors.deepOrange),
        ),
      ),
      onLongPressDown: (_) {
        debugPrint("onLongPressDown");
        widget.controller.forward();
      },
      onLongPressEnd: (details) async {
        debugPrint("onLongPressEnd");

        if (isCancelled(details.localPosition, context)) {
          //Vibrate.feedback(FeedbackType.heavy);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          setState(() {
            showLottie = true;
          });

          Timer(const Duration(milliseconds: 1440), () async {
            widget.controller.reverse();
            debugPrint("Cancelled recording");
            await record.cancel();
            showLottie = false;
          });
        } else if (checkIsLocked(details.localPosition)) {
          widget.controller.reverse();

          //Vibrate.feedback(FeedbackType.heavy);
          debugPrint("Locked recording");
          debugPrint(details.localPosition.dy.toString());
          setState(() {
            isLocked = true;
          });
        } else {
          widget.controller.reverse();

          //Vibrate.feedback(FeedbackType.success);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          record.cancel();
          final success = await CoreService().chatManager.sendMessage(
                    message: '',
                    base64Audio: base64Encode(audioDataBuffer),
                  );
              if (success) {
                print("Audio message sent successfully");
              } else {
                print("Failed to send audio message");
              }

          // var filePath = await record.stop();
          // if (filePath != null) {
          //   print("Recording saved at $filePath");

          //   try {
          //     final file = File(filePath!);
          //     final bytes = await file.readAsBytes();
          //     final base64Audio = base64Encode(bytes);

          //     // Send the audio message
          //     final success = await CoreService().chatManager.sendMessage(
          //           message: '',
          //           base64Audio: base64Audio,
          //         );
          //     if (success) {
          //       print("Audio message sent successfully");
          //       file.deleteSync(); // Optionally delete the file after sending
          //     } else {
          //       print("Failed to send audio message");
          //     }
          //   } catch (e) {
          //     print("Error handling audio file: $e");
          //   }
          // }
        }
      },
      onLongPressCancel: () {
        debugPrint("onLongPressCancel");
        widget.controller.reverse();
      },
      onLongPress: () async {
        debugPrint("onLongPress");
        //Vibrate.feedback(FeedbackType.success);
        if (await record.hasPermission()) {
          print("recording start");
          audioStream = await record.startStream(
            const RecordConfig(encoder: AudioEncoder.pcm16bits),
            // path:
            //     "${CoreService().documentPath}audio_${DateTime.now().millisecondsSinceEpoch}.mp4",
          );
          
          audioStream.listen((data) {
           audioDataBuffer.addAll(data);
          },
          onError: (e) => print(e.toString())
        );

          startTime = DateTime.now();
          timer = Timer.periodic(const Duration(seconds: 1), (_) {
            final minDur = DateTime.now().difference(startTime!).inMinutes;
            final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
            String min = minDur < 10 ? "0$minDur" : minDur.toString();
            String sec = secDur < 10 ? "0$secDur" : secDur.toString();
            setState(() {
              recordDuration = "$min:$sec";
            });
          });
        }
      },
    );
  }

  bool checkIsLocked(Offset offset) {
    return (offset.dy < -35);
  }

  bool isCancelled(Offset offset, BuildContext context) {
    return (offset.dx < -(MediaQuery.of(context).size.width * 0.2));
  }
}
