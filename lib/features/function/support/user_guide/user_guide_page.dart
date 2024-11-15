import 'package:flutter_html/flutter_html.dart';
import 'package:hainong/common/api_client.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/features/function/ui/wed_2nong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/ui/loading.dart';
import '../handbook/handbook_bloc.dart';

class UserGuidePage extends StatefulWidget {
  const UserGuidePage({Key? key}) : super(key: key);
  @override
  _UserGuidePageState createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage> {
  final List<TermPolicyModel> _list = [TermPolicyModel()];
  int _currentExpand = -1;
  final _bloc = UserGuideBloc();

  @override
  void dispose() {
    _list.clear();
    _bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc.stream.listen((state) {
      if (state is LoadListState && state.response.checkOK() &&
          state.response.data.list.length > 0) _list.addAll(state.response.data.list);
    });
    _bloc.add(LoadListEvent(1, ''));
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(elevation: 0, titleSpacing: 0, centerTitle: true,
      title: UtilUI.createLabel('Hướng dẫn')),
        body: BlocBuilder<UserGuideBloc, BaseState>(bloc: _bloc,
          buildWhen: (oldState, newState) => newState is LoadListState || newState is ChangeExpandState,
          builder: (context, state) {
            if (state is LoadListState || state is ChangeExpandState) {
              return ListView.builder(padding: EdgeInsets.only(top: 30.sp),
                  itemCount: _list.length, itemBuilder: (context, index) {
                    if (index > 0) return _Item(_list[index], index, index == _currentExpand, _changeExpand);
                    return ButtonImageWidget(0, () => UtilUI.goToNextPage(context, const Web2Nong('https://help.hainong.vn')),
                        Padding(padding: EdgeInsets.all(30.sp), child: Text(MultiLanguage.get('lbl_entertain'), style: TextStyle(fontSize: 50.sp, color: Colors.blue))));
                  });
            }
            return Loading(_bloc);
          }));

  void _changeExpand(int index, bool expand) {
    if (expand) {_currentExpand = -1;
    } else {_currentExpand = index;}
    _bloc.add(ChangeExpandEvent());
  }
}

class _Item extends StatelessWidget {
  final TermPolicyModel item;
  final int pos;
  final bool expand;
  final Function changeExpand;
  const _Item(this.item, this.pos, this.expand, this.changeExpand);

  @override
  Widget build(BuildContext context) => Column(children: [
      ButtonImageWidget(0, () => changeExpand(pos, expand), Padding(padding: EdgeInsets.all(30.sp), child: Row(children: [
        Expanded(child: Text(item.title, style: TextStyle(fontSize: 50.sp, color: Colors.blue))),
        Icon(expand ? Icons.keyboard_arrow_up_sharp : Icons.keyboard_arrow_down_sharp,
            size: 60.sp, color: Colors.blue)
      ]))),
    expand ? Html(data: item.content, style: {"body": Style(fontSize: FontSize(46.sp), margin: EdgeInsets.only(left:30.sp, right: 30.sp))},
        //onLinkTap: (url, render, map, ele) => launchUrl(Uri.parse(url!)),
        onLinkTap: (url, render, map, ele) => launch(url!),
        //onImageTap: (url, render, map, ele) => launchUrl(Uri.parse(url!))) : SizedBox()
        onImageTap: (url, render, map, ele) => launch(url!)) : const SizedBox()
  ]);

  // void _launchUrl(String url) => launch(url, enableJavaScript: true);
}

class TermsPoliciesModel {
  final List<TermPolicyModel> list = [];
  TermsPoliciesModel fromJson(json) {
    if (json.isNotEmpty) json.forEach((ele) => list.add(TermPolicyModel().fromJson(ele)));
    return this;
  }
}

class TermPolicyModel {
  late String title, content;
  TermPolicyModel fromJson(Map<String, dynamic> json) {
    title = Util.getValueFromJson(json, 'title', '');
    content = Util.getValueFromJson(json, 'content', '');
    return this;
  }
}

class UserGuideBloc extends BaseBloc {
  UserGuideBloc({BaseState init = const BaseState()}):super(init: init){
    on<LoadListEvent> ((event, emit) async {
      emit(const BaseState(isShowLoading: true));
      final response = await ApiClient().getAPI('${Constants().apiVersion}page', TermsPoliciesModel(), hasHeader: false);
      emit(LoadListState(response));
    });
    on<ChangeExpandEvent>((event, emit) => emit(ChangeExpandState()));
  }
}
