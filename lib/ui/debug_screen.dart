import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isekai/data/repository/preference_repository.dart';
import 'package:isekai/data/usecase/preference_use_case.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  static const name = 'DebugScreen';

  static MaterialPageRoute<DebugScreen> route() => MaterialPageRoute(
        builder: (_) => const DebugScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)!.debug),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const _UpdateProfileTile(),
          const _ForceErrorTile(),
          const _ForceCrashTile(),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16),
        ],
      ),
    );
  }
}

class _UpdateProfileTile extends ConsumerWidget {
  const _UpdateProfileTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceActions = ref.watch(preferenceActionsProvider);
    final profile = ref.watch(profileProvider);

    final icon = profile?.icon ?? '';
    final name = profile?.name ?? '';
    final displayProfile = '$icon $name';

    final validUntil = profile?.validUntil;
    final subtitle = validUntil != null
        ? Text(
            '${S.of(context)!.messageDateFormat(validUntil, validUntil)}まで有効',
          )
        : const SizedBox.shrink();

    return ListTile(
      title: const Text('プロフィールを更新する'),
      subtitle: subtitle,
      trailing: Text(displayProfile),
      onTap: preferenceActions.updateProfile,
    );
  }
}

class _ForceErrorTile extends StatelessWidget {
  const _ForceErrorTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('強制エラー'),
      onTap: () => throw Exception('Force error on debug screen'),
    );
  }
}

class _ForceCrashTile extends StatelessWidget {
  const _ForceCrashTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('強制クラッシュ'),
      onTap: () => FirebaseCrashlytics.instance.crash(),
    );
  }
}
