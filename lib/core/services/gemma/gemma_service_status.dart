sealed class GemmaServiceStatus {
  const GemmaServiceStatus();
}

class GemmaNotInstalled extends GemmaServiceStatus {
  const GemmaNotInstalled();
}

class GemmaDownloading extends GemmaServiceStatus {
  const GemmaDownloading(this.progress);
  final int progress;
}

class GemmaLoading extends GemmaServiceStatus {
  const GemmaLoading();
}

class GemmaReady extends GemmaServiceStatus {
  const GemmaReady();
}

class GemmaError extends GemmaServiceStatus {
  const GemmaError(this.error, {this.isInstallError = false});
  final Object error;
  final bool isInstallError;
}
