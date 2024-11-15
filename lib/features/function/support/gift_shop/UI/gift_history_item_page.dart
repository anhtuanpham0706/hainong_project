import 'package:hainong/common/import_lib_system.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import '../gift_history_model.dart';

class GiftHistoryItem extends StatelessWidget {
  final GiftHistoryModel giftHistoryItem;
  const GiftHistoryItem(this.giftHistoryItem,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.sp))
      ),
      margin: EdgeInsets.fromLTRB(10.sp, 10.sp, 10.sp, 10.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10.sp),
            child: Container(
                height: 0.2.sw,
                width:  0.25.sw,
                alignment: Alignment.bottomRight,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.sp),
                    image: DecorationImage(
                        image: giftHistoryItem.image.isNotEmpty
                            ? FadeInImage.assetNetwork(
                            image: giftHistoryItem.image,
                            placeholder: 'assets/images/ic_default.png')
                            .image
                            : Image.asset('assets/images/ic_default.png').image,
                        fit: BoxFit.cover)),
                child: const SizedBox()),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:  EdgeInsets.only(left: 15.sp,top: 5.sp,bottom: 15.sp),
                  child: Text(giftHistoryItem.gift_name,style: TextStyle(fontSize: 48.sp,fontWeight: FontWeight.bold),maxLines: 2,),
                ),
                Row(
                  children: [
                    Padding(
                        padding:  EdgeInsets.only(left: 15.sp,top: 5.sp,bottom: 15.sp),
                        child: Text("Điểm:",style: TextStyle(fontSize: 42.sp),
                        )),
                    Padding(
                      padding:  EdgeInsets.only(left: 15.sp,top: 5.sp,bottom: 15.sp),
                      child: Text(Util.doubleToString(giftHistoryItem.points.toDouble()),style: TextStyle(fontSize: 42.sp,color: Colors.deepOrange),maxLines: 1,),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding:  EdgeInsets.only(left: 15.sp,top: 5.sp,bottom: 15.sp),
                      child: Text("Trạng thái: ",style: TextStyle(fontSize: 42.sp),
                    )),
                    Padding(
                      padding:  EdgeInsets.only(left: 15.sp,top: 5.sp,bottom: 15.sp),
                      child: Text(MultiLanguage.get("lbl_point_${giftHistoryItem.status}"),style: TextStyle(fontSize: 42.sp,color: giftHistoryItem.status == "pending" ? Colors.amber: giftHistoryItem.status == "accepted"? Colors.green : Colors.red),maxLines: 2,),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.sp,top: 5.sp,bottom: 15.sp),
                  child: Text("Ngày đổi: "+Util.dateToString(Util.stringToDateTime(giftHistoryItem.created_at),
                      locale: Constants().localeVI, pattern: 'dd/MM/yyyy'),style: TextStyle(fontSize: 35.sp),maxLines: 2,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
