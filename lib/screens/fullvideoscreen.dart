import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:mobx/mobx.dart';

import 'package:strangers/screens/chatscreen.dart';
import 'package:strangers/setup/meeting_store.dart';
import 'package:strangers/setup/peerTrackNode.dart';

class FullVideoscreen extends StatefulWidget {
  const FullVideoscreen({
    Key? key,
    required this.meetingStore,
    // required this.track,
    // required this.isvideomuted,
  }) : super(key: key);

  final MeetingStore meetingStore;
  // final PeerTracKNode track;
  // final  bool isvideomuted;

  @override
  State<FullVideoscreen> createState() => _FullVideoscreenState();
}

class _FullVideoscreenState extends State<FullVideoscreen> {
  TextEditingController messageTextController = TextEditingController();
  MeetingStore _meetingStore = MeetingStore();
  bool ismessageopen = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _meetingStore = widget.meetingStore;
    //_meetingStore.addUpdateListener();
  }

  bool check() {
    bool res = false;
    _meetingStore.peerTracks.forEach((element) {
      if (element.peerId == _meetingStore.localPeer!.peerId) {
        if (element.track != null) {
          res = true;
          return;
        }
      }
    });
    return res;
  }

  bool checkforpeer() {
    bool res = false;
    _meetingStore.peerTracks.forEach((element) {
      if (element.peerId != _meetingStore.localPeer!.peerId) {
        if (element.track != null) {
          res = true;
          return;
        }
      }
      return;
    });
    return res;
  }

  HMSVideoTrack getvideotrack() {
    late HMSVideoTrack temp;
    _meetingStore.peerTracks.forEach((element) {
      if (element.peerId == _meetingStore.localPeer!.peerId) {
        if (element.track != null) {
          temp = element.track!;
          return;
        }
      }
      return;
    });
    return temp;
  }

  HMSVideoTrack getvideotrackofpeer() {
    late HMSVideoTrack temp;
    _meetingStore.peerTracks.forEach((element) {
      if (element.peerId != _meetingStore.localPeer!.peerId) {
        if (element.track != null) {
          temp = element.track!;
          return;
        }
      }
      return;
    });

    return temp;
  }

  bool ispeervideomute() {
    bool res = false;
    // if (getpeerscreentrack() != null) {
    //   return false;
    // }
    _meetingStore.peerTracks.forEach((element) {
      if (element.peerId != _meetingStore.localPeer!.peerId) {
        if (element.audioTrack != null) {
          res = element.track!.isMute;
          return;
        }
      }
    });
    print(res);
    return res;
  }

  HMSTrack? getpeerscreentrack() {
    HMSTrack? res = null;

    _meetingStore.screenShareTrack.forEach((element) {
      if (element!.peer!.peerId != _meetingStore.localPeer!.peerId) {
        res = element;

        print(
            'sdasUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU');

        return;
      }
    });
    print(res);
    print(
        'nnnnnnnnnnnnnnnnnnnnnnnnNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN');
    return res;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            actions: [
              Observer(
                builder: (context) {
                  return InkWell(
                      onTap: () async {
                        if (_meetingStore.isScreenShareOn) {
                          _meetingStore.switchVideo();
                          _meetingStore.stopScreenShare();
                        } else {
                          _meetingStore.switchVideo();

                          _meetingStore.startScreenShare();
                          //_meetingStore.switchVideo();
                        }
                      },
                      child: _meetingStore.isMeetingStarted
                          ? Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 14),
                                  child: Icon(
                                    Icons.screen_share,
                                    color: !_meetingStore.isScreenShareOn
                                        ? Color.fromARGB(255, 98, 185, 101)
                                        : Colors.redAccent,
                                    size: 50,
                                  ),
                                ),
                                Text(
                                  " ",
                                  style: TextStyle(color: Colors.blue),
                                )
                              ],
                            )
                          : Text("data"));
                },
              ),
            ],
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 42, 44, 44),
            centerTitle: true,
            title: Text(
              "Strangers",
              style: TextStyle(color: Colors.yellowAccent),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 42, 44, 44),
          resizeToAvoidBottomInset: false,
          body: Observer(
            builder: (context) {
              ObservableMap<String, HMSTrackUpdate> trackupdate =
                  _meetingStore.trackStatus;
              Timer.periodic(Duration(seconds: 5), (timer) {});
              Future.delayed(Duration(milliseconds: 50000), () {
                // Do something
              });
              dynamic a = (trackupdate[_meetingStore.peerTracks[0].peerId]) ==
                  HMSTrackUpdate.trackMuted;

              print(
                  "eEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
              return Stack(children: [
                (checkforpeer() && !ispeervideomute())
                    ? getpeerscreentrack() != null
                        ? HMSVideoView(
                            track: getpeerscreentrack() as HMSVideoTrack)
                        : HMSVideoView(track: getvideotrackofpeer())
                    : Container(
                        height: size.height,
                        width: size.width,
                        color: Color.fromARGB(255, 42, 44, 44),
                        child: Center(
                            child: const Text(
                          "video muted",
                          style: TextStyle(color: Colors.redAccent),
                        )),
                      ),
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: Container(
                          height: size.height * .3,
                          width: size.width * .33,

                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 42, 44, 44),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border: Border.all(color: Colors.indigo)),
                          // color: Colors.blue,
                          child: _meetingStore.isVideoOn && check()
                              ? HMSVideoView(track: getvideotrack())
                              : Center(
                                  child: Text(
                                    "video Muted",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * .08,
                        width: size.width * .33,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: RawMaterialButton(
                                constraints:
                                    BoxConstraints(maxHeight: 50, maxWidth: 50),
                                onPressed: () async {
                                  // _meetingStore.switchAudio();
                                  await _meetingStore.switchVideo();
                                },
                                elevation: 2.0,
                                fillColor: _meetingStore.isVideoOn
                                    ? Color.fromARGB(255, 35, 143, 185)
                                    : Colors.redAccent,
                                child: _meetingStore.isVideoOn
                                    ? Icon(
                                        Icons.video_call,
                                        size: 20,
                                      )
                                    : Icon(
                                        Icons.videocam_off,
                                        size: 20.0,
                                      ),
                                padding: EdgeInsets.all(15.0),
                                shape: CircleBorder(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: RawMaterialButton(
                                constraints:
                                    BoxConstraints(maxHeight: 50, maxWidth: 50),
                                onPressed: () {
                                  // _meetingStore.switchAudio();
                                  _meetingStore.switchAudio();
                                },
                                elevation: 2.0,
                                fillColor: _meetingStore.isMicOn
                                    ? Color.fromARGB(255, 35, 143, 185)
                                    : Colors.redAccent,
                                child: _meetingStore.isMicOn
                                    ? Icon(
                                        Icons.mic,
                                        size: 20,
                                      )
                                    : Icon(
                                        Icons.mic_external_off,
                                        size: 20.0,
                                      ),
                                padding: EdgeInsets.all(15.0),
                                shape: CircleBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: SizedBox(
                //     height: 300,
                //     child: ListView.builder(
                //       itemCount: 5,
                //       itemBuilder: (context, index) {
                //         return Text("hello there");
                //       },
                //     ),
                //   ),
                // ),

                Positioned(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 0,
                  right: 0,
                  child: Container(
                    // margin: EdgeInsets.only(
                    //     bottom: MediaQuery.of(context).viewInsets.bottom),
                    color: Colors.transparent.withOpacity(.01),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: ismessageopen
                              ? ListView.builder(
                                  itemCount: _meetingStore.messages.length,
                                  itemBuilder: (context, index) {
                                    return _meetingStore.messages[index].sender!
                                                .peerId ==
                                            _meetingStore.localPeer!.peerId
                                        ? Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Container(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    color: Color.fromARGB(
                                                        255, 59, 125, 179),
                                                  ),
                                                  Text(
                                                    "  - ${_meetingStore.messages[index].message.toString()}",
                                                    style: TextStyle(
                                                        color: Colors.white70),
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
                                                    style: TextStyle(
                                                        color: Colors.white70),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                  },
                                )
                              : null,
                        ),
                        Row(
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
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    _meetingStore.sendBroadcastMessage(
                                        messageTextController.text);
                                    messageTextController.clear();
                                  }
                                },
                                style: TextStyle(color: Colors.white),
                                controller: messageTextController,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(color: Colors.white),
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
                                _meetingStore.sendBroadcastMessage(
                                    messageTextController.text);
                                messageTextController.clear();
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
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
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80, right: 20),
                    child: IconButton(
                      icon: ismessageopen
                          ? Icon(Icons.swipe_up)
                          : Icon(Icons.swipe_down),
                      onPressed: () {
                        setState(() {
                          if (ismessageopen) {
                            ismessageopen = false;
                          } else {
                            ismessageopen = true;
                          }
                        });
                      },
                    ),
                  ),
                ),
                // Positioned(
                //   top: 10,
                //   child: SizedBox(
                //     height: 300,
                //     width: double.infinity,
                //     child: ListView.builder(
                //       itemCount: 5,
                //       itemBuilder: (context, index) {
                //         return Text("hello there");
                //       },
                //     ),
                //   ),
                // )
              ]);
            },
          )),
    );
  }
}
