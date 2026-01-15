/// Analytics event structure for future integration
/// Events are structured but SDK integration is NOT included
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    this.parameters,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Log event (currently just logs to console)
  void log() {
    // In production, this would send to Firebase Analytics, Mixpanel, etc.
    // For now, just log to console
    print('[Analytics] $name ${parameters != null ? parameters.toString() : ""}');
  }
}

/// Pre-defined analytics events
class AnalyticsEvents {
  // Quote interactions
  static AnalyticsEvent quoteViewed(String quoteId) {
    return AnalyticsEvent(
      name: 'quote_viewed',
      parameters: {
        'quote_id': quoteId,
      },
    );
  }

  static AnalyticsEvent quoteLiked(String quoteId) {
    return AnalyticsEvent(
      name: 'quote_liked',
      parameters: {
        'quote_id': quoteId,
      },
    );
  }

  static AnalyticsEvent quoteUnliked(String quoteId) {
    return AnalyticsEvent(
      name: 'quote_unliked',
      parameters: {
        'quote_id': quoteId,
      },
    );
  }

  static AnalyticsEvent quoteFavorited(String quoteId) {
    return AnalyticsEvent(
      name: 'quote_favorited',
      parameters: {
        'quote_id': quoteId,
      },
    );
  }

  static AnalyticsEvent quoteUnfavorited(String quoteId) {
    return AnalyticsEvent(
      name: 'quote_unfavorited',
      parameters: {
        'quote_id': quoteId,
      },
    );
  }

  static AnalyticsEvent quoteShared(String quoteId, String method) {
    return AnalyticsEvent(
      name: 'quote_shared',
      parameters: {
        'quote_id': quoteId,
        'method': method, // 'text' or 'image'
      },
    );
  }

  static AnalyticsEvent quoteCardGenerated(String quoteId, String style) {
    return AnalyticsEvent(
      name: 'quote_card_generated',
      parameters: {
        'quote_id': quoteId,
        'style': style,
      },
    );
  }

  // Collection interactions
  static AnalyticsEvent collectionCreated(String collectionId, String name) {
    return AnalyticsEvent(
      name: 'collection_created',
      parameters: {
        'collection_id': collectionId,
        'collection_name': name,
      },
    );
  }

  static AnalyticsEvent collectionDeleted(String collectionId) {
    return AnalyticsEvent(
      name: 'collection_deleted',
      parameters: {
        'collection_id': collectionId,
      },
    );
  }

  static AnalyticsEvent quoteAddedToCollection(
    String quoteId,
    String collectionId,
  ) {
    return AnalyticsEvent(
      name: 'quote_added_to_collection',
      parameters: {
        'quote_id': quoteId,
        'collection_id': collectionId,
      },
    );
  }

  // Search
  static AnalyticsEvent searchPerformed(String query, int resultCount) {
    return AnalyticsEvent(
      name: 'search_performed',
      parameters: {
        'query': query,
        'result_count': resultCount,
      },
    );
  }

  // Settings
  static AnalyticsEvent themeChanged(String theme) {
    return AnalyticsEvent(
      name: 'theme_changed',
      parameters: {
        'theme': theme,
      },
    );
  }

  static AnalyticsEvent fontSizeChanged(double scale) {
    return AnalyticsEvent(
      name: 'font_size_changed',
      parameters: {
        'scale': scale,
      },
    );
  }

  // App lifecycle
  static AnalyticsEvent appOpened() {
    return AnalyticsEvent(name: 'app_opened');
  }

  static AnalyticsEvent dailyQuoteViewed(String quoteId) {
    return AnalyticsEvent(
      name: 'daily_quote_viewed',
      parameters: {
        'quote_id': quoteId,
      },
    );
  }

  // Errors (for debugging)
  static AnalyticsEvent errorOccurred(String error, String context) {
    return AnalyticsEvent(
      name: 'error_occurred',
      parameters: {
        'error': error,
        'context': context,
      },
    );
  }
}

