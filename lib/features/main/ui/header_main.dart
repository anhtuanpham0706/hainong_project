import 'dart:io';
import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/util/util_ui.dart';
import 'package:hainong/features/cart/ui/cart_item.dart';
import 'package:hainong/features/main/ui/search_widget.dart';
import 'import_lib_ui_main_page.dart';

class HeaderMain extends StatelessWidget {
  final ScrollBloc scrollBloc;
  final ChangeHeaderBloc subBloc;
  final TextEditingController ctrSearch;
  final FocusNode focusSearch;
  final Function funSearch, funClearSearch;

  const HeaderMain(this.scrollBloc, this.subBloc, this.ctrSearch, this.focusSearch,
      this.funSearch, this.funClearSearch, {Key? key}):super(key:key);

  @override
  Widget build(context) => BlocBuilder<ChangeHeaderBloc, ChangeHeaderState>(bloc: subBloc,
      builder: (context, stateHeader) => stateHeader.hasHeader ? Container(color: StyleCustom.primaryColor,
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            SizedBox(height: (Platform.isAndroid ? 0.sp : -20.sp) + WidgetsBinding.instance.window.padding.top.sp),
            BlocBuilder(bloc: scrollBloc, buildWhen: (oldS, newS) => newS is CollapseHeaderScrollState,
                builder: (context, state) {
                  bool value = false;
                  if (state is CollapseHeaderScrollState) value = state.value;
                  final title = Container(
                      padding: EdgeInsets.only(left: 40.sp, bottom: stateHeader.hideSearch ? 10.sp : 0, top: 20.sp),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const HeaderBack(),
                        UtilUI.createLabel(stateHeader.title),
                        if (stateHeader.icon != null) Row(children: [
                          stateHeader.icon!,
                          if (stateHeader.hideSearch) SizedBox(width: 40.sp)
                        ])
                      ]));
                  final header = stateHeader.hideSearch ? title : Column(children: [
                    title,
                    HeaderSearch(ctrSearch, focusSearch, funSearch, funClearSearch, scrollBloc),
                    if (stateHeader.createUI != null) stateHeader.createUI!,
                  ], mainAxisSize: MainAxisSize.min);
                  return AnimatedCrossFade(crossFadeState: value ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      firstChild: SizedBox(width: 1.sw), secondChild: header, duration: const Duration(milliseconds: 500));
                }
            )
          ])) : const SizedBox());
}

class HeaderBack extends StatelessWidget {
  const HeaderBack({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => ButtonImageWidget(20, () => UtilUI.goBack(context, false),
      Row(children: [
        Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white),
        Image.asset('assets/images/ic_logo.png', width: 200.sp, fit: BoxFit.fill)
      ]));
}

class HeaderSearch extends StatelessWidget {
  final TextEditingController ctrSearch;
  final FocusNode focusSearch;
  final Function funSearch, funClearSearch;
  final ScrollBloc scrollBloc;
  const HeaderSearch(this.ctrSearch, this.focusSearch, this.funSearch,
      this.funClearSearch, this.scrollBloc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(padding: EdgeInsets.fromLTRB(40.sp, 20.sp, 40.sp, 40.sp),
      child: Stack(alignment: Alignment.centerLeft, children: [
        SizedBox(height: 0, width: 0, child: TextField(readOnly: true, focusNode: focusSearch)),
        SearchWidget(ctrSearch, focusSearch, funSearch),
        Row(children: [
          Container(padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
              child: ButtonImageCircleWidget(40.sp, funSearch,
                  child: Image.asset('assets/images/ic_search.png',
                      height: 50.sp, width: 50.sp))),
          Container(padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
              child: ButtonImageCircleWidget(40.sp, funClearSearch,
                  child: BlocBuilder(bloc: scrollBloc,
                      buildWhen: (oldState, newState) => newState is HideClearScrollState,
                      builder: (context, state) {
                        bool hide = true;
                        if (state is HideClearScrollState) hide = state.value;
                        return hide?const SizedBox():Icon(Icons.clear, size: 50.sp, color: Colors.white);
                      })))
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
      ]));
}

class HeaderAppBar extends AppBar {
  final TextEditingController ctrSearch;
  final FocusNode focusSearch;
  final Function funSearch, funClearSearch;
  final ScrollBloc scrollBloc;
  final Widget helper;

  HeaderAppBar(this.ctrSearch, this.focusSearch, this.funSearch,
    this.funClearSearch, this.scrollBloc, this.helper, {Key? key}) : super(
      key: key,
      elevation: 5, leadingWidth: 320.sp,
      leading: Padding(child: const HeaderBack(), padding: EdgeInsets.only(left: 40.sp)),
      actions: [
        Row(children: [
          helper, const CartNumber()
        ], crossAxisAlignment: CrossAxisAlignment.center)
      ],
      bottom: PreferredSize(preferredSize: Size(1.sw - 80.sp, 100.sp), child:
        HeaderSearch(ctrSearch, focusSearch, funSearch, funClearSearch, scrollBloc))
    );
}
