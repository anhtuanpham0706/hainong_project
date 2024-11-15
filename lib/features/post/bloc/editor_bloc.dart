import 'package:hainong/common/base_bloc.dart';
import 'package:hainong/common/constants.dart';
import 'package:hainong/common/util/util.dart';
import '../post_list_repository.dart';
import '../model/meta_data_model.dart';
import 'package:html/dom.dart';
import 'package:url_launcher/url_launcher.dart';

class EditorState extends BaseState {
  EditorState({isShowLoading = false}) : super(isShowLoading: isShowLoading);
}

class ReloadEditorState extends EditorState {}

class LoadUrlEditorState extends EditorState {
  final List<MetaDataModel> list;

  LoadUrlEditorState(this.list);
}

class LoadVideoEditorState extends EditorState {}

class LoadSubVideoEditorState extends EditorState {
  final String url;
  LoadSubVideoEditorState(this.url);
}

class ReloadItemEditorState extends EditorState {}

class EditorEvent extends BaseEvent {}

class ReloadEditorEvent extends EditorEvent {}

class LoadUrlEditorEvent extends EditorEvent {
  final String text;

  LoadUrlEditorEvent(this.text);
}

class StopLoadingEditorEvent extends EditorEvent {}

class LoadVideoEditorEvent extends EditorEvent {}

class LoadSubVideoEditorEvent extends EditorEvent {
  final String url;
  LoadSubVideoEditorEvent(this.url);
}

class ReloadItemEditorEvent extends EditorEvent {}

class EditorBloc extends BaseBloc {
  EditorBloc(EditorState init) : super(init:init) {
    on<ReloadEditorEvent>((event, emit) => emit(ReloadEditorState()));
    on<ReloadItemEditorEvent>((event, emit) => emit(ReloadItemEditorState()));
    on<StopLoadingEditorEvent>((event, emit) => emit(EditorState()));
    on<LoadUrlEditorEvent>(_handleLoadUrl);
    on<LoadVideoEditorEvent>((event, emit) => emit(LoadVideoEditorState()));
    on<LoadSubVideoEditorEvent>((event, emit) => emit(LoadSubVideoEditorState(event.url)));
  }

  _handleLoadUrl(event, emit) async {
    final String tmp = event.text.toLowerCase();
    final List<MetaDataModel> list = [];
    final repository = PostListRepository();
    final RegExp exp = RegExp(Constants().patternLinkHtml);
    final Iterable<RegExpMatch> matches = exp.allMatches(tmp);
    String symbol;
    for (int i = 0; i < matches.length; i++) {
        String url = event.text.substring(matches.elementAt(i).start, matches.elementAt(i).end);
        if(url.contains('..') || double.tryParse(url) != null) continue;

        symbol = '';
        if (matches.elementAt(i).start > 0) symbol = tmp.substring(matches.elementAt(i).start - 1, matches.elementAt(i).start);
        if (symbol == '(') continue;
        if (!url.toLowerCase().contains('http')) url = 'https://$url';
        if (Util.isImage(url) || _isVideo(url) || _isAudio(url)) continue;
        if (_notExistUrl(list, url)) {
          final Document? doc = await repository.getWebsite(url);
          if (doc != null) {
            final MetaDataModel item = MetaDataModel(url: url);

            try {
              Element? title = doc.querySelector('title');
              if (title == null) {
                title = doc.querySelector("meta[property='og:title']");
                if (title != null) item.title = title.attributes['content']??'';
              } else {item.title = title.text;}
            } catch (_) {}

            try {
              item.domain = doc.querySelector("meta[property='og:url']")!
                  .attributes['content']!;
            } catch (_) {}

            try {
              if (item.domain.isEmpty) {
                Uri uri = Uri.parse(url);
                item.domain = url.substring(0, url.indexOf(uri.host)) + uri.host;
              }
            } catch (_) {}

            try {
              Element? description = doc.querySelector("meta[name='description']");
              description ??= doc.querySelector("meta[property='og:description']")!;
              item.description = description.attributes['content']!;
            } catch (_) {}

            try {
              Element? image = doc.querySelector("meta[property='og:image']");
              image ??= doc.querySelector("meta[content\$='.png']");
              item.image = image!.attributes['content']!;
            } catch (_) {}

            try {
              item.icon = doc
                  .querySelector("link[rel='shortcut icon']")!
                  .attributes['href']!;
            } catch (_) {}

            if (item.image.isNotEmpty && !item.image.contains('http')) {
              if (item.title.toLowerCase() == 'google')
                item.image = 'https://www.google.com' + item.image;
              else
                item.image = item.domain + '/' + item.image;
            }

            if (item.icon.isNotEmpty && !item.icon.contains('http'))
              item.icon = item.domain + '/' + item.icon;

            if (item.image.isEmpty && item.icon.isNotEmpty) item.image = item.icon;

            list.add(item);
          }
        }
    }

    if (list.isNotEmpty) emit(LoadUrlEditorState(list));
  }

  bool _notExistUrl(List<MetaDataModel> list, String url) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].url == url) return false;
    }
    return true;
  }

  bool _isVideo(String url) => url.contains('.mp4') ||
      url.contains('.ogv') ||
      url.contains('.webm') ||
      url.contains('.3gp') ||
      url.contains('.m3u8') ||
      url.contains('.avi') ||
      url.contains('.mov');

  bool _isAudio(String url) => url.contains('.mp3') ||
      url.contains('.ogg')||
      url.contains('.wma')||
      url.contains('.wav');
}
