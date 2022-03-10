import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:strangers/screens/chatscreen.dart';
import 'package:strangers/screens/fullvideoscreen.dart';
import 'package:strangers/setup/meeting_store.dart';
import 'package:strangers/setup/peerTrackNode.dart';

class Meeting_screen extends StatefulWidget {
  const Meeting_screen({
    Key? key,
    required this.name,
    required this.roomlink,
  }) : super(key: key);

  final String name, roomlink;
  @override
  _Meeting_screenState createState() => _Meeting_screenState();
}

class _Meeting_screenState extends State<Meeting_screen>
    with WidgetsBindingObserver {
  bool isjoined = false;
  Future<void> getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  late MeetingStore _meetingStore;
  TextEditingController messageTextController = TextEditingController();
  iniitializemeeting() async {
    print('init statata');
    await getPermissions();
    bool ans = await _meetingStore.join(widget.name, widget.roomlink);
    isjoined = ans;
    print(ans);
    if (!ans) {
      const SnackBar(content: Text("Unable to Join"));
      Navigator.of(context).pop();
    }
    _meetingStore.addUpdateListener();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('sipp');
    WidgetsBinding.instance!.addObserver(this);
    _meetingStore = MeetingStore();

    iniitializemeeting();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<dynamic> showdialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Exit Room",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        RawMaterialButton(
                          constraints:
                              BoxConstraints(maxHeight: 50, maxWidth: 50),
                          onPressed: () async {
                            _meetingStore.leave();
                            Navigator.pop(context, true);
                          },
                          elevation: 2.0,
                          fillColor: Color.fromARGB(255, 86, 173, 86),
                          child: Icon(Icons.call_end),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        Text('Leave')
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        RawMaterialButton(
                          constraints:
                              BoxConstraints(maxHeight: 50, maxWidth: 50),
                          onPressed: () async {
                            Navigator.pop(context, false);
                            // _meetingStore.switchAudio();
                          },
                          elevation: 2.0,
                          fillColor: Colors.redAccent,
                          child: Icon(
                            Icons.close,
                            size: 20,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        Text('Cancel')
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return await showdialog();
      },
      child: GestureDetector(
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
                      onTap: () {
                        if (_meetingStore.isScreenShareOn) {
                          _meetingStore.stopScreenShare();
                        } else {
                          _meetingStore.startScreenShare();
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return FullVideoscreen(
                                meetingStore: _meetingStore,
                              );
                            },
                          ));
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
                                Text(" ")
                              ],
                            )
                          : Text("data"));
                },
              )
            ],
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 42, 44, 44),
            centerTitle: true,
            title: Text(
              "Strangers",
              style: TextStyle(color: Colors.yellowAccent),
            ),
          ),
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Stack(children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Color.fromARGB(255, 42, 44, 44),
                            child: Observer(
                              builder: (_) {
                                if (_meetingStore.isRoomEnded) {
                                  return const Center(
                                      child: Text(
                                    "Room ended",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  ));
                                }
                                if (_meetingStore.peerTracks.isEmpty) {
                                  return const Center(
                                      child: Text(
                                    'Waiting for others to join!',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 20),
                                  ));
                                }
                                ObservableList<PeerTracKNode> peerlist =
                                    _meetingStore.peerTracks;

                                return videopageview(peerlist);
                              },
                            ),
                          ),
                          Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                  color: Colors.blue,
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return FullVideoscreen(
                                          meetingStore: _meetingStore,
                                        );
                                      },
                                    ));
                                  },
                                  icon: Icon(Icons.expand_more)))
                        ]),
                      ),
                      Expanded(
                        flex: 1,
                        child: Stack(
                          children: [
                            Container(
                              color: Colors.amber,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                        color: Color.fromARGB(255, 42, 44, 44),
                                        child: Observer(
                                          builder: (context) {
                                            return ListView.builder(
                                              itemCount:
                                                  _meetingStore.messages.length,
                                              itemBuilder: (context, index) {
                                                return _meetingStore
                                                            .messages[index]
                                                            .sender!
                                                            .peerId ==
                                                        _meetingStore
                                                            .localPeer!.peerId
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        child: Container(
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.person,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        59,
                                                                        125,
                                                                        179),
                                                              ),
                                                              Text(
                                                                  "  - ${_meetingStore.messages[index].message.toString()}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white70)),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Container(
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .redAccent,
                                                              ),
                                                              Text(
                                                                "  - ${_meetingStore.messages[index].message.toString()}",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white70),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                              },
                                            );
                                          },
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                color: Colors.blue,
                                icon: Icon(Icons.expand_more),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ChatScreen(
                                        meetingStore: _meetingStore,
                                      );
                                    },
                                  ));
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
                ],
              ),
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 0,
                right: 0,
                child: Container(
                  // margin: EdgeInsets.only(
                  //     bottom: MediaQuery.of(context).viewInsets.bottom),
                  color: Colors.transparent.withOpacity(.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RawMaterialButton(
                        onPressed: () {
                          _meetingStore.stopScreenShare();
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
                          style: TextStyle(color: Colors.white),
                          controller: messageTextController,
                          decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.white60),
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
                          FocusScope.of(context).requestFocus(FocusNode());
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget videopageview(List<PeerTracKNode> peerslist) {
    //List<Widget> pagechild = [];
    bool isvideomuted = false;
    print(
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');

    ObservableMap<String, HMSTrackUpdate> trackupdate =
        _meetingStore.trackStatus;

    return ListView.builder(
      itemCount: peerslist.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (ctx, index) {
        isvideomuted = !(peerslist[index].track?.peer?.isLocal ?? false
            ? !_meetingStore.isVideoOn
            : (trackupdate[peerslist[index].peerId]) ==
                HMSTrackUpdate.trackMuted);
        print(isvideomuted);

        return Observer(
          builder: (context) {
            return videotile(
                peerslist[index],
                !(peerslist[index].track?.peer?.isLocal ?? false
                    ? !_meetingStore.isVideoOn
                    : (trackupdate[peerslist[index].peerId]) ==
                        HMSTrackUpdate.trackMuted),
                MediaQuery.of(context).size);
          },
        );
      },
    );
  }

  Widget videotile(
    PeerTracKNode track,
    bool isvideomuted,
    Size size,
  ) {
    return Container(
      height: size.height * .5,
      width: size.width * .5,
      //color: Colors.indigo,
      // decoration: BoxDecoration(border: Border.all(color: Colors.indigo)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          child: Stack(
            children: [
              (track.track != null && isvideomuted)
                  ? Container(
                      height: size.height * .5,
                      width: size.width * .5,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo)),
                      child: HMSVideoView(track: track.track as HMSVideoTrack))
                  : Container(
                      color: Color.fromARGB(255, 32, 32, 32),
                      child: SizedBox(
                          child: Center(
                              child: const Text(
                        "video muted",
                        style: TextStyle(color: Colors.redAccent),
                      )))),
              if (track.peerId == _meetingStore.localPeer!.peerId)
                Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          _meetingStore.switchAudio();
                        },
                        child: _meetingStore.isMicOn
                            ? Icon(
                                Icons.mic,
                                color: Color.fromARGB(255, 69, 86, 92),
                                size: 35,
                              )
                            : Icon(
                                Icons.mic_off,
                                color: Colors.redAccent,
                                size: 35,
                              ),
                      ),
                    )),
              if (track.peerId == _meetingStore.localPeer!.peerId)
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          _meetingStore.switchVideo();
                        },
                        child: _meetingStore.isVideoOn
                            ? Icon(
                                Icons.video_call,
                                color: Color.fromARGB(255, 69, 86, 92),
                                size: 35,
                              )
                            : Icon(
                                Icons.videocam_off,
                                color: Colors.redAccent,
                                size: 35,
                              ),
                      ),
                    )),
              if (track.peerId == _meetingStore.localPeer!.peerId)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        onTap: () {
                          _meetingStore.switchCamera();
                        },
                        child: Icon(
                          Icons.flip_camera_ios,
                          color: Color.fromARGB(255, 69, 86, 92),
                          size: 30,
                        )),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (_meetingStore.isVideoOn) {
        _meetingStore.startCapturing();
      } else {
        _meetingStore.stopCapturing();
      }
    } else if (state == AppLifecycleState.paused) {
      if (_meetingStore.isVideoOn) {
        _meetingStore.stopCapturing();
      }
    } else if (state == AppLifecycleState.inactive) {
      if (_meetingStore.isVideoOn) {
        _meetingStore.stopCapturing();
      }
    } else if (state == AppLifecycleState.detached) {
      _meetingStore.leave();
    }
  }
}
// RawMaterialButton(
//                     constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
//                     onPressed: () {
//                       _meetingStore.switchAudio();
//                     },
//                     elevation: 2.0,
//                     fillColor: Colors.redAccent,
//                     child: _meetingStore.isMicOn
//                         ? Icon(
//                             FlutterIcons.mic_fea,
//                             size: 20,
//                           )
//                         : Icon(
//                             FlutterIcons.mic_off_fea,
//                             size: 20.0,
//                           ),
//                     padding: EdgeInsets.all(15.0),
//                     shape: CircleBorder(),
//                   )