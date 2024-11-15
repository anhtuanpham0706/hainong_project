import 'package:hainong/common/style_custom.dart';
import 'package:hainong/common/util/util.dart';
import 'package:hainong/common/ui/import_lib_base_ui.dart';
import '../gift_model.dart';

class GiftShopItem extends StatelessWidget {
  final GiftModel giftItem;
  final int userPoint;
  final Function changePoint;
  const GiftShopItem(this.giftItem,this.userPoint,this.changePoint,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String expire = Util.getExpired(giftItem.end_date);
    return Container(
      width: 0.32.sw,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.sp)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(3, 3) // changes position of shadow
            )
          ]
      ),
      margin: EdgeInsets.all(10.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 0.33.sw,
              alignment: Alignment.bottomRight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.sp),
                image: DecorationImage(fit: BoxFit.cover, image: giftItem.image.isNotEmpty ? FadeInImage.assetNetwork(
                    image: Util.getRealPath(giftItem.image), placeholder: 'assets/images/ic_default.png').image
                  : Image.asset('assets/images/ic_default.png').image),
              ),
              child: const SizedBox()),
          Padding(
            padding:  EdgeInsets.only(left: 15.sp,top: 5.sp,bottom: 15.sp),
            child: Text(giftItem.name,style: TextStyle(fontSize: 42.sp,fontWeight: FontWeight.bold),maxLines: 2,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.sp,bottom: 15.sp),
            child: Row(
              children: [
                Text("Quà đã đổi: ",style: TextStyle(fontSize: 38.sp,color: Colors.black87)),
                Text("${giftItem.quantity_exchanged}/${giftItem.quantity}",style: TextStyle(fontSize: 38.sp,color: const Color(0XFFFF7A00) ),),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.sp,bottom: 15.sp),
            child: Row(
              children: [
                  Text("Điểm: ",style: TextStyle(fontSize: 38.sp,color: Colors.black87)),
                  Text(giftItem.points > 0 ? Util.doubleToString(giftItem.points.toDouble()) : "Miễn phí",style: TextStyle(fontSize: 38.sp,color: const Color(0XFFFF7A00))),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.sp,bottom: 15.sp),
            child: Row(
              children: [
                Text("Hạn: ",style: TextStyle(fontSize: 38.sp,color: Colors.black87)),
                Text(expire,style: TextStyle(fontSize: 38.sp,color: const Color(0XFFFF7A00))),
              ],
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                if(_isExpire(expire)) changePoint(giftItem);
              },
              child: Container(
                margin: EdgeInsets.only(top: 10.sp,bottom: 20.sp),
                width: 0.32.sw,
                decoration: BoxDecoration(
                    color: _isExpire(expire) ? StyleCustom.primaryColor : const Color(0XFFB9BBBA),
                    borderRadius: BorderRadius.all(Radius.circular(10.sp))
                ),
                child: Center(child: Padding(
                  padding: EdgeInsets.all(20.sp),
                  child: Text("Đổi quà",style: TextStyle(color: Colors.white,fontSize: 38.sp,fontWeight: FontWeight.bold),),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _isExpire(String expire) => expire != 'Hết hạn' && giftItem.quantity_exchanged != giftItem.quantity && (userPoint >= giftItem.points || giftItem.points == 0);
}
