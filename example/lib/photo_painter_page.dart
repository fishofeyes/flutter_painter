import 'package:example/photo_action_bottom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'dart:ui' as ui;

import 'package:phosphor_flutter/phosphor_flutter.dart';

class PhotoPainterPage extends StatefulWidget {
  final String imgUrl;
  const PhotoPainterPage({Key? key, required this.imgUrl}) : super(key: key);

  @override
  State<PhotoPainterPage> createState() => _PhotoPainterPageState();
}

class _PhotoPainterPageState extends State<PhotoPainterPage> {
  Color red = Colors.red;
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  ui.Image? backgroundImage;
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // shape list
  final List<ShapeFactory> shapeList = [
    LineFactory(),
    // ArrowFactory(),
    // DoubleArrowFactory(),
    OvalFactory(),
    RectangleFactory(),
  ];

  @override
  void initState() {
    super.initState();
    controller = PainterController(
        settings: PainterSettings(
            text: TextSettings(
              focusNode: textFocusNode,
              textStyle: TextStyle(fontWeight: FontWeight.bold, color: red, fontSize: 18),
            ),
            freeStyle: FreeStyleSettings(
              color: red,
              strokeWidth: 5,
            ),
            shape: ShapeSettings(
              paint: shapePaint,
            ),
            scale: const ScaleSettings(
              enabled: true,
              minScale: 1,
              maxScale: 5,
            )));
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    initBackground();
  }

  void onFocus() {
    setState(() {});
  }

  void initBackground() async {
    // Extension getter (.image) to get [ui.Image] from [ImageProvider]
    final image = await const NetworkImage('https://picsum.photos/1920/1080/').image;

    setState(() {
      backgroundImage = image;
      controller.background = image.backgroundDrawable;
    });
  }

  void _saveImage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("照片涂鸦"),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveImage,
            child: const Text(
              "保存",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Enforces constraints
          Positioned.fill(
            child: Center(
              child: backgroundImage != null
                  ? AspectRatio(
                      aspectRatio: backgroundImage!.width / backgroundImage!.height,
                      child: FlutterPainter(
                        controller: controller,
                      ),
                    )
                  : const CupertinoActivityIndicator(
                      color: Colors.white,
                    ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: SafeArea(
              child: PhotoActionBottomView(
                controller: controller,
                textFocusNode: textFocusNode,
                shapeList: shapeList,
                selectColor: red,
                onChooseColor: (e) {
                  setState(() {
                    red = e;
                  });
                },
                onUpdate: () {
                  setState(() {});
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
