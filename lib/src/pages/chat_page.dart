import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bubble/bubble.dart';
import 'package:chatgpt/models/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/chat.dart';
import '../../network/api_services.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String messagePrompt = '';
  int tokenValue = 500;
  List<Chat> chatList = [];
  List<Model> modelsList = [];
  bool pressedBtn = false;
  int selectedItem = -1;
  bool waitingResponse = false;
  late SharedPreferences prefs;
  final ScrollController scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    getModels();
    initPrefs();
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void getModels() async {
    modelsList = await submitGetModelsForm(context: context);
  }

  List<DropdownMenuItem<String>> get models {
    List<DropdownMenuItem<String>> menuItems =
        List.generate(modelsList.length, (i) {
      return DropdownMenuItem(
        value: modelsList[i].id,
        child: Text(modelsList[i].id),
      );
    });
    return menuItems;
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    tokenValue = prefs.getInt("token") ?? 500;
  }

  TextEditingController mesageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF292B4D),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _topChat(),
                _bodyChat(),
                const SizedBox(
                  height: 75,
                )
              ],
            ),
            _formChat(),
          ],
        ),
      ),
    );
  }

  void saveData(int value) {
    prefs.setInt("token", value);
  }

  int getData() {
    return prefs.getInt("token") ?? 1;
  }

  _topChat() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Chatgpt',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter state) {
                    return Container(
                      height: 400,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          )),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              'Configuración',
                              style: TextStyle(
                                color: Color(0xFFF75555),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade700,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                            child: DropdownButtonFormField(
                              items: models,
                              borderRadius: const BorderRadius.only(),
                              focusColor: Colors.amber,
                              onChanged: (String? s) {},
                              decoration: const InputDecoration(
                                  hintText: "Selecciona un modelo"),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 2),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text("Token")),
                          ),
                          Slider(
                            min: 0,
                            max: 1000,
                            activeColor: const Color(0xFFE58500),
                            inactiveColor:
                                const Color.fromARGB(255, 230, 173, 92),
                            value: tokenValue.toDouble(),
                            onChanged: (value) {
                              state(() {
                                tokenValue = value.round();
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    child: const Center(
                                      child: Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    saveData(tokenValue);
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE58500),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    child: const Center(
                                      child: Text(
                                        'Guardar',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                },
              );
            },
            child: const Icon(
              Icons.more_vert_rounded,
              size: 25,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget chats() {
    return ListView.builder(
      controller: scroll,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: chatList.length,
      itemBuilder: (context, index) => _itemChat(
          chat: chatList[index].chat,
          message: chatList[index].msg,
          index: index),
    );
  }

  Widget _bodyChat() {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(45), topRight: Radius.circular(45)),
          color: Colors.white,
        ),
        child: chats(),
      ),
    );
  }

  _itemChat({required int chat, required String message, required int index}) {
    return Row(
      mainAxisAlignment:
          chat == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Flexible(
        //   child: Container(
        //     margin: const EdgeInsets.only(
        //       left: 10,
        //       right: 10,
        //       top: 10,
        //     ),
        //     padding: const EdgeInsets.symmetric(
        //       vertical: 10,
        //       horizontal: 10,
        //     ),
        //     decoration: BoxDecoration(
        //       color: getColor(chat, index),
        //       borderRadius: chat == 0
        //           ? const BorderRadius.only(
        //               topLeft: Radius.circular(10),
        //               topRight: Radius.circular(10),
        //               bottomLeft: Radius.circular(10),
        //             )
        //           : const BorderRadius.only(
        //               topLeft: Radius.circular(10),
        //               topRight: Radius.circular(10),
        //               bottomRight: Radius.circular(10),
        //             ),
        //     ),
        //     child: chatWidget(message, index),
        //   ),
        // ),
        Bubble(
          margin: const BubbleEdges.only(top: 10),
          alignment: chat == 0 ? Alignment.topRight : Alignment.topLeft,
          nip: chat == 0 ? BubbleNip.rightTop : BubbleNip.leftTop,
          color: getColor(chat, index),
          child: chatWidget(message, index, chat),
        ),
        Container(
          color: getColor(chat, index),
        )
      ],
    );
  }

  Widget chatWidget(String text, int index, int chat) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      child: DefaultTextStyle(
          style: TextStyle(
            color: Colors.black,
            fontSize: waitingResponse && text == '...' ? 25 : 16,
          ),
          child: waitingResponse && text == '...'
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedTextKit(
                    isRepeatingAnimation: true,
                    animatedTexts: [
                      WavyAnimatedText(
                        text.replaceFirst('\n\n', ''),
                      ),
                    ],
                    repeatForever: true,
                  ),
                )
              : GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      selectedItem = index;
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  onLongPress: () async {
                    SnackBar snackBar = SnackBar(
                      content: const Center(
                        heightFactor: 1,
                        child: Text("Texto copiado"),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height / 10,
                          left: MediaQuery.of(context).size.width / 4,
                          right: MediaQuery.of(context).size.width / 4),
                    );

                    await Clipboard.setData(ClipboardData(text: text))
                        .then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {
                        selectedItem = -1;
                      });
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      selectedItem = -1;
                    });
                  },
                  child: Text(text.replaceFirst('\n\n', ''),
                      textAlign: chat == 0 ? TextAlign.right : TextAlign.left),
                )),
    );
  }

  Widget _formChat() {
    return Positioned(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: Colors.white,
          child: TextField(
            controller: mesageController,
            decoration: InputDecoration(
              hintText: 'Escribe tu mensaje...',
              suffixIcon: InkWell(
                onTap: (() async {
                  messagePrompt = mesageController.text.toString();
                  setState(() {
                    waitingResponse = true;
                    chatList.add(Chat(msg: messagePrompt, chat: 0));
                    _scrollDown();
                    chatList.add(Chat(msg: '...', chat: 1));
                    _scrollDown();
                    mesageController.clear();
                  });
                  chatList.addAll(await submitGetChatsForm(
                    context: context,
                    prompt: messagePrompt,
                    tokenValue: tokenValue,
                  ));
                  setState(() {
                    waitingResponse = false;
                    chatList = chatList
                        .where((element) =>
                            (element.msg != '...' && element.chat == 1) ||
                            element.chat == 0)
                        .toList();
                  });
                  _scrollDown();
                }),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color(0xFF292B4D)),
                  padding: const EdgeInsets.all(14),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              filled: true,
              fillColor: Colors.blueGrey.shade50,
              labelStyle: const TextStyle(fontSize: 12),
              contentPadding: const EdgeInsets.all(20),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey.shade50),
                borderRadius: BorderRadius.circular(25),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey.shade50),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _scrollDown() {
    Timer(const Duration(milliseconds: 100), () {
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 750),
      );
    });
  }

  getColor(int chat, int index) {
    if (chat == 0) {
      return selectedItem == index
          ? Colors.indigo.shade200
          : Colors.indigo.shade100;
    }

    return selectedItem == index
        ? Colors.indigo.shade100
        : Colors.indigo.shade50;
  }
}
