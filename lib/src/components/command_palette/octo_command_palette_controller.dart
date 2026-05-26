import 'package:flutter/foundation.dart';

/// Drives the open / closed state of an [OctoCommandPalette].
///
/// Hold one instance per palette in your `State`, dispose it in `dispose()`,
/// and wire trigger gestures (keyboard shortcut, "search" button) to
/// [open] / [close] / [toggle]. The palette listens via `addListener` and
/// shows or hides its modal overlay accordingly.
class OctoCommandPaletteController extends ChangeNotifier {
  bool _isOpen = false;

  /// `true` while the palette modal is shown.
  bool get isOpen => _isOpen;

  /// Shows the palette. No-op if already open.
  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Hides the palette. No-op if already closed.
  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  /// Flips the open state.
  void toggle() => _isOpen ? close() : open();
}
