import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_game_with_flutter_flame/logic/player_gauge_object_logic.dart';

class Player extends PositionComponent with HasGameRef, CollisionCallbacks {
  Vector2 velocity = Vector2.zero();

  late final Vector2 initialPosition;

  Player({required bool isMe}) : _isMyPlayer = isMe;

  final bool _isMyPlayer;

  static const radius = 30.0;

  @override
  Future<void>? onLoad() async {
    anchor = Anchor.center;
    width = radius * 2;
    height = radius * 2;

    final initialX = gameRef.size.x / 2;
    initialPosition = _isMyPlayer
        ? Vector2(initialX, gameRef.size.y * 0.8)
        : Vector2(initialX, gameRef.size.y * 0.2);
    position = initialPosition;

    add(CircleHitbox());
    add(PlayerGauge());
    await super.onLoad();
  }

  void move(Vector2 delta) {
    position += delta;
  }

  void updateHealth(double healthLeft) {
    for (final child in children) {
      if (child is PlayerGauge) {
        child._healthLeft = healthLeft;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Bullet && _isMyPlayer != other.isMine) {
      other.hasBeenHit = true;
      other.removeFromParent();
    }
  }

  /// returns the mirrored percent position of the player
  /// to be broadcasted to other clients
  Vector2 getMirroredPercentPosition() {
    final mirroredPosition = gameRef.size - position;
    return Vector2(mirroredPosition.x / gameRef.size.x,
        mirroredPosition.y / gameRef.size.y);
  }
}
