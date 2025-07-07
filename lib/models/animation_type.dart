enum AnimationType {
  confetti,
  bubblePop,
}

extension AnimationTypeExtension on AnimationType {
  String get displayName {
    switch (this) {
      case AnimationType.confetti:
        return '🎉 Confetti';
      case AnimationType.bubblePop:
        return '🫧 Bubble Pop';
    }
  }
}