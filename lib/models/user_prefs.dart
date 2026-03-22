class UserPrefs {
  final String userId;
  final List<String> interests;
  final int preferredVolume;
  final String playbackSpeed;
  final String voiceProfile;
  final String theme;
  final String imageQuality;
  final String textSize;
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final String subscriptionTier;

  const UserPrefs({
    required this.userId,
    this.interests                  = const [],
    this.preferredVolume            = 10,
    this.playbackSpeed              = '1.0',
    this.voiceProfile               = 'male_anchor',
    this.theme                      = 'system',
    this.imageQuality               = 'standard',
    this.textSize                   = 'medium',
    this.emailNotificationsEnabled  = true,
    this.pushNotificationsEnabled   = true,
    this.subscriptionTier           = 'free',
  });

  bool get isPro => subscriptionTier == 'pro';

  factory UserPrefs.fromJson(Map<String, dynamic> j) => UserPrefs(
    userId:                       j['id'] as String,
    interests:                    List<String>.from(j['interests'] ?? []),
    preferredVolume:              (j['preferred_volume'] as int?) ?? 10,
    playbackSpeed:                (j['playback_speed'] as String?) ?? '1.0',
    voiceProfile:                 (j['voice_profile'] as String?) ?? 'male_anchor',
    theme:                        (j['theme'] as String?) ?? 'system',
    imageQuality:                 (j['image_quality'] as String?) ?? 'standard',
    textSize:                     (j['text_size'] as String?) ?? 'medium',
    emailNotificationsEnabled:    (j['email_notifications_enabled'] as bool?) ?? true,
    pushNotificationsEnabled:     (j['push_notifications_enabled'] as bool?) ?? true,
    subscriptionTier:             (j['subscription_tier'] as String?) ?? 'free',
  );

  UserPrefs copyWith({
    List<String>? interests,
    int? preferredVolume,
    String? playbackSpeed,
    String? voiceProfile,
    String? theme,
    String? imageQuality,
    String? textSize,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    String? subscriptionTier,
  }) => UserPrefs(
    userId:                      userId,
    interests:                   interests ?? this.interests,
    preferredVolume:             preferredVolume ?? this.preferredVolume,
    playbackSpeed:               playbackSpeed ?? this.playbackSpeed,
    voiceProfile:                voiceProfile ?? this.voiceProfile,
    theme:                       theme ?? this.theme,
    imageQuality:                imageQuality ?? this.imageQuality,
    textSize:                    textSize ?? this.textSize,
    emailNotificationsEnabled:   emailNotificationsEnabled ?? this.emailNotificationsEnabled,
    pushNotificationsEnabled:    pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    subscriptionTier:            subscriptionTier ?? this.subscriptionTier,
  );
}
