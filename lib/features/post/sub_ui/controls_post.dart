import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/button_image_circle_widget.dart';
import 'import_lib_post_sub_ui.dart';

class ControlsPost extends StatelessWidget {
  final bool isLike, isComment, isShare, isNotOwner, hasShare;
  final int totalLike, totalComment;
  final int? index;
  final Function funLike, funUnlike, funComment, funShare, funTransfer;
  const ControlsPost(this.isLike, this.isComment, this.isShare, this.isNotOwner, this.totalLike,
      this.totalComment, this.funLike, this.funUnlike, this.funComment,
      this.funShare, this.funTransfer, {Key? key, this.hasShare = true, this.index}):super(key:key);

  @override
  Widget build(context) => Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ControlPost('assets/images/ic_like.png', isLike, ' Thích', totalLike, () {
            if (isLike) {
              index == null ? funUnlike(context) : funUnlike(context, index);
            } else {
              index == null ? funLike(context) : funLike(context, index);
            }
      }),
      ControlPost('assets/images/ic_comment.png', isComment, ' Bình luận', totalComment, () => funComment(context), flex: 7),
      if (hasShare) ControlPost('assets/images/ic_share.png', isShare, ' Chia sẻ', 0,
        () => index == null ? funShare(context) : funShare(context, index)),
      if (isNotOwner) ControlPost('assets/images/ic_transfer.png', false,
        ' Tặng điểm', 0, () => funTransfer(context))
  ]);
}

class ControlPost extends StatelessWidget {
  final String assetPath, title;
  final int count, flex;
  final bool check;
  final Function function;
  const ControlPost(this.assetPath, this.check, this.title, this.count, this.function, {Key? key, this.flex = 5}):super(key:key);

  @override
  Widget build(context) {
    final temp = ButtonImageCircleWidget(0, function, child: Padding(child: Wrap(children: [
      Image.asset(assetPath, height: 46.sp, width: 46.sp, color: check ? StyleCustom.likeColor : StyleCustom.borderTextColor),
      UtilUI.createLabel(title, color: Colors.black, fontSize: 34.sp),
      if (count > 0) UtilUI.createLabel(' ' + Util().formatNum2(count.toDouble(), digit: 1), color: Colors.black, fontSize: 34.sp)
    ], crossAxisAlignment: WrapCrossAlignment.center, alignment: WrapAlignment.end), padding: EdgeInsets.symmetric(vertical: 40.sp)));
    return count > 0 ? Flexible(flex: flex, child: temp) : temp;
  }
}
