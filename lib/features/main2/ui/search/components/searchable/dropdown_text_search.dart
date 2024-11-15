import 'package:flutter/services.dart';
import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/features/main2/ui/search/models/home_item_search_model.dart';
import 'package:hainong/features/main2/ui/search/models/home_search_model.dart';

class DropdownTextSearch extends StatefulWidget {
  final TextEditingController? controller;
  final InputDecoration? decorator;
  final String? noItemFoundText;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? tileColor;
  final FocusScopeNode? node;
  final Function(String val) onChange;
  final Function(String? type, String? id)? onCallBackPage;
  final List<HomeSearchModel>? items;
  final int? maxLine;
  final TextInputAction inputAction;
  final dynamic border;
  final paddingIcon;
  final double? size, height, iconSize;
  final double? sizeBorder;
  final Color textColor, color;
  final Color? borderColor;
  final FocusNode? focus, nextFocus;
  final String hintText;
  final Function? onPressIcon, onSubmit, onChanged;
  final bool? isLoading;

  const DropdownTextSearch(
      {Key? key,
      required this.onChange,
      required this.items,
      this.onCallBackPage,
      this.maxLine = 1,
      this.controller,
      this.decorator,
      this.node,
      this.hoverColor,
      this.highlightColor,
      this.tileColor,
      this.noItemFoundText,
      this.inputAction = TextInputAction.next,
      this.border,
      this.paddingIcon,
      this.size,
      this.height,
      this.iconSize,
      this.sizeBorder,
      required this.textColor,
      required this.color,
      this.borderColor,
      this.focus,
      this.nextFocus,
      required this.hintText,
      this.onPressIcon,
      this.onSubmit,
      this.onChanged,
      this.isLoading = false})
      : super(key: key);

  @override
  _DropdownTextSearch createState() => _DropdownTextSearch();
}

class _DropdownTextSearch extends State<DropdownTextSearch> {
  //============== VARIANT ==============
  late final ScrollController scrollController;
  late final FocusNode focusNode = FocusNode();
  final layerLink = LayerLink();
  OverlayEntry? entry;
  int _selectedItem = 0;
  String searchText = "", emptyText = '';
  String? errorText;
  double heightSearchDropdown = 0.65.sh;
  //============== OVERRIDE ==============
  @override
  void initState() {
    scrollController = ScrollController();
    focusNode.addListener(() {
      if (focusNode.hasFocus && (widget.controller?.text.length ?? 0) >= 4) {
        if (widget.isLoading == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSearchDropDown();
          });
        }
      } else {
        hideSearchDropDown();
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(DropdownTextSearch oldWidget) {
    if (oldWidget.items != widget.items) {
      if (widget.isLoading == false) {
        focusNode.requestFocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSearchDropDown();
        });
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    scrollController.dispose();
    focusNode.dispose();
    entry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = getInputDecoration();
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (RawKeyEvent key) => handleOnKeyListener(key),
      child: CompositedTransformTarget(
        link: layerLink,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: widget.height ?? 132.sp,
                child: TextFormField(
                  decoration: decoration,
                  controller: widget.controller,
                  maxLines: widget.maxLine == 0 ? null : widget.maxLine,
                  textInputAction: widget.inputAction,
                  autofocus: false,
                  onFieldSubmitted: (bg) {
                    handleSearchButton();
                  },
                  onEditingComplete: widget.node?.nextFocus,
                  cursorColor: Colors.black,
                  style: TextStyle(color: widget.textColor, fontSize: widget.size ?? 40.sp),
                  onChanged: (val) {
                    widget.onChange(val);
                    setState(() {
                      errorText = null;
                      searchText = val;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: widget.height ?? 132.sp,
              child: ButtonImageWidget(200, () {
                handleSearchButton();
              },
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 36.sp),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFD15B),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(200), bottomRight: Radius.circular(200))),
                      child: Icon(Icons.search, color: const Color(0x99303030), size: 75.sp))),
            )
          ],
        ),
      ),
    );
  }

  //============== WIDGET ==============
  void showSearchDropDown() {
    hideSearchDropDown();
    final overlay = Overlay.of(context)!;
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    double maxHeight = 1.sh;
    double positionHeight = size.height;
    entry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
          width: size.width,
          child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height),
              child: buildOverlay())),
    );
    overlay.insert(entry!);
  }

  void hideSearchDropDown() {
    entry?.remove();
    entry = null;
  }

  Widget buildOverlay() {
    return Material(child: Stack(children: [searchCategoryWidget(widget.items)]));
  }

  Widget searchCategoryWidget(List<HomeSearchModel>? data) {
    return widget.isLoading == true
        ? searchCategoryLoadingWidget()
        : data?.isNotEmpty == true
            ? searchCategoryDataWidget(data)
            : searchCategoryEmptyWidget();
  }

  Widget searchCategoryLoadingWidget() {
    return SizedBox(
      height: heightSearchDropdown,
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(StyleCustom.primaryColor)),
        ),
      ),
    );
  }

  Widget searchCategoryDataWidget(List<HomeSearchModel>? data) {
    return Container(
      constraints: BoxConstraints(maxHeight: heightSearchDropdown),
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          controller: scrollController,
          padding: EdgeInsets.zero,
          itemCount: data?.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(data?[index].wrap_title ?? "",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
                searchCatagoryItemWidget(data?[index].data)
              ]),
            );
          }),
    );
  }

  Widget searchCatagoryItemWidget(List<HomeItemSearchModel>? data) {
    return data?.isNotEmpty == true
        ? ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data?.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  InkWell(
                    onTap: (() {
                      if (widget.onCallBackPage != null) {
                        focusNode.requestFocus();
                        widget.onCallBackPage!(
                            data?[index].object_type.toString(), data?[index].id.toString());
                      }
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          if (data?[index].search_image?.isNotEmpty == true) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ClipOval(
                                child: Image.network(
                                  data![index].search_image!,
                                  width: 0.15.sw,
                                  height: 0.15.sw,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((data![index].short_search_homepage_title ?? ""),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(fontSize: 22)),
                                if (getAddress(data[index])?.isNotEmpty == true) ...[
                                  Text(getAddress(data[index])!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 18)),
                                  SizedBox(height: 4.h)
                                ],
                                if (data[index].retail_price != 0) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          Util.doubleToString(data[index].retail_price ?? 0,
                                                  locale: Constants().localeVILang) +
                                              "đ",
                                          maxLines: 2,
                                          style: const TextStyle(fontSize: 18, color: Colors.red)),
                                      SizedBox(
                                        width: 20.w,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              );
            })
        : Container();
  }

  String? getAddress(HomeItemSearchModel? item) {
    List<String> parts = [];
    if (item?.district_name?.isNotEmpty == true) {
      parts.add(item?.district_name ?? "");
    }
    if (item?.province_name?.isNotEmpty == true) {
      parts.add(item?.province_name ?? "");
    }
    return parts.join(", ");
  }

  Widget searchCategoryEmptyWidget() {
    return Container(
      constraints: BoxConstraints(maxHeight: heightSearchDropdown),
      decoration: const BoxDecoration(color: Colors.white),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        children: [
          Text(MultiLanguage.get("msg_not_found"), style: const TextStyle(fontSize: 22)),
          Text(emptyText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(
            height: 20,
          ),
          Container(
              child: Image.asset("assets/images/ic_search_not_found.png",
                  fit: BoxFit.fitWidth, width: 120, height: 120, color: const Color(0xFFEDEDED)),
              decoration: const BoxDecoration(color: Colors.white)),
        ],
      ),
    );
  }

  void scrollFun() {
    double perBlockHeight =
        scrollController.position.maxScrollExtent / ((widget.items?.length ?? 1) - 1);
    double _position = _selectedItem * perBlockHeight;
    scrollController.jumpTo(
      _position,
    );
  }

  Widget iconClearWidget() {
    return widget.isLoading == false
        ? (widget.controller!.text.isNotEmpty)
            ? const Icon(Icons.clear, color: Color(0xFFCDCDCD))
            : const SizedBox()
        : const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(StyleCustom.primaryColor));
  }

  //============== STYLE ==============
  InputDecoration? getInputDecoration() {
    final fcBorder = widget.border ??
        _getBorder(widget.sizeBorder ?? 0, widget.borderColor ?? StyleCustom.borderTextColor);
    final enBorder = widget.border ??
        _getBorder(widget.sizeBorder ?? 0, widget.borderColor ?? StyleCustom.primaryColor);
    final errBorder =
        widget.border ?? _getBorder(widget.sizeBorder ?? 0, widget.borderColor ?? Colors.red);
    return InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(200),
        ),
        contentPadding: EdgeInsets.only(top: 36.sp, left: 36.sp),
        suffixIcon: IconButton(
            onPressed: () {
              hideSearchDropDown();
              widget.onPressIcon!();
              setState(() {});
            },
            icon: iconClearWidget(),
            iconSize: widget.iconSize,
            padding: widget.paddingIcon ?? const EdgeInsets.all(8.0)),
        hintText: widget.hintText,
        // errorText: errorText,
        enabledBorder: fcBorder,
        errorBorder: errBorder,
        focusedBorder: enBorder);
  }

  OutlineInputBorder _getBorder(double size, Color color) => OutlineInputBorder(
      borderRadius:
          const BorderRadius.only(topLeft: Radius.circular(200), bottomLeft: Radius.circular(200)),
      borderSide: BorderSide(color: color, width: 0.5));

  //============== HANDLE EVENT ==============

  void handleOnKeyListener(RawKeyEvent key) {
    if (key.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      _selectedItem =
          _selectedItem < (widget.items?.length ?? 1) - 1 ? _selectedItem + 1 : _selectedItem;
      scrollFun();
    } else if (key.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      _selectedItem = _selectedItem > 0 ? _selectedItem - 1 : _selectedItem;
      scrollFun();
    } else if (key.isKeyPressed(LogicalKeyboardKey.escape)) {
      if (widget.controller != null) {
        widget.controller!.clear();
      }
      focusNode.unfocus();
    }
    entry?.markNeedsBuild();
  }

  void handleSearchButton() {
    if (widget.controller?.text == "") {
      errorText = MultiLanguage.get("msg_input_search_home");
      UtilUI.showCustomDialog(
        context,
        errorText,
        title: MultiLanguage.get('ttl_notifications'),
      );
      return;
    }
    if ((widget.controller?.text.length ?? 0) < 4) {
      errorText = MultiLanguage.get("msg_input_search_character");
      UtilUI.showCustomDialog(
        context,
        errorText,
        title: MultiLanguage.get('ttl_notifications'),
      );
      return;
    }
    if (widget.onSubmit != null) {
      hideSearchDropDown();
      widget.onSubmit!();
      emptyText = widget.controller?.text ?? '';
    }
  }
}
