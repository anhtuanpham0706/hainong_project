import 'package:hainong/common/ui/button_image_widget.dart';
import 'package:hainong/common/ui/import_lib_ui.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/measured_size.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/features/cart/cart_bloc.dart';
import 'package:hainong/features/cart/ui/cart_item.dart';
import 'package:hainong/features/cart/cart_model.dart';

class OrderDtlPage extends BasePage {
  final Function funReload;
  OrderDtlPage(OrderModel order, bool isMine, this.funReload, {int idBusiness = -1, Key? key}) :
    super(pageState: _OrderDtlPageState(order, isMine, idBusiness), key: key);
}

class _OrderDtlPageState extends BasePageState {
  final TextEditingController _ctrName = TextEditingController(),
    _ctrPhone = TextEditingController(), _ctrEmail = TextEditingController(),
    _ctrAddress = TextEditingController();
  final OrderModel order;
  final bool isMine;
  final int idBusiness;
  final colorItem = const Color(0XFFF5F6F8);
  final require = LabelCustom(' (*)', color: Colors.red, size: 36.sp, weight: FontWeight.normal);

  _OrderDtlPageState(this.order, this.isMine, this.idBusiness);

  @override
  void dispose() {
    order.items.clear();
    _ctrName.dispose();
    _ctrPhone.dispose();
    _ctrEmail.dispose();
    _ctrAddress.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = CartBloc(type: 'detail');
    bloc!.stream.listen((state) {
      if (state is LoadOrderDtlState && isResponseNotError(state.resp)) {
        order.items.addAll(state.resp.data.items);
      } else if (state is SetStatusOrderState && isResponseNotError(state.resp, passString: true)) {
        setState(() {
          order.status = state.status;
        });

        UtilUI.showCustomDialog(context, state.status == 'done' ? 'Đã xử lý' : 'Đã huỷ đơn thành công');
        (widget as OrderDtlPage).funReload();
      }
    });
    super.initState();
    if (order.items.isEmpty) bloc!.add(LoadOrderDtlEvent(order.id, isMine, idBusiness: idBusiness));
    _ctrName.text = order.name;
    _ctrPhone.text = order.phone_number;
    _ctrEmail.text = order.email;
    _ctrAddress.text = order.shipping_address;
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    Color statusColor = Colors.orangeAccent;
    String status = 'Chờ xác nhận';
    if (order.status == 'done') {
      statusColor = Colors.green;
      status = 'Hoàn thành';
    } else if (order.status == 'cancelled') {
      statusColor = Colors.red;
      status = 'Đã huỷ';
    }

    return Scaffold(appBar: AppBar(titleSpacing: 0, centerTitle: true, elevation: 2,
        title: UtilUI.createLabel('Chi tiết đơn hàng')),
        backgroundColor: color,
        body: Stack(children: [
          Column(children: [
            Expanded(child: ListView(padding: EdgeInsets.zero, children: [
              Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
                Expanded(child: Column(children: [
                  Row(children: [
                    _title('Mã đơn: '),
                    Expanded(child: LabelCustom(order.sku, color: Colors.black, size: 46.sp)),
                  ], crossAxisAlignment: CrossAxisAlignment.end),
                  SizedBox(height: 30.sp),
                  Row(children: [
                    _title('Ngày tạo: '),
                    LabelCustom(Util.strDateToString(order.created_at, pattern: 'dd/MM/yyyy'), color: Colors.black, size: 46.sp),
                  ], crossAxisAlignment: CrossAxisAlignment.end)
                ], crossAxisAlignment: CrossAxisAlignment.start)),
                Expanded(child: LabelCustom(status, color: statusColor, size: 56.sp, align: TextAlign.center))
              ])),

              Divider(height: 20.sp, color: colorItem, thickness: 20.sp),

              Padding(padding: EdgeInsets.all(40.sp), child: Column(children: [
                LabelCustom('Thông tin chi tiết', color: StyleCustom.primaryColor, size: 52.sp, weight: FontWeight.normal),
                SizedBox(height: 40.sp),

                _title('Họ tên người nhận hàng'),
                Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                    child: TextFieldCustom(_ctrName, null, null, '', maxLine: 0,
                        size: 42.sp, color: colorItem, borderColor: colorItem,
                        type: TextInputType.multiline, readOnly: true,
                        padding: EdgeInsets.all(30.sp))),

                Row(children: [
                  Expanded(child: Column(children: [
                    _title('Số ĐT'),
                    Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                        child: TextFieldCustom(_ctrPhone, null, null, '',
                            size: 42.sp, color: colorItem, borderColor: colorItem,
                            readOnly: true, padding: EdgeInsets.all(30.sp))),
                  ], crossAxisAlignment: CrossAxisAlignment.start)),
                  SizedBox(width: 20.sp),
                  Expanded(child: Column(children: [
                    _title('Email'),
                    Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp),
                        child: TextFieldCustom(_ctrEmail, null, null, '', readOnly: true,
                            size: 42.sp, color: colorItem, borderColor: colorItem, maxLine: 0,
                            type: TextInputType.multiline, padding: EdgeInsets.all(30.sp))),
                  ], crossAxisAlignment: CrossAxisAlignment.start))
                ], crossAxisAlignment: CrossAxisAlignment.start),

                _title('Địa chỉ giao hàng'),
                Padding(padding: EdgeInsets.only(top: 16.sp, bottom: 40.sp), child:
                TextFieldCustom(_ctrAddress, null, null, '', size: 42.sp, color: colorItem,
                    borderColor: colorItem, maxLine: 0, padding: EdgeInsets.all(30.sp),
                    readOnly: true, type: TextInputType.multiline)),
                SizedBox(height: 40.sp),
                BlocBuilder(bloc: bloc, buildWhen: (oldS, newS) => newS is LoadOrderDtlState && order.items.isNotEmpty,
                    builder: (context, state) => CartItem((bloc as CartBloc), order, lock: true))
              ], crossAxisAlignment: CrossAxisAlignment.start))
            ])),
            _totalPaymentWidget(),
            if (order.status == 'pending') Padding(padding: EdgeInsets.all(40.sp), child: Row(children: [
              ButtonImageWidget(16.sp, _cancel, Container(padding: EdgeInsets.all(40.sp),
                        width: isMine && idBusiness < 0 ? (1.sw - 80.sp) : (0.5.sw - 60.sp), child: LabelCustom('Huỷ đơn',
                            color: Colors.white, size: 48.sp, weight: FontWeight.normal,
                            align: TextAlign.center)), color: Colors.red),
              if (!isMine || idBusiness > 0) ButtonImageWidget(16.sp, _complete, Container(padding: EdgeInsets.all(40.sp),
                        width: 0.5.sw - 60.sp, child: LabelCustom('Hoàn thành đơn',
                            color: Colors.white, size: 48.sp, weight: FontWeight.normal,
                            align: TextAlign.center)), color: StyleCustom.primaryColor)
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween))
          ], crossAxisAlignment: CrossAxisAlignment.center),
          Loading(bloc)
        ])
    );
  }

  Widget _title(String title) => LabelCustom(title, color: const Color(0xFF787878), size: 36.sp, weight: FontWeight.normal);

  void _cancel() => UtilUI.showCustomDialog(context, 'Bạn có chắc muốn huỷ đơn này không?', isActionCancel: true).then((value) {
    if (value != null && value) bloc!.add(SetStatusOrderEvent(order.id, 'cancelled', isMine, idBusiness: idBusiness));
  });

  void _complete() => bloc!.add(SetStatusOrderEvent(order.id, 'done', isMine, idBusiness: idBusiness));

  Widget _totalPaymentWidget() => Padding(child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        LabelCustom('Tổng tiền: ', color: Colors.black, size: 42.sp, weight: FontWeight.normal),
        MeasuredSize(child: LabelCustom(Util.doubleToString(order.price_total + (order.max_discount??.0)) + ' đ', color: Colors.black87, size: 46.sp),
          onChange: (size) => bloc!.add(ChangeSizeEvent(type: 'total', width: size.width)))
      ]),
      if (order.coupon_code != null) Padding(child: Row(children: [
        LabelCustom('Giảm giá: ', color: Colors.black, size: 42.sp, weight: FontWeight.normal),
        SpaceCartOrder(bloc, 'dis'),
        MeasuredSize(child: LabelCustom('-' + Util.doubleToString(order.max_discount!) + ' đ', color: Colors.red, size: 46.sp),
          onChange: (size) => bloc!.add(ChangeSizeEvent(type: 'dis', width: size.width)))
      ], mainAxisAlignment: MainAxisAlignment.end), padding: EdgeInsets.only(top: 10.sp)),
      SizedBox(height: 10.sp),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        LabelCustom('Thanh toán: ', color: Colors.black, size: 42.sp, weight: FontWeight.normal),
        SpaceCartOrder(bloc, 'pay'),
        MeasuredSize(child: LabelCustom(Util.doubleToString(order.price_total) + ' đ', color: Colors.red, size: 46.sp),
          onChange: (size) => bloc!.add(ChangeSizeEvent(type: 'pay', width: size.width)))
      ]),
    ]), padding: EdgeInsets.fromLTRB(0, 40.sp, 40.sp, order.status == 'pending' ? 0 : WidgetsBinding.instance.window.padding.bottom.sp));
}