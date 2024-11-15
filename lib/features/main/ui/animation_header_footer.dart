import 'import_lib_ui_main_page.dart';

class AnimationHeaderFooter extends StatelessWidget {
  final ScrollBloc scrollBloc;
  final String type;
  final Widget firstChild, secondChild;

  const AnimationHeaderFooter(this.scrollBloc, this.type, this.firstChild,
      this.secondChild, {Key? key}):super(key:key);

  @override
  Widget build(context) => BlocBuilder(
      bloc: scrollBloc,
      buildWhen: (oldState, newState) {
        if (type == 'header') return newState is CollapseHeaderScrollState;
        if (type == 'footer') return newState is CollapseFooterScrollState;
        return false;
      },
      builder: (context, state) {
        bool value = false;
        if (type == 'header' && state is CollapseHeaderScrollState) value = state.value;
        else if (type == 'footer' && state is CollapseFooterScrollState) value = state.value;
        return AnimatedCrossFade(crossFadeState: value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: firstChild, secondChild: secondChild, duration: const Duration(milliseconds: 500));
      });
}
