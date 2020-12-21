[![Pub][pub_badge]][pub]
[![Sponsor me][sponsor_badge]][sponsor_me]

# atomized_image

A widget which paints and animates images with particles to achieve an atomized effect.

Credits to Jason Labbe, for the original [sketch][sketch] from where most of the code of this package is.

![Overview][overview]

## Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  atomized_image: <latest_version>
```

In your library add the following import:

```dart
import 'package:atomized_image/atomized_image.dart';
```

## Getting started

Example:

```dart
AtomizedImage(
  // Use an ImageProvider to get the image you want to atomize.
  image: NetworkImage('https://pbs.twimg.com/profile_images/653618067084218368/XlQA-oRl_400x400.jpg'),
)
```

To change the image and animates the particles again, just change the image provider with a new one.

## Sponsoring

I'm working on my packages on my free-time, but I don't have as much time as I would. If this package or any other package I created is helping you, please consider to sponsor me so that I can take time to read the issues, fix bugs, merge pull requests and add features to these packages.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue][issue].  
If you fixed a bug or implemented a feature, please send a [pull request][pr].

<!-- Links -->
[sponsor_badge]: https://img.shields.io/badge/Sponsor-♥-green.svg
[sponsor_me]: https://github.com/letsar#reach-me
[overview]: https://raw.githubusercontent.com/letsar/atomized_image/master/.github/images/atomized_image_overview.gif

[pub_badge]: https://img.shields.io/pub/v/atomized_image.svg
[pub]: https://pub.dartlang.org/packages/atomized_image
[issue]: https://github.com/letsar/atomized_image/issues
[pr]: https://github.com/letsar/atomized_image/pulls

[sketch]: https://www.openprocessing.org/sketch/427313