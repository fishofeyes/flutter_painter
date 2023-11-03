import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
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

Map<double, double> _mapFontSize = {
  4: 14,
  6: 16,
  10: 18,
};

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
              // IconButton(
              //   icon: Icon(
              //     PhosphorIcons.scribbleLoop,
              //     color:  ? _primaryColor : Colors.white,
              //   ),
              //   onPressed: toggleFreeStyleDraw,
              // ),
              _PopItem(
                selected: controller.freeStyleMode == FreeStyleMode.draw,
                strokeWidth: controller.freeStyleStrokeWidth,
                onTap: (e) {
                  if (e == controller.freeStyleStrokeWidth) {
                    controller.freeStyleMode = FreeStyleMode.none;
                  } else {
                    controller.freeStyleMode = FreeStyleMode.draw;
                  }
                  controller.freeStyleStrokeWidth = e;
                  controller.textStyle = controller.textStyle.copyWith(fontSize: _mapFontSize[e] ?? 16);
                  controller.shapePaint = controller.shapePaint?.copyWith(strokeWidth: e);
                  onUpdate?.call();
                },
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

class _PopItem extends StatefulWidget {
  final bool selected;
  final Function(double size)? onTap;
  final double strokeWidth;
  const _PopItem({
    Key? key,
    this.selected = false,
    this.strokeWidth = 4,
    this.onTap,
  }) : super(key: key);

  @override
  State<_PopItem> createState() => _PopItemState();
}

class _PopItemState extends State<_PopItem> {
  final CustomPopupMenuController _controller = CustomPopupMenuController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      arrowColor: Colors.white70,
      child: IgnorePointer(
        ignoring: true,
        child: IconButton(
          icon: Icon(
            PhosphorIcons.scribbleLoop,
            color: widget.selected ? _primaryColor : Colors.white,
          ),
          onPressed: () {},
        ),
      ),
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IntrinsicWidth(
            child: _Item(
              onTap: (sender) {
                widget.onTap?.call(sender);
                _controller.hideMenu();
              },
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      ),
      pressType: PressType.singleClick,
      verticalMargin: -10,
      controller: _controller,
    );
  }
}

class _Item extends StatelessWidget {
  final Function(double size)? onTap;
  final double strokeWidth;
  const _Item({Key? key, this.onTap, this.strokeWidth = 4}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SizeItem(
          size: 4,
          selected: strokeWidth == 4,
          onTap: () => onTap?.call(4),
        ),
        Container(height: 30, width: 0.5, color: Colors.black26),
        _SizeItem(
          size: 6,
          selected: strokeWidth == 6,
          onTap: () => onTap?.call(6),
        ),
        Container(height: 30, width: 0.5, color: Colors.black26),
        _SizeItem(
          size: 10,
          selected: strokeWidth == 10,
          onTap: () => onTap?.call(10),
        ),
      ],
    );
  }
}

class _SizeItem extends StatelessWidget {
  final double size;
  final bool selected;
  final Function()? onTap;
  const _SizeItem({Key? key, required this.size, this.onTap, this.selected = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        alignment: Alignment.center,
        width: 40,
        height: 40,
        child: Container(
          width: size,
          height: size,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? _primaryColor : Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
