// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'common.dart';
import 'particle.dart';

class Pixels {
  const Pixels({
    required this.byteData,
    required this.width,
    required this.height,
  });

  final ByteData? byteData;
  final int width;
  final int height;

  Color getColorAt(int x, int y) {
    final offset = 4 * (x + y * width);
    final rgba = byteData!.getUint32(offset);
    final a = rgba & 0xFF;
    final rgb = rgba >> 8;
    final argb = (a << 24) + rgb;
    return Color(argb);
  }
}

class TouchPointer {
  late double touchSize;
  Offset? offset;
}

class TouchDetector extends StatelessWidget {
  const TouchDetector({
    Key? key,
    required this.touchPointer,
    required this.child,
  }) : super(key: key);

  final TouchPointer touchPointer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enabled = touchPointer.touchSize > 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: enabled
          ? (details) => touchPointer.offset = details.localPosition
          : null,
      onPanUpdate: enabled
          ? (details) => touchPointer.offset = details.localPosition
          : null,
      onPanEnd: enabled ? (details) => touchPointer.offset = null : null,
      child: child,
    );
  }
}

/// A widgets which paints an image using particles.
class AtomizedImage extends StatelessWidget {
  /// Paints the [image] using particles.
  ///
  /// When the [image] changes. The particles will be animated to transition
  /// to the new image.
  const AtomizedImage({
    Key? key,
    required this.image,
    this.onImageError,
    this.touchRadius = 100,
    this.particleRadius = 8,
  })  : assert(particleRadius > 0),
        super(key: key);

  /// The image to 'atomize'.
  ///
  /// Typically this will be an [AssetImage] (for an image shipped with the
  /// application) or a [NetworkImage] (for an image obtained from the network).
  final ImageProvider<Object> image;

  /// An optional error callback for errors emitted when loading
  /// [image].
  final ImageErrorListener? onImageError;

  /// The distance from which the particles will be put away when the user
  /// touches the widget.
  ///
  /// When this value is set to 0, nothing happens when the user touches the
  /// widget.
  ///
  /// Defaults to 100.
  final double touchRadius;

  /// The radius of the particles used to paint the image.
  ///
  /// Defaults to 8.
  final double particleRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return SizedBox.expand(
          child: RawAtomizedImage(
            provider: image,
            onError: onImageError,
            configuration: createLocalImageConfiguration(context),
            size: constraints.biggest,
            touchSize: touchRadius,
            particleSize: particleRadius,
          ),
        );
      },
    );
  }
}

class RawAtomizedImage extends StatefulWidget {
  const RawAtomizedImage({
    Key? key,
    required this.provider,
    required this.onError,
    required this.configuration,
    required this.size,
    required this.touchSize,
    required this.particleSize,
  }) : super(key: key);

  final ImageProvider<Object> provider;
  final ImageErrorListener? onError;
  final ImageConfiguration configuration;
  final Size size;
  final double touchSize;
  final double particleSize;

  @override
  _RawAtomizedImageState createState() => _RawAtomizedImageState();
}

class _RawAtomizedImageState extends State<RawAtomizedImage>
    with SingleTickerProviderStateMixin {
  final List<Particle> particles = <Particle>[];
  final TouchPointer touchPointer = TouchPointer();
  ui.Image? image;
  Pixels? pixels;
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    touchPointer.touchSize = widget.touchSize;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    loadPixels();
  }

  @override
  void didUpdateWidget(covariant RawAtomizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    touchPointer.touchSize = widget.touchSize;
    if (oldWidget.provider != widget.provider) {
      image?.dispose();
      loadPixels();
    }
  }

  @override
  void dispose() {
    controller!.dispose();
    image?.dispose();
    super.dispose();
  }

  Future<void> loadPixels() async {
    final imageStream = widget.provider.resolve(widget.configuration);
    final completer = Completer<ui.Image>();
    late ImageStreamListener imageStreamListener;
    imageStreamListener = ImageStreamListener(
      (frame, _) {
        completer.complete(frame.image);
        imageStream.removeListener(imageStreamListener);
      },
      onError: widget.onError,
    );
    imageStream.addListener(imageStreamListener);
    final image = await completer.future;
    final byteData = await image.toByteData();
    final pixels = Pixels(
      byteData: byteData,
      width: image.width,
      height: image.height,
    );
    showParticles(pixels);
  }

  void showParticles(Pixels pixels) {
    final particleIndices = List<int>.generate(particles.length, (i) => i);
    final width = widget.size.width;
    final height = widget.size.height;
    final halfWidth = width / 2;
    final halfHeight = height / 2;
    final halfImageWidth = pixels.width / 2;
    final halfImageHeight = pixels.height / 2;
    final tx = halfWidth - halfImageWidth;
    final ty = halfHeight - halfImageHeight;

    for (var y = 0; y < pixels.height; y++) {
      for (var x = 0; x < pixels.width; x++) {
        // Give it small odds that we'll assign a particle to this pixel.
        if (randNextD(1) > loadPercentage * countMultiplier) {
          continue;
        }

        final pixelColor = pixels.getColorAt(x, y);
        Particle newParticle;
        if (particleIndices.isNotEmpty) {
          // Re-use existing particles.
          final index = particleIndices.length == 1
              ? particleIndices.removeAt(0)
              : particleIndices.removeAt(randI(0, particleIndices.length - 1));
          newParticle = particles[index];
        } else {
          // Create a new particle.
          newParticle = Particle(halfWidth, halfHeight);
          particles.add(newParticle);
        }

        newParticle.target.x = x + tx;
        newParticle.target.y = y + ty;
        newParticle.endColor = pixelColor;
      }
    }

    // Kill off any left over particles that aren't assigned to anything.
    if (particleIndices.isNotEmpty) {
      for (var i = 0; i < particleIndices.length; i++) {
        particles[particleIndices[i]].kill(width, height);
      }
    }
    particles.shuffle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TouchDetector(
      touchPointer: touchPointer,
      child: CustomPaint(
        painter: ParticlesPainter(
          controller,
          particles,
          touchPointer,
          widget.particleSize,
        ),
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  const ParticlesPainter(
    this.animation,
    this.allParticles,
    this.touchPointer,
    this.particleSize,
  ) : super(repaint: animation);

  final Animation<double>? animation;
  final List<Particle> allParticles;
  final TouchPointer touchPointer;
  final double particleSize;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    for (var i = allParticles.length - 1; i >= 0; i--) {
      final particle = allParticles[i];
      particle.move(touchPointer);

      final color = particle.currentColor!;
      particle.currentColor = Color.lerp(
          particle.currentColor, particle.endColor, particle.colorBlendRate);
      double targetSize = 2;
      if (!particle.isKilled) {
        targetSize = map(
          min(particle.distToTarget, closeEnoughTarget),
          closeEnoughTarget,
          0,
          0,
          particleSize,
        );
      }

      particle.currentSize =
          ui.lerpDouble(particle.currentSize, targetSize, 0.1);

      final center = Offset(particle.pos.x, particle.pos.y);
      canvas.drawCircle(center, particle.currentSize!, Paint()..color = color);

      if (particle.isKilled) {
        if (particle.pos.x < 0 ||
            particle.pos.x > width ||
            particle.pos.y < 0 ||
            particle.pos.y > height) {
          allParticles.removeAt(i);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
