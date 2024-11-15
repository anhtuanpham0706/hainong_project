import 'dart:async';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'handbook_detail_page.dart';
import 'handbook_bloc.dart';

class HandbookPage extends StatefulWidget {
  final bool isCreate;
  const HandbookPage({Key? key, this.isCreate = false}) : super(key: key);

  @override
  _HandbookPageState createState() => _HandbookPageState();
}

class _HandbookPageState extends State<HandbookPage> {
  final TextEditingController _ctrSearch = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scroller = ScrollController();
  final List<HandbookModel> _list = [];
  final _bloc = HandBookBloc();
  int _page = 1;

  @override
  void dispose() {
    _ctrSearch.dispose();
    _focus.dispose();
    _scroller.removeListener(_listenScroller);
    _scroller.dispose();
    _list.clear();
    _bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc.stream.listen((state) {
      if (state is LoadListState) {
        if (state.response.checkTimeout()) UtilUI.showDialogTimeout(context);
        else if (state.response.checkOK()) {
          final list = state.response.data.list;
          if (list.length > 0) {
            _list.addAll(list);
            list.length == Constants().limitPage * 2 ? _page++ : _page = 0;
          } else _page = 0;
        } else UtilUI.showCustomDialog(context, state.response.data);
      } else if (state is CreateQuestionState) {
        if (state.response.checkTimeout()) UtilUI.showDialogTimeout(context);
        else if (state.response.checkOK()) {
          UtilUI.showCustomDialog(context, MultiLanguage.get('msg_create_question_success'),
              title: MultiLanguage.get('ttl_alert'));
          //_list.insert(0, state.response.data);
        } else UtilUI.showCustomDialog(context, state.response.data);
      }
    });
    _loadMore();
    _scroller.addListener(_listenScroller);
    Timer(const Duration(seconds: 2), () {
      if (widget.isCreate) _createQuestion();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(elevation: 0, titleSpacing: 0, title: UtilUI.createLabel(
        MultiLanguage.get('lbl_handbook')), centerTitle: true,
        bottom: PreferredSize(child: Container(width: 1.sw - 80.sp,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.sp)
            ), padding: EdgeInsets.all(30.sp), margin: EdgeInsets.only(bottom: 40.sp),
            child: Row(children: [
              ButtonImageWidget(40.sp, _search, Icon(Icons.search, size: 48.sp, color: const Color(0xFF676767))),
              SizedBox(child: TextField(controller: _ctrSearch, focusNode: _focus,
                onSubmitted: (value) => _search(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 36.sp, color: const Color(0xFF959595)),
                    hintText: 'Nhập từ khóa hoặc nội dung cần tìm',
                    contentPadding: EdgeInsets.zero, isDense: true,
                    border: const UnderlineInputBorder(borderSide: BorderSide.none)
                )
              ), width: 1.sw - 256.sp),
              ButtonImageWidget(40.sp, _clear, Icon(Icons.clear, size: 48.sp, color: const Color(0xFF676767)))
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween)), preferredSize: Size(1.sw, 140.sp))),
        backgroundColor: Colors.white,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: EdgeInsets.all(40.sp), child: UtilUI.createLabel('Câu hỏi thường gặp', textAlign: TextAlign.left,
              fontSize: 54.sp, fontWeight: FontWeight.w500, color: const Color(0xFF494949))),
          Padding(padding: EdgeInsets.symmetric(horizontal: 40.sp), child: const Divider(height: 1)),
          Expanded(child: BlocBuilder(bloc: _bloc,
              buildWhen: (oldState, newState) => newState is LoadListState || newState is CreateQuestionState,
              builder: (context, state) {
                if (state is LoadListState || state is CreateQuestionState) {
                  return ListView.builder(padding: EdgeInsets.zero, controller: _scroller, itemCount: _list.length,
                      itemBuilder: (context, index) => index < _list.length ? _Item(_list[index]):const SizedBox());
                }
                return Loading(_bloc);
              }))
        ]),
        floatingActionButton: Constants().isLogin ? FloatingActionButton(onPressed: _createQuestion,
            backgroundColor: StyleCustom.primaryColor, child: const Icon(Icons.add, color: Colors.white)) : const SizedBox());

  void _loadMore() => _bloc.add(LoadListEvent(_page, _ctrSearch.text.trim()));

  void _listenScroller() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) _loadMore();
  }

  void _createQuestion() async {
    if (await UtilUI().alertVerifyPhone(context)) return;
    UtilUI.showConfirmDialog(
            context, "", MultiLanguage.get('msg_input_question'), MultiLanguage.get('msg_question_empty'),
            title: "Đặt câu hỏi", line: 4, showMsg: false, padding: EdgeInsets.all(30.sp))
        .then((value) {
      if (value != null && value is String) _bloc.add(CreateQuestionEvent(value));
      Util.trackActivities('hand_books', path: 'Hand Books Screen -> Add Questions');
    });
  }

  void _reset() {
    _list.clear();
    _page = 1;
    _loadMore();
  }

  void _search() {
    _focus.unfocus();
    if (_ctrSearch.text.trim().isEmpty) return;
    _reset();
  }

  void _clear() {
    _ctrSearch.text = '';
    _reset();
  }
}

class _Item extends StatelessWidget {
  final HandbookModel item;
  const _Item(this.item);
  @override
  Widget build(BuildContext context) => Column(children: [
    ButtonImageWidget(0, () => _gotoDetail(context), Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
      Expanded(child: Text(item.question, style: TextStyle(fontSize: 45.sp, color: const Color(0xFF282828)))),
      SizedBox(width: 10.sp),
      Padding(child: Icon(Icons.arrow_forward_ios, size: 30.sp, color: const Color(0xFF1AAD80)), padding: EdgeInsets.only(top: 10.sp))
    ], crossAxisAlignment: CrossAxisAlignment.start)))
  ]);

  void _gotoDetail(BuildContext context) {
    UtilUI.goToNextPage(context, HandBookDetailPage(item));
    Util.trackActivities('hand_books', path: 'Hand Book Screen -> Open Hand Book Detail Screen');
  }
}

class HandbooksModel {
  final List<HandbookModel> list = [];
  HandbooksModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(HandbookModel().fromJson(ele)));
    return this;
  }
}

class HandbookModel {
  late String question, answer;
  HandbookModel fromJson(Map<String, dynamic> json) {
    question = Util.getValueFromJson(json, 'question', '');
    answer = Util.getValueFromJson(json, 'answer', '');
    return this;
  }
}