import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hainong/features/function/tool/map_task/models/map_item_model.dart';

class TreeView extends StatefulWidget {
  const TreeView({
    Key? key,
    required this.nodes,
    this.level = 0,
    required this.onChanged,
  }) : super(key: key);

  final List<TreeNode> nodes;
  final int level;
  final void Function(List<TreeNode> newNodes) onChanged;

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  late List<TreeNode> nodes;

  @override
  void initState() {
    super.initState();
    nodes = widget.nodes;
  }

  TreeNode _unselectAllSubTree(TreeNode node) {
    final treeNode = node.copyWith(
      isSelected: false,
      children: node.children.isEmpty ? null : node.children.map((e) => _unselectAllSubTree(e)).toList(),
    );
    return treeNode;
  }

  TreeNode _selectAllSubTree(TreeNode node) {
    final treeNode = node.copyWith(
      isSelected: true,
      children: node.children.isEmpty ? null : node.children.map((e) => _selectAllSubTree(e)).toList(),
    );
    return treeNode;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes != nodes) {
      nodes = widget.nodes;
    }

    return Container(
      padding: EdgeInsets.only(left: 40.sp),
      child: ListView.builder(
        itemCount: nodes.length,
        physics: widget.level != 0 ? const NeverScrollableScrollPhysics() : null,
        shrinkWrap: widget.level != 0,
        itemBuilder: (context, index) {
          return ListTileTheme(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: 0,

            dense: true,
            horizontalTitleGap: 0.0,
            minLeadingWidth: 0,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                listTileTheme: ListTileTheme.of(context).copyWith(dense: true, minVerticalPadding: 0),
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                childrenPadding: EdgeInsets.zero,
                tilePadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                leading: iconArrowSelect(index),
                expandedAlignment: Alignment.centerLeft,
                collapsedTextColor: Colors.black87,
                textColor: Colors.black87,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: TitleCheckBox(
                    onChanged: (item) {
                      switch (nodes[index].checkBoxState) {
                        case CheckBoxState.selected:
                          nodes[index] = _unselectAllSubTree(nodes[index]);
                          break;
                        case CheckBoxState.unselected:
                          nodes[index] = _selectAllSubTree(nodes[index]);
                          break;
                        case CheckBoxState.partial:
                          nodes[index] = _unselectAllSubTree(nodes[index]);
                          break;
                      }
                      if (widget.level == 0) {
                        setState(() {});
                      }
                      widget.onChanged(nodes);
                    },
                    item: nodes[index].item,
                    checkBoxState: nodes[index].checkBoxState,
                    isBold: widget.level < 2,
                    level: widget.level),
                children: [
                  TreeView(
                    nodes: nodes[index].children,
                    level: widget.level + 1,
                    onChanged: (newNodes) {
                      bool areAllItemsSelected = !nodes[index].children.any((element) => !element.isSelected);
                      nodes[index] = nodes[index].copyWith(
                        isSelected: areAllItemsSelected,
                        children: newNodes,
                      );

                      widget.onChanged(nodes);
                      if (widget.level == 0) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? iconArrowSelect(int index) {
    switch (nodes[index].children.isEmpty) {
      case true:
        return const Icon(Icons.arrow_drop_down, size: 32, color: Colors.white);
      default:
        return const Icon(Icons.arrow_right, size: 32, color: Colors.grey);
    }
  }
}

class TitleCheckBox extends StatelessWidget {
  const TitleCheckBox({Key? key, required this.item, required this.checkBoxState, required this.onChanged, required this.level, this.isBold = false}) : super(key: key);

  final PetModel item;
  final bool isBold;
  final CheckBoxState checkBoxState;
  final Function(PetModel item) onChanged;
  final int level;

  @override
  Widget build(BuildContext context) {
    const size = 24.0;
    const borderRadius = BorderRadius.all(Radius.circular(3.0));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (item.image != null)
              if (item.image?.contains("assets") == true) ...[
                Image.asset(item.image!, fit: BoxFit.fitHeight, width: 30.w, height: 100.w)
              ] else ...[
                item.image!.isEmpty
                    ? Image.asset('assets/images/ic_default.png', fit: BoxFit.cover, width: 120.w, height: 120.w)
                    : Image.network(item.image!, fit: BoxFit.cover, width: 120.w, height: 120.w)
              ]
            else
              const SizedBox(),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.sp),
                  child: Text(item.name, style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ],
        ),
        IconButton(
            onPressed: () {
              onChanged(item);
            },
            icon: Container(
                height: size,
                width: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2.0),
                  borderRadius: borderRadius,
                  color: checkBoxState == CheckBoxState.unselected ? Colors.transparent : Colors.green,
                ),
                child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: checkBoxState == CheckBoxState.unselected
                        ? const SizedBox(height: size, width: size)
                        : FittedBox(
                            key: ValueKey(checkBoxState.name),
                            fit: BoxFit.scaleDown,
                            child: Center(
                                child: checkBoxState == CheckBoxState.partial
                                    ? Container(height: 1.8, width: 12.0, decoration: const BoxDecoration(color: Colors.white, borderRadius: borderRadius))
                                    : const Icon(Icons.check, color: Colors.white)))))),
      ],
    );
  }
}

enum CheckBoxState {
  selected,
  unselected,
  partial,
}

class TreeNode {
  final PetModel item;
  final bool isSelected;
  final CheckBoxState checkBoxState;
  final List<TreeNode> children;

  TreeNode({
    required this.item,
    this.isSelected = false,
    this.children = const <TreeNode>[],
  }) : checkBoxState = isSelected ? CheckBoxState.selected : (children.any((element) => element.checkBoxState != CheckBoxState.unselected) ? CheckBoxState.partial : CheckBoxState.unselected);

  TreeNode copyWith({
    String? title,
    bool? isSelected,
    List<TreeNode>? children,
  }) {
    return TreeNode(item: item, isSelected: isSelected ?? this.isSelected, children: children ?? this.children);
  }
}
