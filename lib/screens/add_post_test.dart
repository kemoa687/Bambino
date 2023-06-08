import 'dart:convert';
import 'dart:typed_data';
import 'package:babmbino/resources/storage_methods.dart';
import 'package:babmbino/responsive/mobile_screen_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:babmbino/providers/user_provider.dart';
import 'package:babmbino/resources/firestore_methods.dart';
import 'package:babmbino/utils/utils.dart';
import 'package:mailer/smtp_server.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:http/http.dart' as http;
import 'package:spell_check_on_client/spell_check_on_client.dart';
import 'package:babmbino/models/emotion_checker.dart';
import 'package:mailer/mailer.dart';

Color textColor = const Color(0xffbcbcbc);
Color publicColor = Color(0xffcef1ec);
Color privateColor = Color(0xfff7f8f8);
TextEditingController _titleController = TextEditingController(text: '');
TextEditingController _bodyController = TextEditingController(text: '');
List<Widget> _addedWidgets = [];
String language = 'English';
String didYouMean = '';
SpellCheck spellCheck = SpellCheck.fromWordsList([]);
List<String> _addedStories = [];
List<String> _addedPics = [];
List<String> match = [];
List<String> emotions = [];
var URL = Uri.parse("http://192.168.114.183:8080/emotion");
late Future<emotion> emotionData;
String privacy = 'public';
String isSaved = 'notSaved';

class AddStoryTitle extends StatefulWidget {
  const AddStoryTitle({Key? key}) : super(key: key);

  @override
  State<AddStoryTitle> createState() => _AddStoryTitleState();
}

class _AddStoryTitleState extends State<AddStoryTitle> {
  @override
  void initstate() {
    super.initState();
    _titleController = TextEditingController(text: '');
    setState(() {
      _addedStories = [];
      _addedPics = [];
      match=[];
      emotions= [];
    });
  }

  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Write what ever you want'),
        backgroundColor: Color(0xff1cb38b),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        userProvider.getUser.photoUrl,
                      ),
                      radius: 35,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Flexible(child: Text(userProvider.getUser.username)),
                  const SizedBox(
                    height: 60,
                  ),
                  Flexible(
                    child: Container(
                      width: 200,
                      child: TextField(
                        autocorrect: true,
                        autofocus: true,
                        onTap: () {
                          setState(() {
                            textColor = const Color(0xff9fc5e8);
                          });
                        },
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Write a title',
                          hintStyle: TextStyle(color: textColor),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: publicColor,
                            ),
                            width: 80,
                            height: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.public,
                                  size: 25,
                                ),
                                Text(
                                  'Public',
                                  style: TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              privacy = 'public';
                              publicColor = Color(0xffcef1ec);
                              privateColor = Color(0xfff7f8f8);
                            });
                          },
                        ),
                        InkWell(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 25,
                                ),
                                Text(
                                  'Private',
                                  style: TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: privateColor),
                            width: 80,
                            height: 80,
                          ),
                          onTap: () {
                            setState(() {
                              privacy = 'private';
                              publicColor = Color(0xfff7f8f8);
                              privateColor = Color(0xffcef1ec);
                            });
                          },
                        ),
                      ]),
                  Flexible(
                    child: SizedBox(
                        width: 170,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: Color(0xff4ecca8),
                              side: const BorderSide(
                                  width: 2, color: Color(0xff00838FFF)),
                            ),
                            onPressed: () {
                              _titleController.text == '' ?
                              showSnackBar(context, 'Please enter a title'):
                              setState(() {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddStoryBody()));
                              });
                              print('the title is ${_titleController.text}');
                              print('the privacy is $privacy');
                            },
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Next",
                                      style: TextStyle(
                                          color: Color(0xffffffff),
                                          fontSize: 25)),
                                  Icon(
                                    Icons.navigate_next,
                                    color: Color(0xffffffff),
                                  )
                                ]))),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddStoryBody extends StatefulWidget {
  const AddStoryBody({Key? key}) : super(key: key);

  @override
  State<AddStoryBody> createState() => _AddStoryBodyState();
}

class _AddStoryBodyState extends State<AddStoryBody> {
  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController(text: '');
    didYouMean = '';
    initSpellCheck();
    // emotionData = getPost('', '', false, _addedStories);
  }

  void initSpellCheck() async {
    String content = await rootBundle.loadString('assets/en_words.txt');
    spellCheck = SpellCheck.fromWordsContent(content,
        letters: LanguageLetters.getLanguageForLanguage(language));
  }

  void spellCheckValidate() {
    String text = _bodyController.text;
    didYouMean = spellCheck.didYouMean(text);
    setState(() {});
  }

  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Card(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        userProvider.getUser.photoUrl,
                      ),
                      radius: 35,
                    ),
                    Text(userProvider.getUser.username),
                    const SizedBox(
                      height: 60,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                          color: Color(0xffeeeeee),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Center(
                        child: TextField(
                          autofocus: true,
                          onTap: () {
                            setState(() {
                              textColor = const Color(0xff9fc5e8);
                            });
                          },
                          controller: _bodyController,
                          decoration: InputDecoration(
                            hintText: 'Write your story',
                            hintStyle: TextStyle(color: textColor),
                          ),
                          keyboardType: TextInputType.text,
                          maxLines: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        width: 170,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: Color(0xff4ecca8),
                              side: const BorderSide(
                                  width: 2, color: Color(0xff00838FFF)),
                            ),
                            onPressed: () {
                              setState(() {
                                _addedWidgets = [];
                              });
                              spellCheckValidate();
                              if (didYouMean == '') {
                                _addedStories.add(_bodyController.text);
                                // getPost(userProvider.getUser.parentEmail,
                                //     userProvider.getUser.username, false, _addedStories);
                                //print ('the final $finalEmotions');
                                //sendAutomaticEmail(userProvider.getUser.parentEmail, userProvider.getUser.username);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Test()));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'The following message contains the right spelling for your story, would you like to post it?'),
                                        content: Text(didYouMean),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _addedWidgets = [];
                                                  _bodyController.text =
                                                      didYouMean;
                                                  _addedStories.add(
                                                      _bodyController.text);
                                                });
                                                // getPost(
                                                //     userProvider
                                                //         .getUser.parentEmail,
                                                //     userProvider
                                                //         .getUser.username,
                                                //     false, _addedStories);
                                                //sendAutomaticEmail(userProvider.getUser.parentEmail, userProvider.getUser.username);
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Test()));
                                              },
                                              child: const Text('Continue')),
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _addedWidgets = [];
                                                });
                                                _addedStories
                                                    .add(_bodyController.text);
                                                // getPost(
                                                //     userProvider
                                                //         .getUser.parentEmail,
                                                //     userProvider
                                                //         .getUser.username,
                                                //     false, _addedStories);
                                                // //sendAutomaticEmail(userProvider.getUser.parentEmail, userProvider.getUser.username);
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Test()));
                                              },
                                              child: const Text('Ignore')),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancel'))
                                        ],
                                      );
                                    });
                              }
                            },
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Visualize it",
                                      style: TextStyle(
                                          color: Color(0xffffffff),
                                          fontSize: 20)),
                                  Icon(
                                    Icons.draw,
                                    color: Color(0xffffffff),
                                  )
                                ]))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  Color selectedColor = Color(0xff000000);
  GlobalKey _containerKey = GlobalKey();
  Uint8List? _image;
  bool IsImage = false;
  Color _color = Color(0xffeeeeee);
  bool _showDeleteButton = false;
  bool IsDeleteButtonActive = false;
  bool isLoading = false;
  Uint8List _file = Uint8List(0);

  void postImage(String uid, String username, String profImage) async {
    RenderRepaintBoundary renderRepaintBoundary = _containerKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 1);
    ByteData byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png) as dynamic;
    Uint8List uint8list = byteData.buffer.asUint8List();
    setState(() {
      // loading = false;
      _file = uint8list;
    });
    print('the stories are $_addedStories');
    print('the pics are $_addedPics');
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
          _titleController.text,
          _file,
          uid,
          username,
          profImage,
          _bodyController.text,
          _addedStories,
          _addedPics,
          privacy,
          isSaved);
      if (res == "success") {
        setState(() {
          isLoading = false;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => MobileScreenLayout()));
        });
        showSnackBar(
          context,
          'Posted!',
        );
        _titleController.text = '';
        _bodyController.text = '';
        _addedPics = [];
        _addedStories = [];
        privacy = 'public';
        isSaved = 'notSaved';
        didYouMean = '';
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: RepaintBoundary(
            key: _containerKey,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                  color: _color, borderRadius: BorderRadius.circular(20)),
              child: Stack(alignment: Alignment.center, children: [
                IsImage
                    ? Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                alignment: FractionalOffset.topCenter,
                                image: MemoryImage(_image!)
                                    as ImageProvider<Object>)))
                    : Container(),
                for (int i = 0; i < _addedWidgets.length; i++) _addedWidgets[i],
                if (_showDeleteButton)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Icon(
                        Icons.delete,
                        size: IsDeleteButtonActive ? 40 : 25,
                        color: IsDeleteButtonActive
                            ? Color(0xfff44336)
                            : Color(0xff2986cc),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Color(0xff4ecca8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Builder(
              builder: (context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: Icon(Icons.add),
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    InkWell(
                      child: Icon(Icons.color_lens_outlined),
                      onTap: () {
                        pickColor(context);
                      },
                    ),
                    InkWell(
                      child: Icon(Icons.image),
                      onTap: () async {
                        Uint8List image = await pickImage(ImageSource.gallery);
                        setState(() {
                          _image = image;
                          IsImage = true;
                          //here
                        });
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        RenderRepaintBoundary renderRepaintBoundary =
                            _containerKey.currentContext!.findRenderObject()
                                as RenderRepaintBoundary;
                        ui.Image boxImage =
                            await renderRepaintBoundary.toImage(pixelRatio: 1);
                        ByteData byteData = await boxImage.toByteData(
                            format: ui.ImageByteFormat.png) as dynamic;
                        Uint8List pic = byteData.buffer.asUint8List();
                        setState(() {
                          // loading = false;
                          _file = pic;
                        });
                        String _getPhotoURL = await StorageMethods()
                            .uploadImageToStorage('posts', _file, true);
                        print(_getPhotoURL);
                        _addedPics.add(_getPhotoURL);
                        print('the title is: ${_titleController.text}');
                        postImage(
                          userProvider.getUser.uid,
                          userProvider.getUser.username,
                          userProvider.getUser.photoUrl,
                        );
                        getPost(userProvider.getUser.parentEmail,
                            userProvider.getUser.username, _addedStories);
                      },
                      child: isLoading == false
                          ? const Chip(
                              label: Text(
                                'Publish',
                                style: TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 16,
                                ),
                              ),
                              backgroundColor: Color(0xff253f3c),
                              labelPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                            )
                          : const CircularProgressIndicator(
                              color: Color(0xffffffff),
                            ),
                    )
                  ],
                );
              },
            )),
      ),
      drawer: Drawer(
        width: 200,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _container('assets/drag/bear.png'),
              _container('assets/drag/dog.png'),
              _container('assets/drag/bed.png'),
              _container('assets/drag/bicycle.png'),
              _container('assets/drag/bird.png'),
              _container('assets/drag/boy.png'),
              _container('assets/drag/bus.png'),
              _container('assets/drag/car.png'),
              _container('assets/drag/cat.png'),
              _container('assets/drag/cloud.png'),
              _container('assets/drag/deer.png'),
              _container('assets/drag/dog.png'),
              _container('assets/drag/factory.png'),
              _container('assets/drag/giraff.png'),
              _container('assets/drag/girl.png'),
              _container('assets/drag/horse.png'),
              _container('assets/drag/house.png'),
              _container('assets/drag/lamppost.png'),
              _container('assets/drag/mobile.png'),
              _container('assets/drag/moon.png'),
              _container('assets/drag/mosque.png'),
              _container('assets/drag/pc.png'),
              _container('assets/drag/policeStation.png'),
              _container('assets/drag/school.png'),
              _container('assets/drag/train.png'),
              _container('assets/drag/tree.png'),
              _container('assets/drag/tv.png'),
              _container('assets/drag/university.png'),
              _container('assets/drag/zoo.png'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff79dec7),
        onPressed: () async {
          RenderRepaintBoundary renderRepaintBoundary =
              _containerKey.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          ui.Image boxImage =
              await renderRepaintBoundary.toImage(pixelRatio: 1);
          ByteData byteData = await boxImage.toByteData(
              format: ui.ImageByteFormat.png) as dynamic;
          Uint8List pic = byteData.buffer.asUint8List();
          setState(() {
            // loading = false;
            _file = pic;
            _bodyController.text = '';
          });
          String _getPhotoURL =
              await StorageMethods().uploadImageToStorage('posts', _file, true);
          print(_getPhotoURL);
          _addedPics.add(_getPhotoURL);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddStoryBody()));
          _showDeleteButton = false;
          IsDeleteButtonActive = false;
          setState(() {
            didYouMean = '';
          });
        },
        child: Icon(
          Icons.add_card_outlined,
          color: Color(0xff000000),
        ),
      ),
    );
  }

  Widget _container(String path) {
    return InkWell(
      onTap: () {
        setState(() {
          _addedWidgets.add(OverlayedWidget(
            child: Image.asset(path),
            key: Key(_addedWidgets.length.toString()),
            onDragStart: () {
              if (!_showDeleteButton) {
                setState(() {
                  _showDeleteButton = true;
                });
              }
            },
            onDragEnd: (offset, key) {
              if (_showDeleteButton) {
                setState(() {
                  _showDeleteButton = false;
                });
              }
              if (offset.dy > (MediaQuery.of(context).size.height - 100)) {
                _addedWidgets.removeWhere((widget) => widget.key == key);
              }
            },
            onDragUpdate: (offset, key) {
              if (offset.dy > (MediaQuery.of(context).size.height - 100)) {
                if (!IsDeleteButtonActive) {
                  setState(() {
                    IsDeleteButtonActive = true;
                  });
                }
              } else {
                if (IsDeleteButtonActive) {
                  setState(() {
                    IsDeleteButtonActive = false;
                  });
                }
              }
            },
          ));
        });
      },
      child: Container(
          padding: EdgeInsets.all(20),
          width: 100,
          height: 100,
          child: Image.asset(path)),
    );
  }

  Widget buildColorPicker() {
    return ColorPicker(
        pickerColor: _color,
        onColorChanged: (_color) {
          setState(() {
            this._color = _color;
          });
        });
  }

  void pickColor(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Pick up your color'),
              content: Column(
                children: [
                  buildColorPicker(),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Select',
                        style: TextStyle(fontSize: 20),
                      ))
                ],
              ),
            ));
  }
}

typedef PointMoveCallbask = void Function(Offset offset, Key? key);

class OverlayedWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onDragStart;
  final PointMoveCallbask onDragUpdate;
  final PointMoveCallbask onDragEnd;

  const OverlayedWidget(
      {super.key,
      required this.child,
      required this.onDragStart,
      required this.onDragEnd,
      required this.onDragUpdate});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    late Offset offset;
    return Listener(
      onPointerMove: (event) {
        offset = event.position;
        onDragUpdate(offset, key);
      },
      child: MatrixGestureDetector(
          onMatrixUpdate: (m, tm, sm, rm) {
            notifier.value = m;
          },
          onScaleStart: () {
            onDragStart();
          },
          onScaleEnd: () {
            onDragEnd(offset, key);
          },
          child: AnimatedBuilder(
            animation: notifier,
            builder: (ctx, childWidget) {
              return Transform(
                transform: notifier.value,
                child: Stack(
                  fit: StackFit.expand,
                  children: [child],
                ),
              );
            },
          )),
    );
  }
}

Future<emotion> getPost(
    String parentEmail, String sonName, List text) async {
  List x = [];
  Map <String, int> frequency = {} ;
  String mostFrequentItem = '';
  int highestFrequency = 0;
  final response = await http.post(
      URL,
    body: json.encode({
      'samples': text,
    }),
    headers: {
        'Content-Type': "Application/Json; charset=utf-8"
    }
  );
  print ('the new is ${response.body}');
  final jsonObject = json.decode(response.body) as Map <String, dynamic>;
  x = jsonObject['predictions'];
  print (x);
  for (String item in x) {
    if (frequency.containsKey(item)) {
      frequency[item] = (frequency[item]!+1);
    } else {
      frequency[item] = 1;
    }
  }
  frequency.forEach((item, count) {
    if (count > highestFrequency) {
      mostFrequentItem = item;
      highestFrequency = count;
    }
  });
  print ('the highest emotion is $mostFrequentItem');
    sendAutomaticEmail(parentEmail, sonName, mostFrequentItem);
  if (response.statusCode == 200) {
    print(response.body);
    return emotion.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed');
  }
}

void sendAutomaticEmail(
    String parentEmail, String sonName, String content) async {
  final smtpServer = gmail('bambinoservices169@gmail.com', 'vuweuahunigrplxr');
  final message = Message()
    ..from = Address('bambinoservices169@gmail.com', 'Bambino Services')
    ..recipients.add(parentEmail)
    ..subject = 'Emotion Analysis'
    ..text = '''
          Good morning, 
          I hope this email finds you well. We are Bambino Service, sending you an email regardless your son $sonName.
          Our application have detected a feeling of $content ''';
  try {
    await send(message, smtpServer);
    print('Email sent successfully!');
  } catch (e) {
    print('Error sending email: $e');
  }
}