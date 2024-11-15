import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/task_bar_widget.dart';
import 'package:hainong/features/login/login_page.dart';
import 'rating_bloc.dart';

class CreateRatingPage extends StatefulWidget {
  final int point, id, commentId;
  final String type;
  const CreateRatingPage(this.point, this.type, this.id, this.commentId, {Key? key}):super(key:key);
  @override
  _CreateRatingPageState createState() => _CreateRatingPageState();
}

class _CreateRatingPageState extends State<CreateRatingPage> {
  final RatingBloc _bloc = RatingBloc(RatingState());
  final TextEditingController ctrComment = TextEditingController();
  int point = 0;
  bool _isLock = false;

  @override
  void dispose() {
    _bloc.close();
    ctrComment.dispose();
    super.dispose();
  }

  @override
  void initState() {
    point = widget.point;
    _bloc.stream.listen((state) {
      if (state is ChangePointState) { point = state.point;
      } else if (state is PostRatingState) {
        _isLock = false;
        if (state.response.checkTimeout()) {
          UtilUI.showCustomDialog(context, MultiLanguage.get(LanguageKey().msgAnotherLogin)).then((value) => _return());
        } else if (state.response.checkOK()) { Navigator.of(context).pop(state.response.data);
        } else { UtilUI.showCustomDialog(context, state.response.data.toString());}
      }
    });
    super.initState();
  }

  _return() {
    while(Navigator.of(context).canPop()) Navigator.of(context).pop(true);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    final LanguageKey languageKey = LanguageKey();
    return Scaffold(
        appBar: TaskBarWidget('ttl_your_rating', lblButton: languageKey.btnPost, onPressed: _postRating).createUI(),
        body: Padding(
            padding: EdgeInsets.all(40.sp),
            child: Column(children: [
              SizedBox(height: 120.sp),
              BlocBuilder<RatingBloc, RatingState>(
                  bloc: _bloc,
                  buildWhen: (state1, state2) => state2 is ChangePointState,
                  builder: (context, state) =>
                      UtilUI.createStars(
                          rate: point,
                          size: 80.sp,
                          color: StyleCustom.buttonColor,
                          onClick: (index) => _clickStart(context, index),
                          hasFunction: true)),
              SizedBox(height: 10.sp),
              BlocBuilder<RatingBloc, RatingState>(
                  bloc: _bloc,
                  buildWhen: (state1, state2) => state2 is ChangePointState,
                  builder: (context, state) =>
                      UtilUI.createLabel(
                          MultiLanguage.get(_messagePoint()),
                          color: Colors.black)),
              SizedBox(height: 100.sp),
              TextField(
                controller: ctrComment,
                style: TextStyle(fontSize: 40.sp),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 10,
                decoration:
                InputDecoration(hintText: MultiLanguage.get('lbl_write_rating')),
              )
            ])));
  }

  String _messagePoint() {
    switch (point) {
      case 1:
        return 'lbl_very_bad';
      case 2:
        return 'lbl_bad';
      case 3:
        return 'lbl_good';
      case 4:
        return 'lbl_very_good';
      default:
        return 'lbl_excellent';
    }
  }

  _clickStart(BuildContext context, int index) => _bloc.add(ChangePointEvent(index));

  _postRating() {
    if (_isLock) return;
    _isLock = true;
    _bloc.add(PostRatingEvent(point, ctrComment.text, widget.type, widget.id, widget.commentId));
  }
}
