import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import 'package:hainong/common/style_custom.dart';
import '../multi_language.dart';

class LoadingPercent extends StatefulWidget {
  final int total;
  const LoadingPercent(this.total, {Key? key}):super(key:key);
  @override
  _LoadingPercentState createState() => _LoadingPercentState();
}
class _LoadingPercentState extends State<LoadingPercent> {
  final bloc = _PercentBloc();
  int start = 0;

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    bloc.add(_PercentEvent(start, widget.total));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<_PercentBloc, _PercentState>(
      bloc: bloc,
      builder: (context, state) => Scaffold(backgroundColor: Colors.black26,
          body: Container(alignment: Alignment.center, child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(StyleCustom.primaryColor)),
            SizedBox(height: 28.sp),
            Text(MultiLanguage.get('lbl_processing')+' ${state.percent.round()}% ...',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 48.sp))
          ]))),
      listener: (context, state) {
        Timer(const Duration(seconds: 1), () {
          start ++;
          if (start < widget.total + 1 && !bloc.isClosed) bloc.add(_PercentEvent(start, widget.total));
        });
      });
}

class _PercentState {
  final double percent;
  const _PercentState(this.percent);
}

class _PercentEvent {
  final int start, total;
  _PercentEvent(this.start, this.total);
}

class _PercentBloc extends Bloc<_PercentEvent, _PercentState> {
  _PercentBloc({_PercentState initialState = const _PercentState(0)}) : super(initialState){
    on<_PercentEvent>((event, emit) {
      if (event.start == 0) emit(_PercentState(0));
      else if (event.start == event.total) emit(_PercentState(99));
      else emit(_PercentState(event.start * 100 / event.total));
    });
  }
}