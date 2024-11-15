import 'package:hainong/common/ui/avatar_circle_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import '../point_bloc.dart';

class PointItem extends StatelessWidget {
  final PointModel item;
  final int index;
  final String status;
  final Function funChange;
  const PointItem(this.item, this.funChange, this.index, this.status, {Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.all(40.sp),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black12))
        ),
        child: Row(children: [
          AvatarCircleWidget(link: item.sender_avatar, size: 150.sp),
          SizedBox(width: 40.sp),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(children: [
                      if (status == 'pending')
                      UtilUI.createLabel(item.sender_name,
                          color: StyleCustom.textColor2C, fontSize: 45.sp),
                      UtilUI.createLabel(MultiLanguage.get(status == 'pending' ? 'lbl_gave_point' : 'lbl_${status}_point'), fontWeight: FontWeight.w400,
                          color: StyleCustom.textColor2C, fontSize: 45.sp),
                      UtilUI.createLabel(Util.doubleToString(item.points.toDouble()) + MultiLanguage.get('lbl_point') + ' ',
                          color: StyleCustom.textFollowColor, fontSize: 45.sp),
                      if (status != 'pending')
                      UtilUI.createLabel(item.sender_name, color: StyleCustom.textColor2C, fontSize: 45.sp)
                    ]),
                    SizedBox(height: 10.sp),
                    Row(children: [
                      Icon(Icons.av_timer, size: 40.sp, color: Colors.orange),
                      Expanded(
                          child: UtilUI.createLabel(' ${Util.getTimeAgo(item.updated_at)}',
                              color: StyleCustom.textColor6C,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.normal))
                    ]),
                    if (status == 'pending')
                    Padding(padding: EdgeInsets.only(top: 10.sp), child: Row(children: [
                      UtilUI.createCustomButton(()=>funChange(item.id, 'accepted'),
                          MultiLanguage.get('lbl_point_accepted'),
                          fontSize: 35.sp, elevation: 0.0,
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.normal, borderWidth: 0.0),
                      SizedBox(width: 20.sp),
                      UtilUI.createCustomButton(()=>funChange(item.id, 'rejected'),
                          MultiLanguage.get('lbl_point_rejected'),
                          fontSize: 35.sp, elevation: 0.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal, borderWidth: 0.0),
                    ], mainAxisAlignment: MainAxisAlignment.end))
                  ]))
        ]));
  }
}