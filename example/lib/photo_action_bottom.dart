import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const _colors = [
  Colors.white,
  Colors.black,
  Colors.red,
  Colors.deepOrange,
  Colors.orange,
  Colors.orangeAccent,
  Colors.greenAccent,
  Colors.green,
  Colors.lightBlue,
  Colors.blue
];

const _primaryColor = Colors.blue;

class PhotoActionBottomView extends StatelessWidget {
  final PainterController controller;
  final FocusNode? textFocusNode;
  final Color? selectColor;
  final Function(Color color)? onChooseColor;
  final Function()? onUpdate;
  final List<ShapeFactory> shapeList;
  const PhotoActionBottomView({
    Key? key,
    required this.controller,
    required this.shapeList,
    this.onChooseColor,
    this.textFocusNode,
    this.selectColor,
    this.onUpdate,
  }) : super(key: key);

  void undo() {
    controller.undo();
    onUpdate?.call();
  }

  void redo() {
    controller.redo();
    onUpdate?.call();
  }

  void toggleFreeStyleDraw() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.draw ? FreeStyleMode.draw : FreeStyleMode.none;
    onUpdate?.call();
  }

  void toggleFreeStyleErase() {
    controller.freeStyleMode =
        controller.freeStyleMode != FreeStyleMode.erase ? FreeStyleMode.erase : FreeStyleMode.none;
    onUpdate?.call();
  }

  void addText() {
    if (controller.freeStyleMode != FreeStyleMode.none) {
      controller.freeStyleMode = FreeStyleMode.none;
    }
    controller.addText();
    onUpdate?.call();
  }

  void _changeShape(int sender) {
    controller.shapeFactory = shapeList[sender];
    onUpdate?.call();
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) controller.removeDrawable(selectedDrawable);
    onUpdate?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(
                  PhosphorIcons.arrowClockwise,
                  color: Colors.white,
                ),
                onPressed: controller.canRedo ? redo : null,
              ),
              // Undo action
              IconButton(
                icon: const Icon(
                  PhosphorIcons.arrowCounterClockwise,
                  color: Colors.white,
                ),
                onPressed: controller.canUndo ? undo : null,
              ),

              // Free-style eraser
              IconButton(
                icon: Icon(
                  PhosphorIcons.eraser,
                  color: controller.freeStyleMode == FreeStyleMode.erase ? _primaryColor : Colors.white,
                ),
                onPressed: toggleFreeStyleErase,
              ),

              // Free-style eraser
              IconButton(
                icon: const Icon(
                  PhosphorIcons.trash,
                  color: Colors.white,
                ),
                onPressed: removeSelectedDrawable,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  PhosphorIcons.scribbleLoop,
                  color: controller.freeStyleMode == FreeStyleMode.draw ? _primaryColor : Colors.white,
                ),
                onPressed: toggleFreeStyleDraw,
              ),
              IconButton(
                icon: Icon(
                  PhosphorIcons.lineSegment,
                  color: controller.shapeFactory == shapeList[0] ? _primaryColor : Colors.white,
                ),
                onPressed: () => _changeShape(0),
              ),
              IconButton(
                icon: Icon(
                  PhosphorIcons.circle,
                  color: controller.shapeFactory == shapeList[1] ? _primaryColor : Colors.white,
                ),
                onPressed: () => _changeShape(1),
              ),
              IconButton(
                icon: Icon(
                  PhosphorIcons.rectangle,
                  color: controller.shapeFactory == shapeList[2] ? _primaryColor : Colors.white,
                ),
                onPressed: () => _changeShape(2),
              ),
              // Add text
              IconButton(
                icon: Icon(
                  PhosphorIcons.textT,
                  color: textFocusNode?.hasFocus == true ? _primaryColor : Colors.white,
                ),
                onPressed: addText,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _colors
                .map(
                  (e) => GestureDetector(
                    onTap: () {
                      controller.freeStyleColor = e;
                      controller.textStyle = TextStyle(color: e, fontSize: 16);
                      controller.shapePaint = controller.shapePaint?.copyWith(color: e);
                      onChooseColor?.call(e);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: e,
                        shape: BoxShape.circle,
                        border: Border.all(width: selectColor == e ? 3 : 1, color: Colors.white),
                      ),
                    ),
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }
}
