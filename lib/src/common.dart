// ignore_for_file: public_member_api_docs

import 'dart:math';

final Random _random = Random();

double randNextD(double max) => _random.nextDouble() * max;
int randNextI(int max) => _random.nextInt(max);
double randD(double min, double max) =>
    _random.nextDouble() * (max - min) + min;
int randI(int min, int max) => _random.nextInt(max - min) + min;

double map(double x, double minIn, double maxIn, double minOut, double maxOut) {
  return (x - minIn) * (maxOut - minOut) / (maxIn - minIn) + minOut;
}

const loadPercentage = 0.045; // 0 to 1.0.
const countMultiplier = 1;
const closeEnoughTarget = 50.0;
const speed = 1;
