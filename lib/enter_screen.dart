import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strangers/meeting_screen.dart';
import 'package:strangers/service/firebaseServices.dart';

class Enter_screen extends StatefulWidget {
  const Enter_screen({Key? key}) : super(key: key);

  @override
  _Enter_screenState createState() => _Enter_screenState();
}

class _Enter_screenState extends State<Enter_screen> {
  var namecontroller = TextEditingController(text: '');
  var roomlinkcontroller = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(
                    //hintStyle: TextStyle(color: Colors.white),
                    hintText: "Your Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                          color: Colors.blue),
                    )),
                controller: namecontroller,
              ),
              ElevatedButton(
                  onPressed: () async {
                    // CircularProgressIndicator(
                    //   value: 20,
                    //   color: Colors.red,
                    // );

                    String link = await Provider.of<firebaseServices>(context,
                            listen: false)
                        .getmeetinglink();

                    print(link);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return Meeting_screen(
                            name: namecontroller.text, roomlink: link);
                      },
                    ));
                  },
                  child: Text("Get Link")),
            ],
          ),
        ),
      ),
    );
  }
}
