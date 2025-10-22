import "dart:io";

class UpdateChecker {
  final String _currentVersion;
  final Uri _url;
  final bool _disabled;

  String? _latestVersion;

  UpdateChecker({
    required String author,
    required String repoName,
    required String currentVersion,
  }) : _currentVersion = removePrefix(currentVersion),
       _disabled = Platform.environment.containsKey(
         "technicjelle.updatechecker.disabled",
       ),
       _url = Uri.parse("https://github.com/$author/$repoName/releases/latest");

  Future<bool> isUpdateAvailable() async {
    return await getLatestVersion() != _currentVersion;
  }

  Future<String> getLatestVersion() async {
    return _latestVersion ??= await _fetchLatestVersion();
  }

  Future<String> _fetchLatestVersion() async {
    if (_disabled) return _currentVersion;
    try {
      // Connect to GitHub website
      final HttpClientRequest connection = await HttpClient().getUrl(_url);
      connection.followRedirects = false;
      final HttpClientResponse response = await connection.close();

      // Check if response is a redirect
      final String? newUrl = response.headers.value("Location");

      if (newUrl == null) {
        throw const HttpException("Did not get a redirect");
      }

      // Get the latest version tag from the redirect URL
      final List<String> split = newUrl.split("/");
      return removePrefix(split[split.length - 1]);
    } on HttpException catch (e) {
      throw HttpException("Exception trying to fetch the latest version:\n$e");
    }
  }

  static String removePrefix(String version) {
    return version.replaceFirst(RegExp("^v"), "");
  }
}
