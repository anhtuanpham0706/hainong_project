import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangeHeaderState {
  final bool hasHeader, hideSearch, hideLogo;
  final String title;
  final Widget? icon, createUI;
  ChangeHeaderState({this.hasHeader = false, this.title = '', this.icon, this.createUI, this.hideSearch = false, this.hideLogo = false});
}

class ChangeHeaderEvent {
  final bool hasHeader, hideSearch, hideLogo;
  final String title;
  final Widget? icon, createUI;
  ChangeHeaderEvent({this.hasHeader = false, this.title = '', this.icon, this.createUI, this.hideSearch = false, this.hideLogo = false});
}

class ChangeHeaderBloc extends Bloc<ChangeHeaderEvent, ChangeHeaderState> {
  ChangeHeaderBloc(ChangeHeaderState init):super(init) {
    on<ChangeHeaderEvent>((event, emit) => emit(ChangeHeaderState(hasHeader: event.hasHeader, title: event.title, icon: event.icon, createUI: event.createUI, hideSearch: event.hideSearch, hideLogo: event.hideLogo)));
  }
}
