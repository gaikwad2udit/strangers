import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:strangers/setup/meeting_store.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.meetingStore,
  }) : super(key: key);
  final MeetingStore meetingStore;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageTextController = TextEditingController();
  late MeetingStore _meetingStore;
  final scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _meetingStore = widget.meetingStore;
  }

  scrolltolast() {
    if (_meetingStore.messages.length > 1) {
      final double end = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(end + 80);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 42, 44, 44),
          titleSpacing: size.width * .25,
          title: Text(
            "Strangers",
            style: TextStyle(color: Colors.yellowAccent),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 42, 44, 44),
        body: Column(
          children: [
            Expanded(child: Observer(
              builder: (context) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: _meetingStore.messages.length,
                  itemBuilder: (context, index) {
                    return _meetingStore.messages[index].sender!.peerId ==
                            _meetingStore.localPeer!.peerId
                        ? Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Color.fromARGB(255, 59, 125, 179),
                                  ),
                                  Text(
                                    "  - ${_meetingStore.messages[index].message.toString()}",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.redAccent,
                                  ),
                                  Text(
                                    "  - ${_meetingStore.messages[index].message.toString()}",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          );
                  },
                );
              },
            )),
            Container(
              // margin: EdgeInsets.only(
              //     bottom: MediaQuery.of(context).viewInsets.bottom),
              color: Colors.transparent.withOpacity(.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RawMaterialButton(
                    onPressed: () {
                      _meetingStore.leave();
                      Navigator.pop(context);
                    },
                    elevation: 2.0,
                    fillColor: Colors.redAccent,
                    child: Icon(
                      Icons.call_end,
                      size: 20,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                  Expanded(
                    child: TextField(
                      onEditingComplete: () {
                        if (messageTextController.text.isEmpty) {
                          return;
                        }
                        _meetingStore
                            .sendBroadcastMessage(messageTextController.text);
                        messageTextController.clear();
                        scrolltolast();
                      },
                      style: TextStyle(color: Colors.white),
                      controller: messageTextController,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.white70),
                          hintText: "Type message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                                color: Colors.blue),
                          )),
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      if (messageTextController.text.isEmpty) {
                        return;
                      }
                      _meetingStore
                          .sendBroadcastMessage(messageTextController.text);
                      messageTextController.clear();
                      // FocusScope.of(context).requestFocus(FocusNode());
                    },
                    elevation: 2.0,
                    fillColor: Color.fromARGB(255, 4, 173, 224),
                    child: Icon(
                      Icons.send,
                      size: 20,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
