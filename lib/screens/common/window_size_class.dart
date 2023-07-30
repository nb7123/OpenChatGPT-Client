import 'package:flutter/material.dart';

class WindowSizeLayoutBuilder extends LayoutBuilder {
  WindowSizeLayoutBuilder({
    super.key,
    required Widget Function(BuildContext context, WindowSizeClass windowSizeClass) builder,
  }): super(builder: (context, constraints) {
        return builder(context, WindowSizeClass.calculateFromSize(Size(constraints.maxWidth, constraints.maxHeight)));
    });
}

/// Window size classes are a set of opinionated viewport breakpoints to design, develop, and test
/// responsive application layouts against.
/// For more details check <a href="https://developer.android.com/guide/topics/large-screens/support-different-screen-sizes" class="external" target="_blank">Support different screen sizes</a> documentation.
///
/// WindowSizeClass contains a [WindowWidthSizeClass] and [WindowHeightSizeClass], representing the
/// window size classes for this window's width and height respectively.
///
/// See [calculateWindowSizeClass] to calculate the WindowSizeClass for an Activity's current window
///
/// @property widthSizeClass width-based window size class ([WindowWidthSizeClass])
/// @property heightSizeClass height-based window size class ([WindowHeightSizeClass])
@immutable
class WindowSizeClass {
  final WindowWidthSizeClass widthSizeClass;
  final WindowHeightSizeClass heightSizeClass;

  const WindowSizeClass({required this.widthSizeClass, required this.heightSizeClass});

  factory WindowSizeClass.calculateFromSize(Size size) {
    final windowWidthSizeClass = WindowWidthSizeClass.fromWidth(size.width);
    final windowHeightSizeClass = WindowHeightSizeClass.fromHeight(size.height);
    
    return WindowSizeClass(widthSizeClass: windowWidthSizeClass, heightSizeClass: windowHeightSizeClass);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    final WindowSizeClass typedOther = other as WindowSizeClass;
    return widthSizeClass == typedOther.widthSizeClass &&
        heightSizeClass == typedOther.heightSizeClass;
  }

  @override
  String toString() => 'WindowSizeClass($widthSizeClass, $heightSizeClass)';
}

/// Width-based window size class.
///
/// A window size class represents a breakpoint that can be used to build responsive layouts. Each
/// window size class breakpoint represents a majority case for typical device scenarios so your
/// layouts will work well on most devices and configurations.
///
/// For more details see <a href="https://developer.android.com/guide/topics/large-screens/support-different-screen-sizes#window_size_classes" class="external" target="_blank">Window size classes documentation</a>.
@immutable
class WindowWidthSizeClass implements Comparable<WindowWidthSizeClass> {
  final int value;

  const WindowWidthSizeClass._(this.value);

  // ignore: constant_identifier_names
  static const WindowWidthSizeClass Compact = WindowWidthSizeClass._(0);
  // ignore: constant_identifier_names
  static const WindowWidthSizeClass Medium = WindowWidthSizeClass._(1);
  // ignore: constant_identifier_names
  static const WindowWidthSizeClass Expanded = WindowWidthSizeClass._(2);

  static const Set<WindowWidthSizeClass> defaultSizeClasses = {
    Compact,
    Medium,
    Expanded
  };

  int breakpoint() {
    switch (this) {
      case Expanded:
        return 840;
      case Medium:
        return 600;
      default:
        return 0;
    }
  }

  factory WindowWidthSizeClass.fromWidth(double width) {
    const supportedSizeClasses = defaultSizeClasses;
    assert(width >= 0, 'Width must not be negative');
    assert(supportedSizeClasses.isNotEmpty,
        'Must support at least one size class');
    final List<WindowWidthSizeClass> sortedSizeClasses = supportedSizeClasses
        .toList(growable: false)
      ..sort((a, b) => b.compareTo(a));
    // Find the largest supported size class that matches the width
    for (var sizeClass in sortedSizeClasses) {
      if (width >= sizeClass.breakpoint()) {
        return sizeClass;
      }
    }
    // If none of the size classes matches, return the smallest one.
    return sortedSizeClasses.last;
  }

  @override
  int compareTo(WindowWidthSizeClass other) =>
      breakpoint().compareTo(other.breakpoint());

  @override
  String toString() {
    switch (this) {
      case Compact:
        return 'WindowWidthSizeClass.Compact';
      case Medium:
        return 'WindowWidthSizeClass.Medium';
      case Expanded:
        return 'WindowWidthSizeClass.Expanded';
      default:
        return '';
    }
  }
}

/// Height-based window size class.
///
/// A window size class represents a breakpoint that can be used to build responsive layouts. Each
/// window size class breakpoint represents a majority case for typical device scenarios so your
/// layouts will work well on most devices and configurations.
///
/// For more details see [Window size classes documentation](https://developer.android.com/guide/topics/large-screens/support-different-screen-sizes#window_size_classes).
@immutable
class WindowHeightSizeClass implements Comparable<WindowHeightSizeClass> {
  final int value;
  const WindowHeightSizeClass._(this.value);

  // ignore: constant_identifier_names
  static const Compact = WindowHeightSizeClass._(0);

  // ignore: constant_identifier_names
  static const Medium = WindowHeightSizeClass._(1);

  // ignore: constant_identifier_names
  static const Expanded = WindowHeightSizeClass._(2);

  static const _defaultSizeClasses = {Compact, Medium, Expanded};

  @override
  int compareTo(WindowHeightSizeClass other) {
    return _breakpoint().compareTo(other._breakpoint());
  }

  @override
  String toString() {
    switch (this) {
      case Compact:
        return "WindowHeightSizeClass.Compact";
      case Medium:
        return "WindowHeightSizeClass.Medium";
      case Expanded:
        return "WindowHeightSizeClass.Expanded";
      default:
        return "";
    }
  }

  int _breakpoint() {
    switch (this) {
      case Expanded:
        return 900;
      case Medium:
        return 480;
      default:
        return 0;
    }
  }

  factory WindowHeightSizeClass.fromHeight(double height) {
    assert(height >= 0, "Width must not be negative");

    const supportedSizeClasses = _defaultSizeClasses;
    assert(supportedSizeClasses.isNotEmpty,
        "Must support at least one size class");
    List<WindowHeightSizeClass> sortedSizeClasses =
        supportedSizeClasses.toList()..sort((a, b) => b.compareTo(a));
    for (WindowHeightSizeClass sizeClass in sortedSizeClasses) {
      if (height >= sizeClass._breakpoint()) {
        return sizeClass;
      }
    }
    return sortedSizeClasses.last;
  }
}
