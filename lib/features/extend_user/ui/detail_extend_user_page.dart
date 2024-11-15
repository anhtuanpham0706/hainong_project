import 'dart:io';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../bloc/detail_extend_user_bloc.dart';
import '../extend_user_model.dart';
import 'package:number_paginator/number_paginator.dart';

class DetailExtendUserPage extends BasePage {
  final String nameParentApp;
  final int id;

  DetailExtendUserPage({Key? key, required this.nameParentApp, required this.id})
      : super(pageState: _DetailExtendUserPage(), key: key);
}

class _DetailExtendUserPage extends BasePageState {
  List<TagNameModel> tagNames = [];
  int indextagName = 0;
  String subTabName = '';
  List<Map<String, dynamic>> jsonData = [];
  final TextEditingController _controller = TextEditingController();
  final NumberPaginatorController _paginateController = NumberPaginatorController();
  final FocusNode _focusNode = FocusNode();
  Map<String, dynamic> _translateData = {};
  Map<String, dynamic> _dataPaginate = {};
  String key = '';
  String slug = '';
  String keySearch = '';
  int currentPage = 1;
  int pageLimit = 1;

  @override
  void initState() {
    initBloc();

    bloc!.add(LoadListJsonEvent((widget as DetailExtendUserPage).id, TypeFlowData.Floor1,
        key: (widget as DetailExtendUserPage).nameParentApp));
    super.initState();
  }

  @override
  void dispose() {
    _paginateController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    tagNames.clear();
    jsonData.clear();
    _translateData.clear();
    _dataPaginate.clear();
    super.dispose();
  }

  void initBloc() {
    bloc = DetailExtendUserBloc();
    bloc!.stream.listen((state) {
      if (state is LoadListJsonState && isResponseNotError(state.response)) {
        jsonData.clear();
        if (tagNames.length != 3) {
          _controller.clear();
        }
        int newIndex = 0;
        if (tagNames.isNotEmpty) {
          for (int i = 0; i < tagNames.length; i++) {
            if (tagNames[i].key_name == state.keyName) {
              newIndex = i;
              tagNames.removeRange(i, tagNames.length);
              break;
            }
            newIndex = i + 1;
          }
        } else {
          newIndex = 0;
        }
        indextagName = newIndex;
        tagNames.add(TagNameModel(indextagName, translateJson(state.keyName), state.keyName));

        if (tagNames.length == 1) {
          jsonData.add(state.response.data as Map<String, dynamic>);
          _translateData = state.response.translate;
        } else {
          if (tagNames.length == 3) {
            subTabName = tagNames[2].name;
            _dataPaginate = state.response.paginate;
            pageLimit = _dataPaginate['max_pages'];
            currentPage = _dataPaginate['current_page'];
          }
          List<dynamic> list = state.response.data;
          list.forEach((element) {
            jsonData.add(element as Map<String, dynamic>);
          });
          _translateData = state.response.translate;
        }
      }
    });
  }

  @override
  Widget createHeaderUI() {
    final logo = Image.asset('assets/images/ic_logo.png', height: 120.sp);
    return Padding(
        padding: EdgeInsets.only(top: 40.sp + WidgetsBinding.instance.window.padding.top.sp, left: 20.sp),
        child: Stack(children: [
          logo,
          Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                  onPressed: () => UtilUI.goBack(context, false),
                  icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white)))
        ], alignment: Alignment.center));
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    return Scaffold(

      resizeToAvoidBottomInset: true,
      body: GestureDetector(
          onVerticalDragDown: (details) {
            clearFocus();
          },
          onTapUp: (value) {
            clearFocus();
          },
          child: Container(
            color: StyleCustom.primaryColor,
            child: Stack(children: [
              Column(children: [
              SizedBox(
                  height:  Platform.isAndroid? 300.sp  : 330.sp,
                ),

                Expanded(child: Container(
                  height: MediaQuery.of(context).size.height*0.85,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(60.sp)), color: StyleCustom.backgroundColor),
                ),),
              ]),
              createUI(),
              Loading(bloc)
            ]),
          )),
    );
  }

  @override
  Widget createUI() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         createHeaderUI(),
        const Expanded(
          flex: 5,
          child: SizedBox(),
        ),
        BlocBuilder(
          bloc: bloc,
          buildWhen: (olds, news) => news is LoadListJsonState,
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.sp, right: 16.sp, bottom: 32.sp),
                    child: SingleChildScrollView(
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: tagNames.map((e) {
                          if (e.index == 0) {
                            return InkWell(
                              child: Text(
                                e.name.length > 25 ? e.name.substring(0, 25) + '...' : e.name,
                                style: TextStyle(
                                  color: StyleCustom.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48.sp,
                                ),
                              ),
                              onTap: () => loadListByTagName(e),
                            );
                          } else {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(' > '),
                                InkWell(
                                  child: Text(
                                    e.name.length > 25 ? e.name.substring(0, 25) + '...' : e.name,
                                    style: TextStyle(
                                      color: StyleCustom.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48.sp,
                                    ),
                                  ),
                                  onTap: () => loadListByTagName(e),
                                )
                              ],
                            );
                          }
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        BlocBuilder(
            bloc: bloc,
            buildWhen: (olds, news) => news is LoadListJsonState,
            builder: (context, state) {
              if (tagNames.length == 3) {
                return  Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                            height: 110.sp,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.sp),
                              border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.sp),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16.sp),
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'tra cứu theo mã, tên',
                              ),
                              controller: _controller,
                              focusNode: _focusNode,
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () => _searchText(),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 16.sp, horizontal: 32.sp),
                            margin: EdgeInsets.only(left: 10.sp),
                            decoration: BoxDecoration(
                              color: StyleCustom.primaryColor,
                              borderRadius: BorderRadius.circular(10.sp),
                            ),
                            child: Text(
                              'Tìm kiếm',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                height: 5.sp,
                                color: Colors.white,
                                fontSize: 36.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () => _refresh(),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 16.sp, horizontal: 32.sp),
                            margin: EdgeInsets.only(left: 10.sp),
                            decoration: BoxDecoration(
                              color: StyleCustom.buttonColor,
                              borderRadius: BorderRadius.circular(10.sp),
                            ),
                            child: Text(
                              'Làm mới',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                height: 5.sp,
                                color: Colors.white,
                                fontSize: 36.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),
        SizedBox(
          height: 16.sp,
        ),

        BlocBuilder(
          bloc: bloc,
          buildWhen: (olds, news) => news is LoadListJsonState,
          builder: (context, state) {
            return jsonData.isEmpty
                ? Expanded(
                    flex: 67,
                    child: Center(
                      child: Text(
                        "Không tìm thấy kết quả phù hợp, vui lòng thữ lại.",
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 5.sp,
                          color: Colors.black,
                          fontSize: 42.sp,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    flex: tagNames.length > 2 ? 62 : 77,
                    child: Padding(
                        padding: EdgeInsets.only(
                          left: 16.sp,
                          right: 16.sp,
                        ),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          physics: const ScrollPhysics(),
                          children: listJsonBody(),
                          shrinkWrap: true,
                        )),
                  );
          },
        ),
        BlocBuilder(
            bloc: bloc,
            buildWhen: (olds, news) => news is LoadListJsonState,
            builder: (context, state) {
              if (tagNames.length == 3) {
                if (pageLimit != 0) _paginateController.currentPage = currentPage - 1;
                return pageLimit == 0
                    ? const SizedBox()
                    :Align(
                  child: SizedBox(
                    width: customAlgorithm(pageLimit),
                    child: NumberPaginator(
                      controller: _paginateController,
                      numberPages: pageLimit,
                      onPageChange: (int index) {
                        if (index + 1 != currentPage) {
                          subTabName = tagNames[2].name;
                          bloc!.add(LoadListJsonEvent((widget as DetailExtendUserPage).id, TypeFlowData.Floor3,
                              keySearch: keySearch, key: key, slug: slug, page: index + 1));
                        }
                      },
                      config: const NumberPaginatorUIConfig(
                        buttonSelectedBackgroundColor: StyleCustom.primaryColor,
                        buttonUnselectedForegroundColor: StyleCustom.primaryColor,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                );
              }
              return const SizedBox();
            }),
      Expanded(
        child: SizedBox(
          height: 30.sp,
        ),
        flex: 3,
      )
        // createBodyUI(),
        // createFooterUI()
      ]);

  List<Widget> listJsonBody() {
    List<Widget> list = [];
    if (jsonData.isNotEmpty) {
      switch (tagNames.length) {
        case 1: // data floor 1
          list.addAll(jsonData[0].entries.map((e) {
            if (e.value is List<dynamic>) {
              return InkWell(
                onTap: () {
                  bloc!.add(LoadListJsonEvent(
                    (widget as DetailExtendUserPage).id,
                    TypeFlowData.Floor2,
                    key: e.key,
                  ));
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '- ' + translateJson(e.key),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 4.sp,
                          color: const Color(0xff0275D8),
                          fontSize: 42.sp,
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          translateJson(e.key) + ': ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 5.sp,
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 42.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(e.value,
                            textAlign: TextAlign.start,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 5.sp,
                              color: Colors.black,
                              fontSize: 42.sp,
                            )),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                    endIndent: 30.sp,
                    thickness: 1.sp,
                  )
                ],
              );
            }
          }).toList());
          break;
        case 2: // data floor 2
          list.addAll(jsonData[0].entries.map((e) {
            if (e.value is List<dynamic>) {
              if(e.key == 'dia-chi' ){
                  List<Widget> data =[ Text(
                    translateJson(e.key) + ': ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 5.sp,
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 42.sp,
                    ),
                  ),];
                  Map<String,dynamic> a = e.value[0];
                  a.forEach((key, value) {
                    data.add(
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            translateJson(key) + ': ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 5.sp,
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 42.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(value,
                              textAlign: TextAlign.start,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                height: 5.sp,
                                color: Colors.black,
                                fontSize: 42.sp,
                              )),
                        ),
                      ],
                    ));
                  });
                  data.add( Divider(
                    color: Colors.black,
                    endIndent: 30.sp,
                    thickness: 1.sp,
                  ));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data,
                );

              }
              return InkWell(
                onTap: () {
                  key = tagNames[tagNames.length - 1].key_name;
                  slug = e.key;
                  bloc!.add(LoadListJsonEvent((widget as DetailExtendUserPage).id, TypeFlowData.Floor3, key: key, slug: slug));
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '- ' + translateJson(e.key),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 4.sp,
                          color: const Color(0xff0275D8),
                          fontSize: 42.sp,
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          translateJson(e.key) + ': ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 5.sp,
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 42.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(e.value,
                            textAlign: TextAlign.start,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 5.sp,
                              color: Colors.black,
                              fontSize: 42.sp,
                            )),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                    endIndent: 30.sp,
                    thickness: 1.sp,
                  )
                ],
              );
            }
          }).toList());
          break;
        case 3: // data floor 3
          jsonData.forEach((element) {
            list.addAll(element.entries.map((e) {
              if (e.value is List<dynamic>) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        translateJson(e.key) + ': ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 5.sp,
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 48.sp,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        translateJson(e.key) + ': ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 5.sp,
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 48.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(e.value,
                          textAlign: TextAlign.start,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 5.sp,
                            color: Colors.black,
                            fontSize: 48.sp,
                          )),
                    ),
                  ],
                );
              }
            }).toList());
            list.add(jsonData.last != element
                ? Divider(
                    color: Colors.black,
                    endIndent: 30.sp,
                    thickness: 1.sp,
                  )
                : SizedBox(
                    height: 50.sp,
                  ));
          });
      }
    }
    return list.isNotEmpty ? list : [const SizedBox()];
  }

  double customAlgorithm(int input) {
    if (input == 1) {
      return 0.5.sw;
    } else if (input == 2) {
      return 0.5.sw;
    } else if (input == 3) {
      return 0.75.sw;
    } else {
      return 1.0.sw;
    }
  }
  String translateJson(String key) {
    if (_translateData.containsKey(key)) {
      return _translateData[key];
    } else {
      if (subTabName.isNotEmpty) {
        String temp = subTabName;
        subTabName = '';
        return temp;
      }
      return key;
    }
  }
  

  void _searchText() {
    currentPage = 1;
    pageLimit = 1;
    subTabName = tagNames[2].name;
    keySearch = _controller.text;
    bloc!.add(LoadListJsonEvent((widget as DetailExtendUserPage).id, TypeFlowData.Floor3,
        key: key, slug: slug, keySearch: keySearch));
  }

  void _refresh() {
    currentPage = 1;
    pageLimit = 1;
    keySearch = '';
    _controller.clear();
    subTabName = tagNames[2].name;
    bloc!.add(LoadListJsonEvent(
      (widget as DetailExtendUserPage).id,
      TypeFlowData.Floor3,
      key: key,
      slug: slug,
      page: currentPage,
    ));
  }

  void goParentPage() {
    UtilUI.goBack(context, false);
  }

  void loadListByTagName(TagNameModel model) {
    subTabName = model.name;
    if (model.index != indextagName) {
      if (model.index == 0) {
        bloc!.add(LoadListJsonEvent((widget as DetailExtendUserPage).id, TypeFlowData.Floor1, key: model.key_name));
      } else if (model.index == 1) {
        bloc!.add(LoadListJsonEvent((widget as DetailExtendUserPage).id, TypeFlowData.Floor2, key: model.key_name));
      }
    }
  }
}

class TagNameModel {
  int index;
  String name;
  String key_name;

  TagNameModel(this.index, this.name, this.key_name);
}
