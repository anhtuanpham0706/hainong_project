import 'import_lib_base_ui.dart';

class EmptySearch extends StatelessWidget {
  final String keyword, title;
  final double paddingTop;
  const EmptySearch(this.keyword, {this.title = 'Không tìm thấy' , this.paddingTop = 0, Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) => Column(children: [
    if (paddingTop > 0) SizedBox(height: paddingTop),
    Text(title, style: const TextStyle(fontSize: 22)),
    if (keyword.trim().isNotEmpty) Text(keyword, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
    const SizedBox(height: 10),
    Image.asset("assets/images/ic_search_not_found.png", fit: BoxFit.fill, color: const Color(0xFFCDCDCD), height: 80, width: 80)
  ], mainAxisAlignment: MainAxisAlignment.center);
}