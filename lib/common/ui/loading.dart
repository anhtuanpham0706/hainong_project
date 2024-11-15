import 'import_lib_base_ui.dart';
import '../style_custom.dart';
import '../base_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Loading extends StatelessWidget {
  final Color color, bgColor;
  final BaseBloc? bloc;
  const Loading(this.bloc, {this.color = StyleCustom.primaryColor, this.bgColor = Colors.black12, Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) => BlocBuilder<BaseBloc, BaseState>(bloc: bloc,
     builder: (context, state) => state.isShowLoading ? Container(alignment: Alignment.center, child:
        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(color))
        ,color: bgColor, width: 1.sw, height: 1.sh) : const SizedBox());
}