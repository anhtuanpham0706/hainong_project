import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hainong/common/count_down_bloc.dart';
import 'package:hainong/features/function/support/pests_handbook/ui/pests_handbook_list_page.dart';
import 'package:hainong/features/post/ui/list_post_hash_tag_page.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import '../constants.dart';
import '../util/util_ui.dart';

class StringHtml extends StatefulWidget {
  final String htmlString, shortHtml;
  final bool allowGotoShop;
  final bool isProduct, clearPage;
  StringHtml(this.htmlString, {this.shortHtml = '', Key? key, this.allowGotoShop = true,this.isProduct = false,this.clearPage = true}) : super(key: key);
  @override
  _StringHtmlState createState() => _StringHtmlState();
}

class _StringHtmlState extends State<StringHtml> {
  final CountDownBloc bloc = CountDownBloc();
  String content = '';

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _formatContent(widget.shortHtml.isEmpty ? widget.htmlString : widget.shortHtml);
  }

  @override
  Widget build(context) => BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is CountDownState,
    builder: (context, state) => Html(data: content,
        style: {
          "html,body,p": Style(padding: EdgeInsets.zero, margin: EdgeInsets.zero),
          "p": Style(fontSize: FontSize(42.sp))
        },
        onLinkTap: (url, render, map, ele) => _launchUrl(url!, context),
        onImageTap: (url, render, map, ele) => _launchUrl(url!, context))
  );

  _launchUrl(String url, BuildContext context) async {
    if(widget.isProduct){
      launch(url, enableJavaScript: true);
    } else {
      if (url.contains('#')) {
        if (widget.clearPage) UtilUI.clearAllPages(context);
        UtilUI.goToNextPage(context, ListPostHashtagPage(
            url.replaceFirst('https://', ''), allowGotoShop: widget.allowGotoShop, clearPage: widget.clearPage));
      } else if (url.contains('https://more')) {
        _formatContent(widget.htmlString);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final list = prefs.getStringList('pests')??[];
        if (list.contains(url.toLowerCase())) UtilUI.goToNextPage(context, PestsHandbookListPage(url));
        //else launchUrl(Uri.parse(url), mode: LaunchMode.externalNonBrowserApplication);
        else launch(url, enableJavaScript: true);
      }
    }
  }

  String _formatHashtags(String str) {
    String root = str;
    if (root.contains('#')) {
      final list = RegExp(r'#\S*').allMatches(root);
      for (int i = list.length - 1; i > -1; i--) {
        final String temp = root.substring(list
            .elementAt(i)
            .start, list
            .elementAt(i)
            .end);
        str = str.replaceRange(list
            .elementAt(i)
            .start, list
            .elementAt(i)
            .end, "<a href='https://$temp'>$temp</a>");
      }
    }
    return str;
  }

  void _formatContent(String raw) {
    content = _stringToLinkHtml(raw.trim());
    content = _formatHashtags(content);
    content = content.replaceAll(RegExp(r'\n'), '<br/>');
    content = '<p>$content</p>';
    bloc.add(CountDownEvent());
  }

  String _stringToLinkHtml(String str) {
    String result = str;
    if (str.length > 2) {
      String tmp = str;
      RegExp exp = RegExp(Constants().patternLinkHtml);
      Iterable<RegExpMatch> matches = exp.allMatches(str.toLowerCase());
      for(int i = matches.length - 1; i > -1; i--) {
        final match = matches.elementAt(i);
        String url = tmp.substring(match.start, match.end);
        if (url.contains('..') || double.tryParse(url) != null)
          '';
        else {
          String symbol = '';
          if (match.start > 0) symbol = tmp.substring(match.start - 1, match.start);
          if (!symbol.contains('#') && !symbol.contains('(') && url.length > 3) {
            //String http = url;
            //if (!url.toLowerCase().contains('http')) http = 'https://$url';
            //result = result.replaceRange(match.start, match.end, "<a href='$http'>$url</a>");
            result = result.replaceRange(match.start, match.end, '');
          }
        }
      }
    }
    return result;
  }
}
