import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/app/app.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_update_notifier.g.dart';

@Riverpod(keepAlive: true)
class AppUpdateNotifier extends _$AppUpdateNotifier with AppLogger {
  @override
  Future<RemoteVersionInfo?> build() async {
    loggy.debug("checking for update");
    final appInfo = ref.watch(appInfoProvider);
    // TODO use market-specific update checkers
    if (!appInfo.release.allowCustomUpdateChecker) {
      loggy.debug(
        "custom update checkers are not allowed for [${appInfo.release.name}] release",
      );
      return null;
    }
    final currentVersion = appInfo.version;
    return ref
        .watch(appRepositoryProvider)
        .getLatestVersion(includePreReleases: true)
        .match(
      (l) {
        loggy.warning("failed to get latest version, $l");
        throw l;
      },
      (remote) {
        if (remote.version.compareTo(currentVersion) > 0) {
          loggy.info("new version available: $remote");
          return remote;
        }
        loggy.info(
          "already using latest version[$currentVersion], remote: $remote",
        );
        return null;
      },
    ).run();
  }
}