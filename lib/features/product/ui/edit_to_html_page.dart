import 'package:file_picker/file_picker.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class EditorToHtmlPage extends StatefulWidget {
  final String result;
   const EditorToHtmlPage( {this.result = '', Key? key}) : super(key: key);

  @override
  State<EditorToHtmlPage> createState() => _EditorToHtmlPageState();
}


class _EditorToHtmlPageState extends State<EditorToHtmlPage> {
  Future set_url_hainong () async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('hainong_url', Constants().baseUrl);
  }
  @override
  void initState()  {
    set_url_hainong();
    super.initState();
    _result = widget.result;
  }

  final HtmlEditorController controller = HtmlEditorController();
  String _result = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 0, centerTitle: true,
        title: const Text('Mô tả'),
        elevation: 0,
        actions: [TextButton(onPressed: () async {
          // controller.toggleCodeView();
          var txt = await controller.getText();
          UtilUI.goBack(context, txt);
        }, child: const Text('Xong', style: TextStyle(color: Colors.white, fontSize: 18)))]
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 1.sh,
              child: HtmlEditor(
                controller: controller,
                htmlEditorOptions: HtmlEditorOptions(
                  darkMode: false,
                  hint: 'Nhập nội dung ...',
                  shouldEnsureVisible: true,
                  initialText: _result,
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarPosition: ToolbarPosition.aboveEditor,
                  audioExtensions: [''],
                  //by default
                  toolbarType: ToolbarType.nativeGrid, //by default
                  onButtonPressed: (ButtonType type, bool? status,
                      Function()? updateStatus) {
                    //print("button '${describeEnum(type)}' pressed, the current selected status is $status");
                    return true;
                  },
                  onDropdownChanged: (DropdownType type, dynamic changed,
                      Function(dynamic)? updateSelectedItem) {
                    //print("dropdown '${describeEnum(type)}' changed to $changed");
                    return true;
                  },
                  mediaLinkInsertInterceptor:
                      (String url, InsertFileType type) {
                    //print(url);
                    return true;
                  },
                  mediaUploadInterceptor: (PlatformFile file, InsertFileType type) async {
                    //print(file.name); //filename
                    //print(file.size); //size in bytes
                    //print(file.extension); //file extension (eg jpeg or mp4)
                    return true;
                  },
                ),
                otherOptions: const OtherOptions(height: 800),
                callbacks: Callbacks(onBeforeCommand: (String? currentHtml) {
                  //print('html before change is $currentHtml');
                }, onChangeContent: (String? changed) {
                  //print('content changed to $changed');
                }, onChangeCodeview: (String? changed) {
                  // print('code changed to $changed');
                }, onChangeSelection: (EditorSettings settings) {
                  // print('parent element is ${settings.parentElement}');
                  // print('font name is ${settings.fontName}');
                }, onDialogShown: () {
                  // print('dialog shown');
                }, onEnter: () {
                  // print('enter/return pressed');
                }, onFocus: () {
                  // print('editor focused');
                }, onBlur: () {
                  // print('editor unfocused');
                }, onBlurCodeview: () {
                  // print('codeview either focused or unfocused');
                }, onInit: () {
                  // print('init');
                },
                    //this is commented because it overrides the default Summernote handlers
                    /*onImageLinkInsert: (String? url) {
                      print(url ?? "unknown url");
                    },
                    onImageUpload: (FileUpload file) async {
                      print(file.name);
                      print(file.size);
                      print(file.type);
                      print(file.base64);
                    },*/
                    onImageUploadError: (FileUpload? file, String? base64Str,
                        UploadError error) {
                      //print(describeEnum(error));
                      //print(base64Str ?? '');
                      if (file != null) {
                        //print(file.name);
                        //print(file.size);
                        //print(file.type);
                      }
                    }, onKeyDown: (int? keyCode) {
                      //print('$keyCode key downed');
                      //print('current character count: ${controller.characterCount}');
                    }, onKeyUp: (int? keyCode) {
                      //print('$keyCode key released');
                    }, onMouseDown: () {
                      //print('mouse downed');
                    }, onMouseUp: () {
                      //print('mouse released');
                    }, onNavigationRequestMobile: (String url) {
                      //print(url);
                      return NavigationActionPolicy.ALLOW;
                    }, onPaste: () {
                      //print('pasted into editor');
                    }, onScroll: () {
                      //print('editor scrolled');
                    }),
                plugins: [
                  SummernoteAtMention(
                      getSuggestionsMobile: (String value) {
                        var mentions = <String>['test1', 'test2', 'test3'];
                        return mentions
                            .where((element) => element.contains(value))
                            .toList();
                      },
                      mentionsWeb: ['test1', 'test2', 'test3'],
                      onSelect: (String value) {
                        //print(value);
                      }),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Colors.blueGrey),
            //         onPressed: () {
            //           controller.undo();
            //         },
            //         child:
            //         Text('Undo', style: TextStyle(color: Colors.white)),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Colors.blueGrey),
            //         onPressed: () {
            //           controller.clear();
            //         },
            //         child:
            //         Text('Reset', style: TextStyle(color: Colors.white)),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () async {
            //           var txt = await controller.getText();
            //           if (txt.contains('src=\"data:')) {
            //             txt =
            //             '<text removed due to base-64 data, displaying the text could cause the app to crash>';
            //           }
            //           setState(() {
            //             _result = txt;
            //           });
            //         },
            //         child: Text(
            //           'Submit',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () {
            //           controller.redo();
            //         },
            //         child: Text(
            //           'Redo',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(result),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Colors.blueGrey),
            //         onPressed: () {
            //           controller.disable();
            //         },
            //         child: Text('Disable',
            //             style: TextStyle(color: Colors.white)),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () async {
            //           controller.enable();
            //         },
            //         child: Text(
            //           'Enable',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 16),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () {
            //           controller.insertText('Google');
            //         },
            //         child: Text('Insert Text',
            //             style: TextStyle(color: Colors.white)),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () {
            //           controller.insertHtml(
            //               '''<p style="color: blue">Google in blue</p>''');
            //         },
            //         child: Text('Insert HTML',
            //             style: TextStyle(color: Colors.white)),
            //       ),
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () async {
            //           controller.insertLink(
            //               'Google linked', 'https://google.com', true);
            //         },
            //         child: Text(
            //           'Insert Link',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () {
            //           controller.insertNetworkImage(
            //               'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
            //               filename: 'Google network image');
            //         },
            //         child: Text(
            //           'Insert network image',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 16),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Colors.blueGrey),
            //         onPressed: () {
            //           controller.addNotification(
            //               'Info notification', NotificationType.info);
            //         },
            //         child:
            //         Text('Info', style: TextStyle(color: Colors.white)),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Colors.blueGrey),
            //         onPressed: () {
            //           controller.addNotification(
            //               'Warning notification', NotificationType.warning);
            //         },
            //         child: Text('Warning',
            //             style: TextStyle(color: Colors.white)),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () async {
            //           controller.addNotification(
            //               'Success notification', NotificationType.success);
            //         },
            //         child: Text(
            //           'Success',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () {
            //           controller.addNotification(
            //               'Danger notification', NotificationType.danger);
            //         },
            //         child: Text(
            //           'Danger',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 16),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Colors.blueGrey),
            //         onPressed: () {
            //           controller.addNotification('Plaintext notification',
            //               NotificationType.plaintext);
            //         },
            //         child: Text('Plaintext',
            //             style: TextStyle(color: Colors.white)),
            //       ),
            //       SizedBox(
            //         width: 16,
            //       ),
            //       TextButton(
            //         style: TextButton.styleFrom(
            //             backgroundColor: Theme.of(context).accentColor),
            //         onPressed: () async {
            //           controller.removeNotification();
            //         },
            //         child: Text(
            //           'Remove',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
