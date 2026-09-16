enum StoryTemplate {
  minimal,
  glass,
  cinematic,
  strava,
  journal;

  String get displayName {
    switch (this) {
      case StoryTemplate.minimal:
        return 'Minimal';
      case StoryTemplate.glass:
        return 'Glass';
      case StoryTemplate.cinematic:
        return 'Cinematic';
      case StoryTemplate.strava:
        return 'Strava';
      case StoryTemplate.journal:
        return 'Journal';
    }
  }

  String get description {
    switch (this) {
      case StoryTemplate.minimal:
        return 'Bersih & fokus statistik';
      case StoryTemplate.glass:
        return 'Frosted glass premium';
      case StoryTemplate.cinematic:
        return 'Foto dominan sinematik';
      case StoryTemplate.strava:
        return 'Route hero sporty';
      case StoryTemplate.journal:
        return 'Travel diary personal';
    }
  }
}
