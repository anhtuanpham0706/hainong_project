import 'post_item_page.dart';
import 'import_lib_ui_post.dart';

class SharePage extends StatelessWidget {
  final Post item;
  final int index;
  final String shopId, permission;
  final HomeBloc bloc;
  final bool isCreate;
  final ctrDescription = TextEditingController();
  String shopName = '', shopImage = '';

  SharePage(this.item, this.index, this.bloc, this.shopId,
      {this.isCreate = true, this.permission = '', Key? key}):super(key:key) {
    if (!isCreate) ctrDescription.text = item.description;
    SharedPreferences.getInstance().then((prefs) {
      final Constants constants = Constants();
      shopName = prefs.getString(constants.shopName)??'';
      shopImage = prefs.getString(constants.shopImage)??'';
    });
  }

  @override
  Widget build(BuildContext context) {
    final LanguageKey languageKey = LanguageKey();
    return Scaffold(
        appBar: TaskBarWidget('ttl_share_post',
            lblButton: languageKey.btnPost,
            onPressed: () => _onClickPost(context)).createUI(),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(40.sp),
                color: StyleCustom.backgroundColor,
                child: Column(children: [
                  Row(children: [
                    AvatarCircleWidget(link: shopImage, size: 150.sp),
                    Padding(padding: EdgeInsets.all(10.sp)),
                    Expanded(
                        child: UtilUI.createLabel(shopName,
                            color: Colors.black, fontSize: 45.sp)),
                  ]),
                  TextField(minLines: 1, maxLines: 100,
                      controller: ctrDescription,
                      decoration: InputDecoration(
                          hintText: MultiLanguage.get(
                              languageKey.msgInputShareDescription)),
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline),
                  if (item.shared_post_id.isNotEmpty || isCreate) Padding(
                      padding: EdgeInsets.only(top: 120.sp),
                      child: PostItemPage(item, index, bloc, shopId,
                          isHideControls: true, isHideOption: true)),
                ]))));
  }

  _onClickPost(final BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (await UtilUI().alertVerifyPhone(context)) return;
    final hashTags = Util.createHashTags(ctrDescription.text);
    if (isCreate)
      bloc.add(SharePostHomeEvent(item, ctrDescription.text, index, hashTags));
    else
      bloc.add(CreatePostHomeEvent([], hashTags, '', ctrDescription.text, item.id, context: context, permission: permission));
  }
}
