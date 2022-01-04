class EssentialInfo {
  String jellyfinUrl;
  String mediaBrowserToken;
  String userId;
  String libraryId;

  EssentialInfo(
    this.jellyfinUrl,
    this.mediaBrowserToken,
    this.userId,
    this.libraryId,
  );

  void setJellyfinUrl(String jellyfinUrl) {
    this.jellyfinUrl = jellyfinUrl;
  }

  void setMediaBrowserToken(String mediaBrowserToken) {
    this.mediaBrowserToken = mediaBrowserToken;
  }

  void setUserId(String userId) {
    this.userId = userId;
  }

  void setLibraryId(String libraryId) {
    this.libraryId = libraryId;
  }

  bool allInfoFilled() {
    return jellyfinUrl != '' &&
        mediaBrowserToken != '' &&
        userId != '' &&
        libraryId != '';
  }
}
