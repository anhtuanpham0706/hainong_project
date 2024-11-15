import 'dart:async';
import 'package:hainong/common/ui/import_lib_base_ui.dart';

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  const MyTooltip(this.message, this.child, {Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(5)),
        textStyle: TextStyle(fontSize: 52.sp, color: Colors.white),
        padding: const EdgeInsets.all(10), key: key, message: message, child: GestureDetector(onTap: () => _onTap(key), child: child));
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
    Timer(const Duration(seconds: 3), () => tooltip?.deactivate());
  }
}