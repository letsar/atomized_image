// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:atomized_image/src/atomized_image.dart';
import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math.dart';

import 'common.dart';

class Particle {
  Particle(this.x, this.y)
      : pos = Vector2(x, y),
        maxSpeed = randD(0.25, 2),
        maxForce = randD(8, 15),
        colorBlendRate = randD(0.01, 0.05);

  final double x;
  final double y;
  final Vector2 pos;
  final double maxSpeed; // How fast it can move per frame.
  final double maxForce; // Its speed limit.
  final double colorBlendRate;

  Vector2 vel = Vector2.zero();
  Vector2 acc = Vector2.zero();
  Vector2 target = Vector2.zero();
  bool isKilled = false;
  Color currentColor = const Color(0x00000000);
  Color endColor = const Color(0x00000000);
  double currentSize = 0;
  double distToTarget = 0;

  void move(TouchPointer touchPointer) {
    distToTarget = pos.distanceTo(target);

    double proximityMult;

    // If it's close enough to its target, the slower it'll get
    // so that it can settle.
    if (distToTarget < closeEnoughTarget) {
      proximityMult = distToTarget / closeEnoughTarget;
      vel *= 0.9;
    } else {
      proximityMult = 1;
      vel *= 0.95;
    }

    // Steer towards its target.
    if (distToTarget > 1) {
      final steer = target.clone()
        ..sub(pos)
        ..normalize()
        ..scale(maxSpeed * proximityMult * speed);
      acc.add(steer);
    }

    if (touchPointer.offset != null) {
      final touchSize = touchPointer.touchSize;
      final touch = Vector2(touchPointer.offset.dx, touchPointer.offset.dy);
      final distToTouch = pos.distanceTo(touch);
      if (distToTouch < touchSize) {
        final push = pos.clone()..sub(touch);
        push.normalize();
        push.scale((touchSize - distToTouch) * 0.05);
        acc.add(push);
      }
    }

    vel.add(acc);
    vel.limit(maxForce * speed);
    pos.add(vel);
    acc.scale(0);
  }

  void kill(double width, double height) {
    if (!isKilled) {
      target = generateRandomPos(
          width / 2, height / 2, max(width, height), width, height);
      endColor = const Color(0x00000000);
      isKilled = true;
    }
  }
}

extension on Vector2 {
  void limit(double max) {
    if (length2 > max * max) {
      normalize();
      scale(max);
    }
  }
}

Vector2 generateRandomPos(
    double x, double y, double mag, double width, double height) {
  final pos = Vector2(x, y);
  final vel = Vector2(randD(0, width), randD(0, height));
  vel.sub(pos);
  vel.normalize();
  vel.scale(mag);
  pos.add(vel);

  return pos;
}
