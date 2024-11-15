import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:hainong/common/ui/banner_2nong.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/title_helper.dart';
import 'package:hainong/features/function/info_news/technical_process/technical_process_model.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../technical_process_bloc.dart';
import 'technical_process_create_contribute_page.dart';
import 'technical_process_item.dart';

class TechnicalProcessListPage extends BasePage {
  TechnicalProcessListPage({Key? key}) : super(key: key, pageState: _TechnicalProcessListPageState());
}

class _TechnicalProcessListPageState extends BasePageState {
  final ScrollController _scroller = ScrollController();
  final ScrollController _scrollerCatSub = ScrollController();
  final ScrollController _scrollerList = ScrollController();
  final ScrollController _scrollerListA = ScrollController();
  // final TextEditingController _ctrSearch = TextEditingController();
  final List<TechProCatModel> _catMain = [], _catSub = [], _catSubProcess = [];
  final Map<String, TechProCatModel> _links = {};
  final List<TechnicalProcessModel> _list = [];
  final Map<String, int> _catMap = {};
  int _page = 1, _indexSub = 0, _index = 0;
  String _cat = '', _keySearch = '';
  TechProCatModel _itemCatMainSelect = TechProCatModel();
  TechProCatModel _itemCatSubSelect = TechProCatModel();
  TechProCatModel _itemCatSubProcessSelect = TechProCatModel();

  @override
  void dispose() {
    _links.clear();
    _catMain.clear();
    _catSub.clear();
    _catSubProcess.clear();
    _list.clear();
    _scrollerList.removeListener(_scrollListListener);
    _scroller.dispose();
    _scrollerCatSub.dispose();
    _scrollerList.dispose();
    // _ctrSearch.dispose();
    _scrollerListA.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = TechnicalProcessBloc();
    super.initState();
    bloc?.stream.listen((state) {
      if (state is LoadListState) {
        if (isResponseNotError(state.response)) {
          _handleLoadList(state.response.data);
        }
      } else if (state is LoadCatalogueState) {
        // load kỹ thuật
        if (state.isSubProcess) {
          _handleListCatSubProcess(state.response, clearList: state.clearList);
          _list.clear();
          bloc?.add(LoadListEvent(1, '', _itemCatSubProcessSelect.id));
          return;
        }
        // load cây trồng
        if (state.idSub.isNotEmpty) {
          _handleListCatSub(state.response, state.idSub,
              clearList: state.clearList, loadPrevious: state.loadPrevious, index: state.index);
          // trường hợp click vào cây trồng nó sẽ load về vị trí đầu và cần phải load 1 mảng trước đó
          // luồng này không cho hoạt động khi có search
          if(state.response.isNotEmpty){
            if (_indexSub == 0 && _index > 0 && _keySearch.isEmpty) {
              bloc?.add(LoadCatalogueEvent(
                  idSub: _catMain[_index - 1].id, clearList: false, loadPrevious: true, index: _index - 1, keyword: _keySearch));
              return;
            }
            if (_indexSub == _catSub.length - 1 &&
                _index < _catMain.length - 1 &&
                state.response.isNotEmpty &&
                _keySearch.isEmpty) {
              bloc?.add(
                  LoadCatalogueEvent(idSub: _catMain[_index + 1].id, clearList: false, index: _index + 1, keyword: _keySearch));
              return;
            }
            bloc?.add(LoadCatalogueEvent(
                isSubProcess: true, idSub: _itemCatSubSelect.id, clearList: state.clearList, keyword: _keySearch));
          }else{
            //list cây trồng rỗng
            // thì không load nhưng catalog con cũng như bài viết quy trình của nó
            _catSubProcess.clear();
            _list.clear();
            bloc?.add(EmptySearchEvent());
          }
          return;
        }
        // load list loại cây trồng
        _handleListCatMain(state.response, clearList: state.clearList);
        bloc?.add(LoadCatalogueEvent(idSub: _itemCatMainSelect.id, clearList: state.clearList, keyword: _keySearch));
      } else if (state is ChangeIndexState) {
        if (_index != -1) _itemCatMainSelect = _catMain[_index];
        scrollToSelected(_index);
      }
    });
    bloc?.add(LoadCatalogueEvent(keyword: _keySearch));
    _scrollerList.addListener(_scrollListListener);
  }

  _scrollListListener() {
    if (_page > 0 && _scroller.position.maxScrollExtent == _scroller.position.pixels) {
      bloc!.add(LoadListEvent(_page, '', _itemCatSubProcessSelect.id));
    }
  }

  void scrollToSelected(int index) {
    // final contentSize = _scroller.position.viewportDimension + _scroller.position.maxScrollExtent;
    // final target = contentSize * index / _catMain.length + (index == (_catMain.length - 1) ? 0 : -350.sp);
    // _scroller.animateTo(
    //   target,
    //   duration: const Duration(milliseconds: 500),
    //   curve: Curves.easeInOut,
    // );
    double offset = index * 0.333.sw + (0.45.sw  / 2) - (1.sw / 2);
    if(_scroller.hasClients){
    _scroller.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    }
  }

  void scrollCatSubToSelected(int index, {bool keepPosition = false}) {

    double offset = index * 0.333.sw + 0.45.sw/2 - 1.sw/2 + (index == 0? (0.45.sw/2 ): index ==_catSub.length-1? - (0.45.sw/2): 0);
    if(_scrollerCatSub.hasClients){
      _scrollerCatSub.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _backScroll() {
      if (_indexSub > 0) _indexSub = _indexSub - 1;
      bloc?.add(ChangeIndexEvent(_checkIndexItem(id: _catSub[_indexSub].id)));
      _itemCatSubSelect = _catSub[_indexSub];
      scrollCatSubToSelected(_indexSub);
      if(_indexSub == 0){
        if (_index > 0 && _keySearch.isEmpty) {
          bloc?.add(LoadCatalogueEvent(
              idSub: _catMain[_index - 1].id, clearList: false, loadPrevious: true, index: _index - 1, keyword: _keySearch));
        }
        if(_index ==0) return;
      }
      bloc?.add(LoadCatalogueEvent(idSub: _itemCatSubSelect.id, isSubProcess: true, keyword: _keySearch));
  }

  void _nextScroll() {
    if(_indexSub == _catSub.length -1 && _index == _catMain.length -1 ) return;
    if (_indexSub < _catSub.length - 1) {
      _indexSub = _indexSub + 1;
      if (_index < _catMain.length - 1 && _indexSub == _catSub.length - 1 && _keySearch.isEmpty) {
        bloc?.add(LoadCatalogueEvent(idSub: _catMain[_index + 1].id, clearList: false, index: _index + 1, keyword: _keySearch));
      }
    }
    bloc?.add(ChangeIndexEvent(_checkIndexItem(id: _catSub[_indexSub].id)));
    _itemCatSubSelect = _catSub[_indexSub];
    scrollCatSubToSelected(_indexSub);
    if (_indexSub != _catSub.length - 1 || _index == _catMain.length - 1)
      bloc?.add(LoadCatalogueEvent(idSub: _itemCatSubSelect.id, isSubProcess: true, keyword: _keySearch));
  }

  void _setCatList({required String id, required int index}) {
    if (_catMap.containsKey(id) && _keySearch.isEmpty) return;
    _catMap[id] = index;
  }

  int _checkIndexItem({required String id}) {
    _index = _catMap[id] ?? -1;
    return _index;
  }

  void _selectCatMain(TechProCatModel main, int index) {
    if(main.id == _itemCatMainSelect.id) return;
    _index = index;
    _itemCatMainSelect = _catMain[index];
    scrollToSelected(index);
    _indexSub = 0;
    _catSub.clear();
    _catSubProcess.clear();
    bloc?.add(LoadCatalogueEvent(
      idSub: _itemCatMainSelect.id,
      keyword: _keySearch,
      isMainSelect: true,
    ));
  }

  void _selectCatSub(TechProCatModel sub, int index) {
    if(sub.id == _itemCatSubSelect.id) return;
    _indexSub = index;
    _itemCatSubSelect = _catSub[_indexSub];
    final _indexOfItem = _checkIndexItem(id: sub.id);

    bloc?.add(ChangeIndexEvent(_indexOfItem));
    if (_indexSub == 0 && _index > 0) {
      bloc?.add(LoadCatalogueEvent(
          idSub: _catMain[_index - 1].id, clearList: false, loadPrevious: true, index: _index - 1, keyword: _keySearch));
    }
    if (_indexSub == _catSub.length - 1 && _index < _catMain.length - 1) {
      bloc?.add(LoadCatalogueEvent(idSub: _catMain[_index + 1].id, clearList: false, index: _index + 1, keyword: _keySearch));
    }
    scrollCatSubToSelected(_indexSub);
    _catSubProcess.clear();
    bloc?.add(LoadCatalogueEvent(idSub: _itemCatSubSelect.id, isSubProcess: true, keyword: _keySearch));
  }

  void _selectProcess(TechProCatModel techModel) {
    if(techModel.id == _itemCatSubProcessSelect.id) return;
    _itemCatSubProcessSelect = techModel;
    bloc?.add(LoadListEvent(_page, '', techModel.id));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) => Stack(children: [
    WillPopScope(
          child: Scaffold(
              backgroundColor: color,
              appBar: AppBar(
                  elevation: 0,
                  titleSpacing: 0,
                  centerTitle: true,
                  title: const TitleHelper('lbl_technical_process2', url: 'https://help.hainong.vn/muc/1'),
                  actions: [
                    if (constants.isLogin)
                      IconButton(
                          onPressed: () async {
                            if (await UtilUI().alertVerifyPhone(context)) return;
                            UtilUI.goToNextPage(context, TPCreateContributePage());
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white))
                  ],
                  // bottom: PreferredSize(
                  //     preferredSize: Size(1.sw, 140.sp),
                  //     child: Container(
                  //         width: 1.sw - 80.sp,
                  //         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.sp)),
                  //         padding: EdgeInsets.all(30.sp),
                  //         margin: EdgeInsets.only(bottom: 40.sp),
                  //         child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //           ButtonImageWidget(100, _search, Icon(Icons.search, size: 48.sp, color: const Color(0xFF676767))),
                  //           SizedBox(
                  //               child: TextField(
                  //                   controller: _ctrSearch,
                  //                   onSubmitted: (value) => _search(),
                  //                   textInputAction: TextInputAction.search,
                  //                   decoration: InputDecoration(
                  //                       hintStyle: TextStyle(fontSize: 36.sp, color: const Color(0xFF959595)),
                  //                       hintText: 'Bạn muốn xem kỹ thuật cây trồng nào',
                  //                       contentPadding: EdgeInsets.zero,
                  //                       isDense: true,
                  //                       border: const UnderlineInputBorder(borderSide: BorderSide.none))),
                  //               width: 1.sw - 256.sp),
                  //           ButtonImageWidget(100, _clear, Icon(Icons.clear, size: 48.sp, color: const Color(0xFF676767)))
                  //         ])))
                  ),
              body: BlocBuilder(
                  bloc: bloc,
                  buildWhen: (state1, state2) => state2 is LoadCatalogueState || state2 is ChangeIndexState,
                  builder: (context, state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 8.sp,),
                            margin: EdgeInsets.only(bottom: 20.sp,left: 50.sp, right: 50.sp),
                            height: 100.sp,
                            child: ListView.builder(
                                controller: _scroller,
                                itemCount: _catMain.length,
                                physics: const ClampingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  bool isSelect = _catMain[index].id == _itemCatMainSelect.id;
                                  // if (index > 0) return TechnicalProcessItem(_list[index], index);
                                  return GestureDetector(
                                      onTap: () => _selectCatMain(_catMain[index], index),
                                      child: SizedBox(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                                              child: Text(
                                                _catMain[index].name,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: isSelect ? const Color(0xff2EC67E) : Colors.black,
                                                    fontSize: 45.sp,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            if (isSelect)
                                              Container(
                                                width: 0.333.sw,
                                                height: 5.sp,
                                                color: const Color(0xff2EC67E),
                                              )
                                          ],
                                        ),
                                        width: 0.333.sw,
                                      ));
                                }),
                          ),
                          SizedBox(
                            height: 0.18.sh ,
                            child: BlocBuilder(
                              bloc: bloc,
                              buildWhen: (olds, news) => (news is LoadCatalogueState && news.idSub.isNotEmpty),
                              builder: (context, state) => _catSub.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(10.sp),
                                        child: Text(
                                          'Không tìm thấy cây trồng nào liên quan',
                                          style: TextStyle(color: Colors.black, fontSize: 45.sp),
                                        ),
                                      ),
                                    )
                                  : NotificationListener<ScrollNotification>(
                                      onNotification: (ScrollNotification scrollInfo) {
                                        if (scrollInfo is ScrollEndNotification) {
                                          if (_scrollerListA.position.userScrollDirection == ScrollDirection.forward) {
                                            _backScroll();
                                          } else if (_scrollerListA.position.userScrollDirection == ScrollDirection.reverse) {
                                            _nextScroll();
                                          }
                                          Future.delayed(const Duration(milliseconds: 500));
                                        }
                                        return true;
                                      },
                                      child: SingleChildScrollView(
                                          controller: _scrollerListA,
                                          physics: const ClampingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          child: SizedBox(
                                            width: 1.sw + 4.sp,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                InkWell(
                                                    child: Icon(
                                                      Icons.arrow_left,
                                                      color: Colors.grey,
                                                      size: 80.sp,
                                                    ),
                                                    onTap: () => _backScroll()),
                                                Expanded(child: ListView.builder(
                                                    itemExtent: 0.33.sw,
                                                    controller: _scrollerCatSub,
                                                    itemCount: _catSub.length,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    scrollDirection: Axis.horizontal,
                                                    itemBuilder: (context, index) {
                                                      bool isSelect = _catSub[index].id == _itemCatSubSelect.id;
                                                      return _item(_catSub[index], () => _selectCatSub(_catSub[index], index),
                                                          isSelect: isSelect);
                                                    }),),
                                                InkWell(
                                                  child: Icon(
                                                    Icons.arrow_right,
                                                    color: Colors.grey,
                                                    size: 80.sp,
                                                  ),
                                                  onTap: () => _nextScroll(),
                                                ),
                                              ],
                                            ),
                                          ))),
                            ),
                          ),
                          Divider(color: Colors.black12,thickness: 20.sp),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
                            child: BlocBuilder(
                              bloc: bloc,
                              buildWhen: (olds, news) => news is LoadCatalogueState && news.isSubProcess || news is LoadListState || news is EmptySearchState,
                              builder: (context, state) => _catSubProcess.isNotEmpty? Wrap(
                                spacing: 20.sp,
                                runSpacing: 20.sp,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: _catSubProcess
                                    .map((e) => GestureDetector(
                                  onTap: () => _selectProcess(e),
                                  child: Container(
                                    padding: EdgeInsets.all(30.sp),
                                    decoration: BoxDecoration(
                                        color:
                                        e.id == _itemCatSubProcessSelect.id ? const Color(0xff64CC8F) : Colors.white,
                                        borderRadius: BorderRadius.circular(16.sp),
                                        border: Border.all(
                                          color: const Color(0xff64CC8F),
                                          width: 2.sp,
                                        )),
                                    child: Text(
                                      e.name,
                                      style: TextStyle(
                                          color: e.id == _itemCatSubProcessSelect.id
                                              ? Colors.white
                                              : const Color(0xff64CC8F),
                                          fontSize: 45.sp),
                                    ),
                                  ),
                                ))
                                    .toList(),
                              ) : const SizedBox(),
                            ),
                          ),
                          Expanded(
                              child: BlocBuilder(
                            bloc: bloc,
                            buildWhen: (olds, news) => news is LoadListState || news is EmptySearchState,
                            builder: (context, state) {
                              return _list.isNotEmpty
                                  ? ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: _list.length,
                                      itemBuilder: (context, index) => TechnicalProcessItem(_list[index], index))
                                  : Container(
                                      padding: EdgeInsets.all(40.sp),
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Không tìm thấy bài viết về quy trình kỹ thuật nào liên quan',
                                        style: TextStyle(color: Colors.black, fontSize: 45.sp),
                                      ),
                                    );
                            },
                          )),
                        ],
                      ))),
          onWillPop: _surfBack,
        ),
    Banner2Nong('technical_process'),
    Loading(bloc)
  ], alignment: Alignment.bottomRight);

  Widget _item(TechProCatModel catSub, Function clickItem, {bool isSelect = false}) {
    String asset = 'assets/images/ic_default.png';
    final Widget error =
        Image.asset(asset, width: isSelect ? 200.sp : 150.sp, height: isSelect ? 200.sp : 150.sp, fit: BoxFit.fill);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 15.sp),
      // margin: EdgeInsets.only(left: 40.sp),
      child: GestureDetector(
        onTap: () => clickItem(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32.sp), boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))
              ]),
              child: ClipRRect(
                  child: FadeInImage.assetNetwork(
                      placeholder: asset,
                      width: isSelect ? 200.sp : 150.sp,
                      height: isSelect ? 200.sp : 150.sp,
                      fit: BoxFit.cover,
                      image: Util.getRealPath(catSub.image),
                      imageScale: 0.5,
                      imageErrorBuilder: (_, __, ___) => error),
                  borderRadius: BorderRadius.circular(5)),
            ),
            SizedBox(
              height: 20.sp,
            ),
            LabelCustom(
              catSub.name + '\n',
              color: isSelect ? const Color(0xff2EC67E) : Colors.black,
              align: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              line: 2,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _surfBack() async {
    if (_links.isNotEmpty) {
      final list = _links.values.toList();
      list.removeLast();
      if (list.isNotEmpty) _cat = list[list.length - 1].id;
      bloc!.add(LoadCatalogueEvent(idSub: _cat));
      return Future.value(false);
    }
    return Future.value(true);
  }

  // void _search() {
  //   _keySearch = _ctrSearch.text.trim();
  //   _indexSub = 0;
  //   bloc?.add(LoadCatalogueEvent(keyword: _keySearch));
  // }

  // void _clear() {
  //   if (_ctrSearch.text.trim().isEmpty) return;
  //   _ctrSearch.text = '';
  //   _reset();
  // }

  void _reset() {
    _index = 0;
    _indexSub = 0;
    _itemCatMainSelect = TechProCatModel();
    _itemCatMainSelect = TechProCatModel();
    _itemCatSubProcessSelect = TechProCatModel();
    _keySearch = '';
    _catSub.clear();
    _catMain.clear();
    _catMap.clear();
    _catSubProcess.clear();
    bloc?.add(LoadCatalogueEvent());
    _page = 1;
  }

  void _handleLoadList(TechnicalProcessesModel data) {
    _list.clear();
    if (data.list.isNotEmpty) {
      _list.addAll(data.list);
      data.list.length == 20 ? _page++ : _page = 0;
    } else
      _page = 0;
  }

  void _handleListCatMain(List list, {bool clearList = false}) {
    _catMain.clear();
    if (_keySearch.isNotEmpty) _catMain.add(TechProCatModel(name: 'tất cả', id: 'all'));
    list.map((element) {
      _catMain.add(TechProCatModel().fromJson(element));
    }).toList();
    _itemCatMainSelect = _catMain.isNotEmpty ? _catMain.first : TechProCatModel();
    _index = 0;
    bloc?.add(ChangeIndexEvent(_index));
  }

  void _handleListCatSub(List list, String idMain, {bool clearList = false, bool loadPrevious = false, int index = -1}) {
    if (clearList) _catSub.clear();
    List<TechProCatModel> listTemp = [];
    for (int i = 0; i <= list.length - 1; i++) {
      final item = TechProCatModel().fromJson(list[i]);
      listTemp.add(item);
      _setCatList(id: item.id, index: index != -1 ? index : _index);
    }
    if (loadPrevious) {
      _catSub.insertAll(0, listTemp);
      _indexSub = _indexSub + listTemp.length;
      _itemCatSubSelect = _catSub.isNotEmpty ? _catSub[_indexSub] : TechProCatModel();
    } else {
      _catSub.addAll(listTemp);
      _indexSub =_indexSub<_catSub.length? _indexSub: 0;
      _itemCatSubSelect = _catSub.isNotEmpty ? _catSub[_indexSub] : TechProCatModel();
    }
    scrollCatSubToSelected(_indexSub);

  }

  void _handleListCatSubProcess(List list, {bool clearList = false}) {
    _catSubProcess.clear();
    list.map((element) {
      _catSubProcess.add(TechProCatModel().fromJson(element));
    }).toList();
    _itemCatSubProcessSelect = _catSubProcess.isNotEmpty ? _catSubProcess.first : TechProCatModel(id: '-1');
  }
}
