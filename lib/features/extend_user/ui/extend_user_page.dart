import 'dart:io';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import '../bloc/extend_user_bloc.dart';
import 'detail_extend_user_page.dart';
import '../extend_user_model.dart';

class ExtendUserPage extends BasePage {
  ExtendUserPage({Key? key}) : super(key: key, pageState: _ExtendUserPage());
}

class _ExtendUserPage extends BasePageState {
  List<AppExtendUserModel> listAppThirdParty = [];

  @override
  void initState() {
    bloc = ExtendUserBloc();
    initData();
    super.initState();
  }

  void initData() {
    bloc!.add(LoadListAppEvent());
    bloc!.stream.listen((state) {
      if (state is LoadListAppState && isResponseNotError(state.baseResponse)) {
        ListAppExtendUserModel data = ListAppExtendUserModel().fromJson(state.baseResponse.data);
        listAppThirdParty.addAll(data.list);
      }
    });
  }

  @override
  Widget createHeaderUI() {
    //final header = (widget as ShopPage).hasHeader;
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
                const Expanded(
                  flex: 15,
                  child: SizedBox(),
                ),
                Expanded(
                  flex: 85,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(60.sp)), color: StyleCustom.backgroundColor),
                  ),
                ),
              ]),
              createUI(),
              Loading(bloc)
            ]),
          )),
    );
  }

  @override
  Widget createUI() => Column(children: [
        createHeaderUI(),
        const Expanded(child: SizedBox(), flex: 8),
        Expanded(
          child: bodyUI(),
          flex: 92,
        ),
        // createBodyUI(),
        // createFooterUI()
      ]);

  Widget bodyUI() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: Text(
              MultiLanguage.get('btn_extend_user'),
              style: TextStyle(
                color: StyleCustom.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 48.sp,
              ),
            ),
          ),
          SizedBox(
            height: 32.sp,
          ),
          titleTable(),
          Expanded(
            child: SingleChildScrollView(
                child: BlocBuilder(
              bloc: bloc,
              buildWhen: (olds, news) => news is LoadListAppState,
              builder: (context, state) {
                return ListView.builder(
                  padding: EdgeInsets.only(top: 15.sp),
                  controller: ScrollController(),
                  itemCount: listAppThirdParty.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return itemList(listAppThirdParty[index]);
                  },
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget itemList(AppExtendUserModel model) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.sp),
      margin: EdgeInsets.only(bottom: 16.sp),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 2.0.sp),
          right: BorderSide(color: Colors.grey, width: 2.0.sp),
          left: BorderSide(color: Colors.grey, width: 2.0.sp),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '  ' + model.name,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 48.sp,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 32.sp),
            height: 90.sp,
            width: 2.sp,
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              Util.strDateToString(model.dateUpdate, pattern: 'dd/MM/yyyy'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
                fontSize: 42.sp,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 32.sp),
            height: 90.sp,
            width: 2.sp,
            color: Colors.white,
          ),
          Expanded(
              child: GestureDetector(
            onTap: () {
              selectItem(model.id, model.name);
            },
            child: Text(
              'Xem chi tiết',
              style: TextStyle(
                color: StyleCustom.primaryColor,
                fontSize: 42.sp,
                decoration: TextDecoration.underline,
              ),
            ),
          ))
        ],
      ),
    );
  }

  void selectItem(int id, String name) {
    UtilUI.goToNextPage(
      context,
      DetailExtendUserPage(
        nameParentApp: name,
        id: id,
      ),
    );
  }

  Widget titleTable() {
    return Container(
      color: StyleCustom.primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 34.sp, vertical: 16.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Tên ứng\ndụng',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 42.sp,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 32.sp),
            height: 90.sp,
            width: 2.sp,
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              'Ngày cập \nnhập',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 42.sp,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 32.sp),
            height: 90.sp,
            width: 2.sp,
            color: Colors.white,
          ),
          const Expanded(child: SizedBox())
        ],
      ),
    );
  }
}
