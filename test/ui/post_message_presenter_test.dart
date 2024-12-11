import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isekai/data/model/profile.dart';
import 'package:isekai/data/repository/preference_repository.dart';
import 'package:isekai/data/usecase/message_use_case.dart';
import 'package:isekai/data/usecase/preference_use_case.dart';
import 'package:isekai/ui/model/confirm_result_with_do_not_show_again_option.dart';
import 'package:isekai/ui/post_message_presenter.dart';
import 'package:mocktail/mocktail.dart';

class _MockPreferenceActions extends Mock implements PreferenceActions {}

class _MockMessageActions extends Mock implements MessageActions {}

abstract class _Listeners {
  Future<ConfirmResultWithDoNotShowAgainOption?> showConfirmDialog({
    required Profile profile,
  });
  void close();
}

class _MockListeners extends Mock implements _Listeners {}

void main() {
  late _MockListeners listeners;
  late _MockMessageActions messageActions;
  late _MockPreferenceActions preferenceActions;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      Profile(
        icon: '👍',
        name: 'テストユーザー',
        validUntil: DateTime(2024, 12),
      ),
    );
  });

  setUp(() {
    listeners = _MockListeners();
    preferenceActions = _MockPreferenceActions();
    messageActions = _MockMessageActions();
    container = ProviderContainer(
      overrides: [
        profileProvider.overrideWithValue(
          Profile(
            icon: '👍',
            name: 'テストユーザー',
            validUntil: DateTime(2024, 12),
          ),
        ),
        preferenceActionsProvider.overrideWithValue(preferenceActions),
        messageActionsProvider.overrideWithValue(messageActions),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('入力中のメッセージが変化した', () {
    test('空の場合、メッセージ投稿できない', () {
      container.read(postMessagePresenterProvider).onChangeMessage('');

      expect(
        container.read(canPostMessageOnPostMessageScreenProvider),
        false,
      );
    });

    test('空白だけの場合、メッセージ投稿できない', () {
      container.read(postMessagePresenterProvider).onChangeMessage('  ');

      expect(
        container.read(canPostMessageOnPostMessageScreenProvider),
        false,
      );
    });

    test('空白ではない文字がある場合、メッセージ投稿できる', () {
      container.read(postMessagePresenterProvider).onChangeMessage('テスト投稿です！');

      expect(
        container.read(canPostMessageOnPostMessageScreenProvider),
        true,
      );
    });
  });

  group('メッセージを投稿しようとした', () {
    group('プロフィールのライフサイクルについてユーザーが説明を受けるべき', () {
      test('説明は表示され、再表示しないチェックをONにして説明を受け入れると、メッセージが投稿され、画面が閉じる', () async {
        final presenter = container.read(postMessagePresenterProvider)
          ..registerListeners(
            showConfirmDialog: listeners.showConfirmDialog,
            close: listeners.close,
          );
        when(() => listeners.showConfirmDialog(profile: any(named: 'profile')))
            .thenAnswer(
          (_) async => const ConfirmResultWithDoNotShowAgainOption.doContinue(
            doNotShowAgain: true,
          ),
        );
        when(preferenceActions.getShouldExplainProfileLifecycle)
            .thenAnswer((_) async => true);
        when(preferenceActions.userRequestedDoNotShowAgainProfileLifecycle)
            .thenAnswer((_) async {});
        when(() => messageActions.sendMessage(text: any(named: 'text')))
            .thenAnswer((_) async {});

        await presenter.sendMessage(text: 'テスト投稿です！');

        verify(
          () => listeners.showConfirmDialog(profile: any(named: 'profile')),
        ).called(1);
        verify(
          preferenceActions.userRequestedDoNotShowAgainProfileLifecycle,
        ).called(1);
        verify(() => messageActions.sendMessage(text: 'テスト投稿です！')).called(1);
        verify(listeners.close).called(1);
      });

      test('説明は表示され、再表示しないチェックをOFFにして説明を受け入れると、メッセージが投稿され、画面が閉じる', () async {
        final presenter = container.read(postMessagePresenterProvider)
          ..registerListeners(
            showConfirmDialog: listeners.showConfirmDialog,
            close: listeners.close,
          );
        when(() => listeners.showConfirmDialog(profile: any(named: 'profile')))
            .thenAnswer(
          (_) async => const ConfirmResultWithDoNotShowAgainOption.doContinue(
            doNotShowAgain: false,
          ),
        );
        when(preferenceActions.getShouldExplainProfileLifecycle)
            .thenAnswer((_) async => true);
        when(preferenceActions.userRequestedDoNotShowAgainProfileLifecycle)
            .thenAnswer((_) async {});
        when(() => messageActions.sendMessage(text: any(named: 'text')))
            .thenAnswer((_) async {});

        await presenter.sendMessage(text: 'テスト投稿です！');

        verify(
          () => listeners.showConfirmDialog(profile: any(named: 'profile')),
        ).called(1);
        verifyNever(
          preferenceActions.userRequestedDoNotShowAgainProfileLifecycle,
        );
        verify(() => messageActions.sendMessage(text: 'テスト投稿です！')).called(1);
        verify(listeners.close).called(1);
      });

      test('説明は表示され、説明を受け入れないと、メッセージは投稿されず、画面は閉じない', () async {
        final presenter = container.read(postMessagePresenterProvider)
          ..registerListeners(
            showConfirmDialog: listeners.showConfirmDialog,
            close: listeners.close,
          );
        when(() => listeners.showConfirmDialog(profile: any(named: 'profile')))
            .thenAnswer(
          (_) async => const ConfirmResultWithDoNotShowAgainOption.cancel(),
        );
        when(preferenceActions.getShouldExplainProfileLifecycle)
            .thenAnswer((_) async => true);
        when(preferenceActions.userRequestedDoNotShowAgainProfileLifecycle)
            .thenAnswer((_) async {});
        when(() => messageActions.sendMessage(text: any(named: 'text')))
            .thenAnswer((_) async {});

        await presenter.sendMessage(text: 'テスト投稿です！');

        verify(
          () => listeners.showConfirmDialog(profile: any(named: 'profile')),
        ).called(1);
        verifyNever(
          preferenceActions.userRequestedDoNotShowAgainProfileLifecycle,
        );
        verifyNever(() => messageActions.sendMessage(text: any(named: 'text')));
        verifyNever(listeners.close);
      });

      test('説明は表示され、説明を閉じると、メッセージは投稿されず、画面は閉じない', () async {
        final presenter = container.read(postMessagePresenterProvider)
          ..registerListeners(
            showConfirmDialog: listeners.showConfirmDialog,
            close: listeners.close,
          );
        when(() => listeners.showConfirmDialog(profile: any(named: 'profile')))
            .thenAnswer(
          (_) async => null,
        );
        when(preferenceActions.getShouldExplainProfileLifecycle)
            .thenAnswer((_) async => true);
        when(preferenceActions.userRequestedDoNotShowAgainProfileLifecycle)
            .thenAnswer((_) async {});
        when(() => messageActions.sendMessage(text: any(named: 'text')))
            .thenAnswer((_) async {});

        await presenter.sendMessage(text: 'テスト投稿です！');

        verify(
          () => listeners.showConfirmDialog(profile: any(named: 'profile')),
        ).called(1);
        verifyNever(
          preferenceActions.userRequestedDoNotShowAgainProfileLifecycle,
        );
        verifyNever(() => messageActions.sendMessage(text: any(named: 'text')));
        verifyNever(listeners.close);
      });
    });

    group('プロフィールのライフサイクルについてユーザーが説明を受けなくていい', () {
      test('説明は表示されず、メッセージが投稿され、画面が閉じる', () async {
        final presenter = container.read(postMessagePresenterProvider)
          ..registerListeners(
            showConfirmDialog: listeners.showConfirmDialog,
            close: listeners.close,
          );
        when(preferenceActions.getShouldExplainProfileLifecycle)
            .thenAnswer((_) async => false);
        when(() => messageActions.sendMessage(text: any(named: 'text')))
            .thenAnswer((_) async {});

        await presenter.sendMessage(text: 'テスト投稿です！');

        verifyNever(
          () => listeners.showConfirmDialog(profile: any(named: 'profile')),
        );
        verifyNever(
          preferenceActions.userRequestedDoNotShowAgainProfileLifecycle,
        );
        verify(() => messageActions.sendMessage(text: 'テスト投稿です！')).called(1);
        verify(listeners.close).called(1);
      });
    });
  });
}
