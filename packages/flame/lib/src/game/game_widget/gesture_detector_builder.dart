import 'package:flame/events.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/gestures.dart' as flutter;
import 'package:flutter/widgets.dart';

class GestureDetectorBuilder {
  GestureDetectorBuilder([this._onChange]);

  final Map<Type, GestureRecognizerFactory> _gestures = {};
  final Map<Type, int> _counters = {};
  final void Function()? _onChange;

  void add<T extends flutter.GestureRecognizer>(
    T Function() constructor,
    void Function(T) initializer,
  ) {
    final count = _counters[T];
    if (count == null) {
      _gestures[T] =
          GestureRecognizerFactoryWithHandlers<T>(constructor, initializer);
      _onChange?.call();
    }
    _counters[T] = (count ?? 0) + 1;
  }

  void remove<T extends flutter.GestureRecognizer>() {
    final count = _counters[T]!;
    if (count == 1) {
      _counters.remove(T);
      _gestures.remove(T);
      _onChange?.call();
    } else {
      _counters[T] = count - 1;
    }
  }

  Widget build(Widget child) {
    if (_gestures.isEmpty) {
      return child;
    }
    return RawGestureDetector(
      gestures: _gestures,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  void initializeGestures(Game game) {
    if (game is TapDetector ||
        game is SecondaryTapDetector ||
        game is TertiaryTapDetector) {
      add(
        flutter.TapGestureRecognizer.new,
        (flutter.TapGestureRecognizer instance) {
          if (game is TapDetector) {
            instance.onTap = game.onTap;
            instance.onTapCancel = game.onTapCancel;
            instance.onTapUp = game.handleTapUp;
            instance.onTapDown = game.handleTapDown;
          }
          if (game is SecondaryTapDetector) {
            instance.onSecondaryTapCancel = game.onSecondaryTapCancel;
            instance.onSecondaryTapUp = game.handleSecondaryTapUp;
            instance.onSecondaryTapDown = game.handleSecondaryTapDown;
          }
          if (game is TertiaryTapDetector) {
            instance.onTertiaryTapCancel = game.onTertiaryTapCancel;
            instance.onTertiaryTapUp = game.handleTertiaryTapUp;
            instance.onTertiaryTapDown = game.handleTertiaryTapDown;
          }
        },
      );
    }
    if (game is DoubleTapDetector) {
      add(
        flutter.DoubleTapGestureRecognizer.new,
        (flutter.DoubleTapGestureRecognizer instance) {
          instance.onDoubleTap = game.onDoubleTap;
          instance.onDoubleTapDown = game.handleDoubleTapDown;
          instance.onDoubleTapCancel = game.onDoubleTapCancel;
        },
      );
    }
    if (game is LongPressDetector) {
      add(
        flutter.LongPressGestureRecognizer.new,
        (flutter.LongPressGestureRecognizer instance) {
          instance.onLongPress = game.onLongPress;
          instance.onLongPressStart = game.handleLongPressStart;
          instance.onLongPressMoveUpdate = game.handleLongPressMoveUpdate;
          instance.onLongPressEnd = game.handleLongPressEnd;
          instance.onLongPressUp = game.onLongPressUp;
          instance.onLongPressCancel = game.onLongPressCancel;
        },
      );
    }
    if (game is VerticalDragDetector) {
      add(
        flutter.VerticalDragGestureRecognizer.new,
        (flutter.VerticalDragGestureRecognizer instance) {
          instance.onDown = game.handleVerticalDragDown;
          instance.onStart = game.handleVerticalDragStart;
          instance.onUpdate = game.handleVerticalDragUpdate;
          instance.onEnd = game.handleVerticalDragEnd;
          instance.onCancel = game.onVerticalDragCancel;
        },
      );
    }
    if (game is HorizontalDragDetector) {
      add(
        flutter.HorizontalDragGestureRecognizer.new,
        (flutter.HorizontalDragGestureRecognizer instance) {
          instance.onDown = game.handleHorizontalDragDown;
          instance.onStart = game.handleHorizontalDragStart;
          instance.onUpdate = game.handleHorizontalDragUpdate;
          instance.onEnd = game.handleHorizontalDragEnd;
          instance.onCancel = game.onHorizontalDragCancel;
        },
      );
    }
    if (game is ForcePressDetector) {
      add(
        flutter.ForcePressGestureRecognizer.new,
        (flutter.ForcePressGestureRecognizer instance) {
          instance.onStart = game.handleForcePressStart;
          instance.onPeak = game.handleForcePressPeak;
          instance.onUpdate = game.handleForcePressUpdate;
          instance.onEnd = game.handleForcePressEnd;
        },
      );
    }
    if (game is PanDetector) {
      add(
        flutter.PanGestureRecognizer.new,
        (flutter.PanGestureRecognizer instance) {
          instance.onDown = game.handlePanDown;
          instance.onStart = game.handlePanStart;
          instance.onUpdate = game.handlePanUpdate;
          instance.onEnd = game.handlePanEnd;
          instance.onCancel = game.onPanCancel;
        },
      );
    }
    if (game is ScaleDetector) {
      add(
        flutter.ScaleGestureRecognizer.new,
        (flutter.ScaleGestureRecognizer instance) {
          instance.onStart = game.handleScaleStart;
          instance.onUpdate = game.handleScaleUpdate;
          instance.onEnd = game.handleScaleEnd;
        },
      );
    }
    if (game is MultiTapListener) {
      add(
        flutter.MultiTapGestureRecognizer.new,
        (flutter.MultiTapGestureRecognizer instance) {
          final g = game as MultiTapListener;
          instance.longTapDelay = Duration(
            milliseconds: (g.longTapDelay * 1000).toInt(),
          );
          instance.onTap = g.handleTap;
          instance.onTapDown = g.handleTapDown;
          instance.onTapUp = g.handleTapUp;
          instance.onTapCancel = g.handleTapCancel;
          instance.onLongTapDown = g.handleLongTapDown;
        },
      );
    }
  }
}

bool hasMouseDetectors(Game game) {
  return game is MouseMovementDetector ||
      game is PointerListenerDetector ||
      game is ScrollDetector ||
      game.mouseDetector != null;
}

Widget applyMouseDetectors(Game game, Widget child) {
  final pointerDownFn = game is PointerListenerDetector ? game.onPointerDown : null;
  final pointerMoveFn = game is PointerListenerDetector ? game.onPointerMove : null;
  final pointerUpFn = game is PointerListenerDetector ? game.onPointerUp : null;
  final pointerCancelFn = game is PointerListenerDetector ? game.onPointerCancel : null;

  final mouseMoveFn = game is MouseMovementDetector ? game.onMouseMove : null;
  final mouseDetector = game.mouseDetector;
  return Listener(
    onPointerMove: (flutter.PointerMoveEvent e) {
      mouseMoveFn?.call(PointerMoveInfo.fromDetails(game, e));
      mouseDetector?.call(e);
      pointerMoveFn?.call(e);
    },
    onPointerDown: (flutter.PointerDownEvent e) {
      pointerDownFn?.call(e);
    },
    onPointerUp: (flutter.PointerUpEvent e) {
      pointerUpFn?.call(e);
    },
    onPointerCancel: (flutter.PointerCancelEvent e) {
      pointerCancelFn?.call(e);
    },
    child: MouseRegion(
      child: child,
      onHover: (flutter.PointerHoverEvent e) {
        // mouseMoveFn?.call(PointerHoverInfo.fromDetails(game, e));
        // mouseDetector?.call(e);
      },
    ),
    onPointerSignal: (event) =>
        game is ScrollDetector && event is flutter.PointerScrollEvent
            ? game.onScroll(PointerScrollInfo.fromDetails(game, event))
            : null,
  );
}
