class UserSettings {
  const UserSettings({
    this.language = 'en',
    this.theme = 'system',
    this.notifNewBatch = true,
    this.notifBatchFull = true,
    this.notifProviderApproval = true,
  });

  final String language;
  final String theme;
  final bool notifNewBatch;
  final bool notifBatchFull;
  final bool notifProviderApproval;

  UserSettings copyWith({
    String? language,
    String? theme,
    bool? notifNewBatch,
    bool? notifBatchFull,
    bool? notifProviderApproval,
  }) =>
      UserSettings(
        language: language ?? this.language,
        theme: theme ?? this.theme,
        notifNewBatch: notifNewBatch ?? this.notifNewBatch,
        notifBatchFull: notifBatchFull ?? this.notifBatchFull,
        notifProviderApproval: notifProviderApproval ?? this.notifProviderApproval,
      );

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      language: json['language'] as String? ?? 'en',
      theme: json['theme'] as String? ?? 'system',
      notifNewBatch: json['notif_new_batch'] as bool? ?? true,
      notifBatchFull: json['notif_batch_full'] as bool? ?? true,
      notifProviderApproval: json['notif_provider_approval'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'theme': theme,
        'notif_new_batch': notifNewBatch,
        'notif_batch_full': notifBatchFull,
        'notif_provider_approval': notifProviderApproval,
      };
}
