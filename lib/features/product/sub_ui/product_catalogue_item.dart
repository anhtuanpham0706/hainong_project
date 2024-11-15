import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/models/catalogue_model.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import '../bloc/product_list_bloc.dart';

class ProductCatalogueItem extends StatefulWidget {
  final int index, first;
  final ProductListBloc bloc;
  final CatalogueModel item;
  final Map<String,ItemModel> selectCats;
  final Function funLoadSub, funSelectedSub, funUnselected;
  const ProductCatalogueItem(this.bloc, this.index, this.item, this.funLoadSub, this.funSelectedSub,
      this.funUnselected, this.selectCats, {this.first = 0, Key? key}):super(key:key);

  @override
  _CatalogueItemState createState() => _CatalogueItemState();
}

class _CatalogueItemState extends State<ProductCatalogueItem> {
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    ButtonImageWidget(0, _selectRow,
      Container(padding: EdgeInsets.fromLTRB(40.sp, 20.sp, 20.sp, 20.sp), width: 1.sw,
        child: Row(children: [
            Expanded(child:
            BlocBuilder(bloc: widget.bloc,
            buildWhen: (oldState, newState) => newState is SelectedCatalogueState,
            builder: (context, state) => Text(widget.item.name, style: TextStyle(color: widget.item.selected ? StyleCustom.textFollowColor : const Color(0xFF2C2C2C), fontSize: 48.sp)))),
            widget.index != widget.first ? ButtonImageWidget(50.sp, () => widget.funLoadSub(widget.item.id, widget.index), Container(padding: EdgeInsets.all(20.sp),
                child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(50.sp)),
                child: BlocBuilder(bloc: widget.bloc,
                buildWhen: (oldState, newState) => newState is ExpandedCatalogueState,
                builder: (context, state) => Icon(widget.item.expanded ? Icons.remove : Icons.add, size: 60.sp, color: Colors.black12))))) : SizedBox()
        ])
    )),
    Padding(padding: EdgeInsets.only(left: 40.sp, right: 40.sp),
        child: Divider(height: 1.sp)),
    BlocBuilder(bloc: widget.bloc,
        buildWhen: (oldState, newState) => newState is LoadSubCatalogueState ||
            newState is ExpandedCatalogueState || newState is SelectedCatalogueState,
        builder: (context, state) {
          if (!widget.item.expanded) return const SizedBox();
          if (widget.item.hasSub && widget.item.subList != null) {
            final List<Widget>list = [];
            for(int i = 0; i < widget.item.subList!.length; i++)
              list.add(SubCatalogueItem(widget.item.subList![i], () => _selected(i), _unselected,
                  widget.selectCats, paddingLeft: 40.sp));
            return Column(children: list);
          }
          return const SizedBox();
    })
  ]);

  void _selected(int index) {
    widget.funUnselected();
    if (widget.item.hasSub && widget.item.subList != null) {
      widget.item.subList![index].selected = true;
      widget.selectCats.putIfAbsent(widget.item.id.toString() + widget.item.name,
              ()=>ItemModel(id: widget.item.id.toString(), name: widget.item.name));
      widget.selectCats.putIfAbsent(widget.item.subList![index].id.toString() + widget.item.subList![index].name,
          ()=>ItemModel(id: widget.item.subList![index].id.toString(), name: widget.item.subList![index].name));
      widget.bloc.add(SelectedCatalogueEvent());
    }
  }

  void _unselected() {
    widget.funUnselected();
    widget.selectCats.putIfAbsent(widget.item.id.toString() + widget.item.name,
        ()=>ItemModel(id: widget.item.id.toString(), name: widget.item.name));
    widget.bloc.add(SelectedCatalogueEvent());
  }

  void _selectRow() {
    widget.funSelectedSub(widget.index);
    //if (widget.index != 0) widget.funLoadSub(widget.item.id, widget.index);
  }
}

class SubCatalogueItem extends StatefulWidget {
  final double paddingLeft;
  final CatalogueModel item;
  final Map<String,ItemModel> selectCats;
  final Function funSelectedParent, funUnselectedParent;
  const SubCatalogueItem(this.item, this.funSelectedParent, this.funUnselectedParent,
      this.selectCats, {this.paddingLeft = 0.0, Key? key}):super(key:key);
  @override
  _SubCatalogueItemState createState() => _SubCatalogueItemState();
}

class _SubCatalogueItemState extends State<SubCatalogueItem> {
  final ProductListBloc bloc = ProductListBloc(ProductListState());
  bool isFirst = true;

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    bloc.stream.listen((state) {
      if (state is LoadSubCatalogueState) _handleLoadSubCatalogue(state);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(color: const Color(0xFFF5F5F5), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    ButtonImageWidget(0, _selectRow,
      Container(padding: EdgeInsets.fromLTRB(40.sp + widget.paddingLeft, 20.sp, 20.sp, 20.sp), width: 1.sw,
        child: Row(children: [
          Expanded(child:
          BlocBuilder(bloc: bloc,
              buildWhen: (oldState, newState) => newState is SelectedCatalogueState,
              builder: (context, state) => Text(widget.item.name, style: TextStyle(color: widget.item.selected ? StyleCustom.textFollowColor : const Color(0xFF2C2C2C), fontSize: 42.sp)))),
          ButtonImageWidget(50.sp, () => _loadSubCatalogue(widget.item.id, 0), Container(padding: EdgeInsets.all(20.sp),
              child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(50.sp)),
              child: BlocBuilder(bloc: bloc,
                  buildWhen: (oldState, newState) => newState is ExpandedCatalogueState,
                  builder: (context, state) {
                    if (!widget.item.hasSub) return const SizedBox();
                    return Icon(widget.item.expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 60.sp, color: Colors.black12);
              }))))
        ])
    )),
    BlocBuilder(bloc: bloc,
        buildWhen: (oldState, newState) => newState is LoadSubCatalogueState ||
            newState is ExpandedCatalogueState || newState is SelectedCatalogueState,
        builder: (context, state) {
          if (!widget.item.expanded) return const SizedBox();
          if (widget.item.hasSub && widget.item.subList != null) {
            final List<Widget>list = [];
            for(int i = 0; i < widget.item.subList!.length; i++)
              list.add(SubCatalogueItem(widget.item.subList![i], () => _selected(i), _unselected,
                  widget.selectCats, paddingLeft: widget.paddingLeft + 40.sp));

            return Column(children: list);
          }
          return const SizedBox();
        })
  ]));

  void _loadSubCatalogue(int id, int index) {
    widget.item.expanded = !widget.item.expanded;
    bloc.add(ExpandedCatalogueEvent());
    bloc.add(LoadSubCatalogueEvent(id, index));
  }

  void _handleLoadSubCatalogue(LoadSubCatalogueState state) {
    if (state.list.isNotEmpty) {
      final cat = widget.item;
      if (cat.subList == null) cat.subList = state.list;
      else if (cat.subList!.isEmpty) cat.subList!.addAll(state.list);
      cat.hasSub = true;
    } else {
      bloc.add(ExpandedCatalogueEvent());
      widget.item.hasSub = false;
    }
  }

  void _selected(int index) {
    widget.funUnselectedParent();
    if (widget.item.hasSub && widget.item.subList != null) {
      widget.selectCats.putIfAbsent(widget.item.id.toString() + widget.item.name,
              ()=>ItemModel(id: widget.item.id.toString(), name: widget.item.name));
      widget.selectCats.putIfAbsent(widget.item.subList![index].id.toString() + widget.item.subList![index].name,
              ()=>ItemModel(id: widget.item.subList![index].id.toString(), name: widget.item.subList![index].name));
      widget.item.subList![index].selected = true;
      bloc.add(SelectedCatalogueEvent());
    }
  }

  void _unselected() {
    widget.funUnselectedParent();
    widget.selectCats.putIfAbsent(widget.item.id.toString() + widget.item.name,
            ()=>ItemModel(id: widget.item.id.toString(), name: widget.item.name));
    bloc.add(SelectedCatalogueEvent());
  }

  void _selectRow() {
    widget.funSelectedParent();
    //_loadSubCatalogue(widget.item.id, 0);
  }
}