import 'package:flutter/material.dart';
import 'package:monice_playground_borderanimation/border_loading_animation/border_loading_animation.dart';

void main() => runApp(const MaterialApp(home: BorderLoadingPlayground()));

class BorderLoadingPlayground extends StatefulWidget {
  const BorderLoadingPlayground({super.key});

  @override
  BorderLoadingPlaygroundState createState() => BorderLoadingPlaygroundState();
}

class BorderLoadingPlaygroundState extends State<BorderLoadingPlayground> {
  final BorderLoadingAnimationController _borderLoadingAnimationController =
      BorderLoadingAnimationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: BorderLoadingAnimation(
          controller: _borderLoadingAnimationController,
          color: Colors.red,
          glowColor: Colors.red,
          child: SizedBox(
            height: 50,
            width: 200,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${(_borderLoadingAnimationController.value * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () async {
              _borderLoadingAnimationController.isShown.value
                  ? await _borderLoadingAnimationController.hide()
                  : _borderLoadingAnimationController.show();
              setState(() {});
            },
            mini: true,
            child: Icon(_borderLoadingAnimationController.isShown.value
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              _borderLoadingAnimationController.updateValue(
                  (_borderLoadingAnimationController.value + 0.1) > 1
                      ? 0
                      : (_borderLoadingAnimationController.value + 0.1));
              setState(() {});
            },
            mini: true,
            child: const Icon(Icons.add_rounded),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              _borderLoadingAnimationController.fullAnimation();
              setState(() {});
            },
            mini: true,
            child: const Icon(Icons.replay_rounded),
          ),
        ],
      ),
    );
  }
}
