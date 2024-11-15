import 'package:flutter_bloc/flutter_bloc.dart';

class ScrollState {}

class CollapseHeaderScrollState extends ScrollState {
  final bool value;
  CollapseHeaderScrollState(this.value);
}

class CollapseFooterScrollState extends ScrollState {
  final bool value;
  CollapseFooterScrollState(this.value);
}

class HideClearScrollState extends ScrollState {
  final bool value;
  HideClearScrollState(this.value);
}

class ScrollEvent {}

class CollapseHeaderScrollEvent extends ScrollEvent {
  final bool value;
  CollapseHeaderScrollEvent(this.value);
}

class CollapseFooterScrollEvent extends ScrollEvent {
  final bool value;
  CollapseFooterScrollEvent(this.value);
}

class HideClearScrollEvent extends ScrollEvent {
  final bool value;
  HideClearScrollEvent(this.value);
}

class ScrollBloc extends Bloc<ScrollEvent, ScrollState> {
  ScrollBloc(ScrollState init):super(init) {
    on<CollapseHeaderScrollEvent>((event, emit) => emit(CollapseHeaderScrollState(event.value)));
    on<CollapseFooterScrollEvent>((event, emit) => emit(CollapseFooterScrollState(event.value)));
    on<HideClearScrollEvent>((event, emit) => emit(HideClearScrollState(event.value)));
  }
}
