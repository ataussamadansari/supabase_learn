import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  RealtimeChannel? channel;
  final msgController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  listenBroadcast() {
    channel = supabase.channel(
      'room1',
      opts: RealtimeChannelConfig(self: true),
    );
    channel?.onBroadcast(
      event: 'event1',
      callback: (payload) {
        debugPrint('Payload: $payload');
        setState(() {
          messages.add(payload);
        });
      },
    );
    channel?.subscribe();
  }

  sendMessage() async {
    String text = msgController.text;
    msgController.clear();

    ChannelResponse? response = await channel?.sendBroadcastMessage(
      event: 'event1',
      payload: {'text': text, 'user_id': supabase.auth.currentUser?.id},
    );

    debugPrint('Message status: ${response?.name}');
  }

  @override
  void initState() {
    listenBroadcast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  await supabase.auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (context) => false,
                  );
                },
                child: Text("Logout"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (var msg in messages)
                  Align(
                    alignment: msg['user_id'] == supabase.auth.currentUser?.id
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 300
                      ),
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: msg['user_id'] == supabase.auth.currentUser?.id
                            ? Colors.blue
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: msg['user_id'] == supabase.auth.currentUser?.id
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: InputDecoration(
                      hintText: "Type your messages...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => sendMessage(),
                  icon: Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
