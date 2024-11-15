import 'package:hainong/common/base_bloc.dart';

class CountDownState extends BaseState {
  final int value;
  const CountDownState({this.value = 0});
}

class CountDownEvent extends BaseEvent {
  final int value;
  CountDownEvent({this.value = 0});
}

class CountDownBloc extends BaseBloc {
  CountDownBloc({CountDownState init = const CountDownState(), bool hasAds = false, bool hasBanner = false}):super(init: init, hasAds: hasAds, hasBanner: hasBanner) {
    on<CountDownEvent>((event, emit) => emit(CountDownState(value: event.value)));
  }
}