import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_bresto/data/model/thread.dart';
import 'package:live_bresto/data/usecase/message_use_case.dart';
import 'package:live_bresto/data/usecase/thread_use_case.dart';
import 'package:live_bresto/ui/thread_presenter.dart';
import 'ProfileScreen.dart'; // Import ProfileScreen

final _threadPresenterProvider = Provider(
  (ref) => ThreadPresenter(messageActions: ref.watch(messageActionsProvider)),
);


class ThreadScreen extends ConsumerWidget {
  const ThreadScreen({super.key});

  // Function to navigate to ProfileScreen
  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadStream = ref.watch(currentThreadProvider.stream);
    final messagesStream = ref.watch(currentThreadMessagesProvider.stream);
    final presenter = ref.watch(_threadPresenterProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: StreamBuilder<Thread>(
          stream: threadStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('エラーが発生しました。');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final thread = snapshot.data;
            if (thread == null) {
              return const Text('null');
            }

            return Text(thread.title);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => _navigateToProfile(context), // Navigate on press
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: messagesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('エラーが発生しました。');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final messages = snapshot.data;
              if (messages == null) {
                return Container();
              }

              return Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return ListTile(
                      title: Text(message.text),
                      subtitle: Text('User: ${message.userId}'),
                      trailing: Text(
                        S.of(context)!.messageDateFormat(
                              message.createdAt,
                              message.createdAt,
                            ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 0),
                  itemCount: messages.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var contributor = '';
          await showModalBottomSheet<void>(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                height: 750, // TODO(shimizu): サイズを比率にする。
                alignment: Alignment.center,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 20,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text('閉じる'),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        Align(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                            onPressed: () {
                              presenter.sendMessage(text: contributor);
                              Navigator.pop(context);
                            },
                            child: const Text('投稿'),
                          ),
                        ),
                      ],
                    ),
                    Scrollbar(
                      child: TextField(
                        autofocus: true,
                        maxLines: 12,
                        minLines: 12,
                        decoration: const InputDecoration(
                          hintText: 'コメントを投稿する',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (text) {
                          contributor = text;
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        tooltip: 'コメントを投稿する',
        child: const Icon(Icons.add),
      ),
    );
  }
}
