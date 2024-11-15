import 'package:flutter/services.dart';
import 'package:hainong/common/models/item_list_model.dart';
import 'package:hainong/common/ui/core_button_custom.dart';
import 'package:hainong/common/ui/label_custom.dart';
import 'package:hainong/common/ui/loading.dart';
import 'package:hainong/common/ui/textfield_custom.dart';
import 'package:hainong/common/ui/title_helper.dart';
import '../model/market_price_history_model.dart';
import '../model/market_price_model.dart';
import 'package:hainong/features/home/ui/import_ui_home.dart';
import '../market_price_bloc.dart';

class MarketPriceCreateReportPage extends BasePage {
  final MarketPriceModel? marketPriceModel;
  final bool isReview,isCreate;
  final Function? funReload;

  MarketPriceCreateReportPage({Key? key, this.marketPriceModel, this.isReview = false,this.isCreate = false ,this.funReload})
      : super(key: key, pageState: _MarketPriceCreateReportPageState());
}

class _MarketPriceCreateReportPageState extends BasePageState {
  final _goodCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  final FocusNode _focusPrice = FocusNode();
  final FocusNode _focusMinPrice = FocusNode();
  final FocusNode _focusMaxPrice = FocusNode();
  final ItemModel _locationProvinces = ItemModel();
  final ItemModel _locationDistrict = ItemModel();
  final ItemModel _selectedGoodType = ItemModel();
  final List<ItemModel> _provinces = [];
  final List<ItemModel> _district = [];
  final List<ItemModel> _goodType = [];
  MarketPriceModel? _marketPriceModel;

  @override
  void initState() {
    bloc = MarketPriceBloc();
    bloc!.stream.listen((state) {
      if (state is LoadProvinceState) {
        _provinces.addAll(state.resp.data.list);
        if (state.showLocation) _showLocations(loadProvince: false, isProvince: true);
      } else if (state is LoadDistrictState) {
        _district.addAll(state.response.data.list);
        if (state.showLocation) _showLocations(loadDistrict: true, isProvince: false);
      } else if (state is CreateReportPriceState && isResponseNotError(state.baseResponse, passString: true)) {
        UtilUI.showCustomDialog(context, MultiLanguage.get('msg_feedback_success'), title: MultiLanguage.get('ttl_alert'))
            .whenComplete(() => UtilUI.goBack(context, true));
      } else if (state is UpdateStatusState && isResponseNotError(state.resp, passString: true)) {
        (widget as MarketPriceCreateReportPage).funReload!();
        String temp = 'Đã chấp nhận đóng góp thành công';
        if (state.status == '0') temp = 'Đã từ chối đóng góp thành công';
        UtilUI.showCustomDialog(context, temp, title: MultiLanguage.get('ttl_alert'))
            .whenComplete(() => UtilUI.goBack(context, true));
      }
    });
    _getTypeGood();
    _focusListeners(_priceCtrl, _focusPrice);
    _focusListeners(_minPriceCtrl, _focusMinPrice, minCtrComp: _minPriceCtrl, maxCtrComp: _maxPriceCtrl);
    _focusListeners(_maxPriceCtrl, _focusMaxPrice, minCtrComp: _minPriceCtrl, maxCtrComp: _maxPriceCtrl);
    _marketPriceModel = (widget as MarketPriceCreateReportPage).marketPriceModel;
    if (_marketPriceModel != null) {
      _goodCtrl.text = _marketPriceModel?.title ?? '';
      _unitCtrl.text = _marketPriceModel?.unit ?? '';
      _selectedGoodType.name = _marketPriceModel?.agricultural_type == 'agricultural'
          ? MultiLanguage.get('lbl_agricultural')
          : MultiLanguage.get('lbl_fertilizer');
      _selectedGoodType.id = (_marketPriceModel?.agricultural_type == 'agricultural') ? '0' : '1';
      _locationDistrict.name = _marketPriceModel?.district_name ?? '';
      _locationDistrict.id = _marketPriceModel?.district_id.toString() ?? '';
      _locationProvinces.name = _marketPriceModel?.province_name ?? '';
      _locationProvinces.id = _marketPriceModel?.province_id.toString() ?? '';
      if (_marketPriceModel!.lastDetail.id > 0 && (widget as MarketPriceCreateReportPage).isReview) {
        _priceCtrl.text = Util.doubleToString(_marketPriceModel!.lastDetail.price);
        _minPriceCtrl.text = Util.doubleToString(_marketPriceModel!.lastDetail.min_price);
        _maxPriceCtrl.text = Util.doubleToString(_marketPriceModel!.lastDetail.max_price);
      }
    }
    super.initState();
  }

  void _getTypeGood() {
    _goodType.addAll([
      ItemModel(
        id: '0',
        name: MultiLanguage.get('lbl_agricultural'),
      ),
      ItemModel(
        id: '1',
        name: MultiLanguage.get('lbl_fertilizer'),
      )
    ]);
  }

  @override
  void dispose() {
    _provinces.clear();
    _district.clear();
    _goodType.clear();
    _goodCtrl.dispose();
    _unitCtrl.dispose();
    _typeCtrl.dispose();
    _priceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _minPriceCtrl.dispose();
    _focusMaxPrice.dispose();
    _focusMinPrice.dispose();
    _focusPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, {Color color = Colors.white}) {
    final page = widget as MarketPriceCreateReportPage;
    return Stack(children: [
      Scaffold(
        appBar: AppBar(title: Padding(padding: const EdgeInsets.only(right: 48),
            child: TitleHelper(page.isReview ? 'Duyệt đóng góp' : 'ttl_contribute_price',
                url: 'https://help.hainong.vn/huong-dan/27')),
            elevation: 0, centerTitle: true),
        backgroundColor: color,
        body: GestureDetector(
            onVerticalDragDown: (details) {
              clearFocus();
            },
            onTapDown: (value) {
              clearFocus();
            },
            child: Column(children: [
              Expanded(child: ListView(
                padding: EdgeInsets.all(32.sp),
                children: [
                  SizedBox(height: 16.sp,),
                  _lineInfo(
                    MultiLanguage.get('lbl_product2'),
                    TextFieldCustom(
                        _goodCtrl,
                        null,
                        null,
                        MultiLanguage.get('msg_input_good'),
                        readOnly: page.isReview || page.isCreate,
                        color : const Color(0xFFF5F6F8),
                        borderColor: const Color(0XFFF5F6F8)
                    ),
                  ),
                  SizedBox(height: 16.sp,),
                  Row(
                    children: [
                      Expanded(
                        child: _lineInfo(
                          MultiLanguage.get('lbl_unit'),
                          TextFieldCustom(_unitCtrl, null, null, MultiLanguage.get('msg_input_unit'), readOnly: page.isReview || page.isCreate, color: const Color(0xFFF5F6F8), borderColor: const Color(0XFFF5F6F8)),
                        ),
                      ),
                      SizedBox(
                        width: 24.sp,
                      ),
                      Expanded(
                        child: _lineInfo(
                          MultiLanguage.get('lbl_typeGood'),
                          CoreButtonCustom(
                            _showListGoodType,
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 40.sp),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.sp),
                                  color: const Color(0xFFF5F6F8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: BlocBuilder(
                                      bloc: bloc,
                                      buildWhen: (oldsState, newState) =>
                                      newState is SetGoodTypeState || newState is ResetSearchState,
                                      builder: (context, state) {
                                        return LabelCustom(
                                            _selectedGoodType.name.isEmpty
                                                ? MultiLanguage.get('msg_input_type_good')
                                                : _selectedGoodType.name,
                                            size: 40.sp,
                                            color: const Color(0xFF494747),
                                            weight: FontWeight.normal,
                                            line: 1);
                                      },
                                    ),),
                                    SizedBox(width: 16.sp,),
                                    Icon(Icons.arrow_drop_down, color: const Color(0xFF919191), size: 48.sp)
                                  ],
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16.sp,),
                  _lineInfo(
                    MultiLanguage.get('lbl_province'),
                    CoreButtonCustom(
                          () => _showLocations(isProvince: true),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 40.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.sp),
                          color: const Color(0xFFF5F6F8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: BlocBuilder(
                                  bloc: bloc,
                                  buildWhen: (oldS, newS) => newS is SetLocationState || newS is ResetSearchState,
                                  builder: (context, state) => Padding(
                                    child: LabelCustom(
                                        _locationProvinces.name.isEmpty
                                            ? MultiLanguage.get('lbl_location')
                                            : _locationProvinces.name,
                                        size: 40.sp,
                                        color: const Color(0xFF494747),
                                        weight: FontWeight.normal,
                                        overflow: TextOverflow.ellipsis,
                                        line: 1),
                                    padding: EdgeInsets.symmetric(vertical: 4.sp),
                                  )),
                            ),
                            SizedBox(
                              width: 16.sp,
                            ),
                            Icon(Icons.arrow_drop_down, color: const Color(0xFF919191), size: 48.sp)
                          ],
                        ),
                      ),
                    ),
                  ),
                  _lineInfo(
                    MultiLanguage.get('lbl_district'),
                    CoreButtonCustom(
                          () => _showLocations(isProvince: false, idProvince: _locationProvinces.id),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30.sp, vertical: 40.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.sp),
                          color: const Color(0xFFF5F6F8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: BlocBuilder(
                                bloc: bloc,
                                buildWhen: (oldsState, newState) =>
                                newState is SetLocationState || newState is ResetSearchState,
                                builder: (context, state) {
                                  return LabelCustom(
                                      _locationDistrict.name.isEmpty
                                          ? MultiLanguage.get('lbl_location')
                                          : _locationDistrict.name,
                                      size: 40.sp,
                                      overflow: TextOverflow.ellipsis,
                                      color: const Color(0xFF494747),
                                      weight: FontWeight.normal,
                                      line: 1);
                                },
                              ),
                            ),
                            SizedBox(
                              width: 16.sp,
                            ),
                            Icon(Icons.arrow_drop_down, color: const Color(0xFF919191), size: 48.sp)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.sp,),
                  _lineInfo('Giá hiện tại',
                    UtilUI.createTextField(
                        context,
                        _priceCtrl,
                        _focusPrice,
                        null,
                        MultiLanguage.get('msg_input_price'),
                        readOnly: page.isReview,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp("[0-9]"),
                          ),
                        ],
                        suffixIcon: Text(constants.defaultCurrency),
                        inputType: TextInputType.number,
                        onChanged: (ctr, value) => _onTextChanged(_priceCtrl, value),
                        fillColor: const Color(0xFFF5F6F8),borderColor: const Color(0XFFF5F6F8)
                    ),
                  ),
                  /*SizedBox(height: 16.sp,),
                  Row(
                    children: [
                      Expanded(
                        child:_lineInfo(
                          MultiLanguage.get('lbl_min_price'),
                          UtilUI.createTextField(
                              context,
                              _minPriceCtrl,
                              _focusMinPrice,
                              null,
                              MultiLanguage.get('msg_input_price'),
                              readOnly: page.isReview,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9 ]"))],
                              inputType: TextInputType.number,
                              suffixIcon: Text(constants.defaultCurrency),
                              onChanged: (ctrl, value) => _onTextChanged(_minPriceCtrl, value),
                              fillColor: const Color(0xFFF5F6F8),borderColor: const Color(0XFFF5F6F8)
                          ),
                        ),
                      ),

                      SizedBox( width: 24.sp,),

                      Expanded(
                        child: _lineInfo(
                          MultiLanguage.get('lbl_max_price'),
                          UtilUI.createTextField(context, _maxPriceCtrl, _focusMaxPrice, null, MultiLanguage.get('msg_input_price'),
                              readOnly: page.isReview,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9 ]"))],
                              inputType: TextInputType.number,
                              inputAction: TextInputAction.done,
                              suffixIcon: Text(constants.defaultCurrency),
                              onChanged: (ctrl, value) => _onTextChanged(_maxPriceCtrl, value),
                              fillColor: const Color(0xFFF5F6F8),borderColor: const Color(0XFFF5F6F8)
                          ),
                        ),
                      ),
                    ],
                  ),*/
                  // _line(),
                  // _titleListReport(),
                  // _line(),
                  // _listReport(),
                ],
              )),
              Padding(child: page.isReview ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                CoreButtonCustom(
                      () => _setStatus('0'),
                  Container(width: 0.5.sw - 48.sp,
                    padding: EdgeInsets.all(40.sp),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15.sp)
                    ),
                    child: Text('Từ chối',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 48.sp
                      ),
                    ),
                  ),
                ),
                CoreButtonCustom(
                      () => _setStatus('1'),
                  Container(width: 0.5.sw - 48.sp,
                    padding: EdgeInsets.all(40.sp),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1AAD80),
                        borderRadius: BorderRadius.circular(15.sp)
                    ),
                    child: Text('Chấp nhận',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 48.sp
                      ),
                    ),
                  ),
                )
              ]) : CoreButtonCustom(
                _successForm,
                Container(
                  width: 1.sw - 64.sp,
                  padding: EdgeInsets.all(40.sp),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1AAD80),
                      borderRadius: BorderRadius.circular(15.sp)
                  ),
                  child: Text(
                    MultiLanguage.get('lbl_contribute'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp
                    ),
                  ),
                ),
              ), padding: EdgeInsets.all(32.sp))
            ])
        ),
      ),
      Loading(bloc)
    ]);
  }

  Widget _listReport() => ListView.builder(
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (index, context) => Padding(
            padding: EdgeInsets.only(bottom: 24.sp),
            child: _itemReport(30000, 28000, 32000, '16-3-2022'),
          ));

  Widget _itemReport(double price, double minPrice, double maxPrice, String date) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Util.doubleToString(price),
              style: TextStyle(
                color: Colors.black,
                fontSize: 40.sp,
              ),
            ),
            Text(
              Util.doubleToString(maxPrice - minPrice),
              style: TextStyle(
                color: Colors.black,
                fontSize: 40.sp,
              ),
            ),
            Text(
              '${Util.doubleToString(minPrice)} - ${Util.doubleToString(maxPrice)}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 40.sp,
              ),
            ),
            Text(
              date.toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 40.sp,
              ),
            ),
          ],
        ),
      );

  Widget _lineInfo(String title, Widget widget) => Padding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
              child: Text(
                title,
                style: TextStyle(color: const Color(0xFF787878), fontSize: 40.sp,),
              ),
            ),
            SizedBox(height: 8.sp,),
            widget,
          ],
        ),
        padding: EdgeInsets.only(bottom: 16.sp),
      );

  Widget _line() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.sp, vertical: 16.sp),
        child: Container(
          color: Colors.black,
          height: 2.sp,
        ),
      );

  void _successForm() {
    if (_goodCtrl.text.isEmpty ||
        _unitCtrl.text.isEmpty ||
        _selectedGoodType.id.isEmpty ||
        _locationProvinces.id.isEmpty ||
        _locationDistrict.id.isEmpty ||
        _priceCtrl.text.isEmpty/* ||
        _minPriceCtrl.text.isEmpty ||
        _maxPriceCtrl.text.isEmpty*/) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(MultiLanguage.get('msg_validate_input_market_pice')),
        duration: const Duration(seconds: 2),
      ));
      return;
    }
    /*if ((Util.stringToDouble(_minPriceCtrl.text, locale: constants.localeVILang) >
            Util.stringToDouble(_maxPriceCtrl.text, locale: constants.localeVILang) &&
        _maxPriceCtrl.text.isNotEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(MultiLanguage.get('msg_validate_min_price_and_max_price')),
        duration: const Duration(seconds: 2),
      ));
      _minPriceCtrl.text = '';
      _maxPriceCtrl.text = '';
      return;
    }*/
    if (Util.stringToDouble(_priceCtrl.text, locale: constants.localeVILang) <= 0/* ||
        Util.stringToDouble(_minPriceCtrl.text, locale: constants.localeVILang) <= 0 ||
        Util.stringToDouble(_maxPriceCtrl.text, locale: constants.localeVILang) <= 0*/) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(MultiLanguage.get('msg_validate_input_market_price_bigger_0')),
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    bloc!.add(CreateReportPriceEvent(
      MkPHistoryModel()
        ..title = _goodCtrl.text
        ..unit = _unitCtrl.text
        ..agricultural_type = _selectedGoodType.name
        ..provinceId = int.parse(_locationProvinces.id)
        ..districtId = int.parse(_locationDistrict.id)
        ..price = Util.stringToDouble(_priceCtrl.text, locale: constants.localeVILang)
        ..min_price = Util.stringToDouble(_minPriceCtrl.text, locale: constants.localeVILang)
        ..max_price = Util.stringToDouble(_maxPriceCtrl.text, locale: constants.localeVILang),
    ));
  }

  void _showListGoodType() {
    if ((widget as MarketPriceCreateReportPage).isReview || (widget as MarketPriceCreateReportPage).isCreate) return;
    UtilUI.showOptionDialog(context, MultiLanguage.get('lbl_typeGood'), _goodType, _selectedGoodType.id).then((value) {
      if (value != null) _setGoodType(value);
    });
  }

  void _setGoodType(ItemModel value) {
    if (_selectedGoodType.id == value.id) return;
    _selectedGoodType.id = value.id;
    _selectedGoodType.name = value.name;
    bloc!.add(SetGoodTypeEvent());
  }

  void _showLocations({bool loadProvince = true, bool loadDistrict = true, String idProvince = '', required bool isProvince}) {
    if ((widget as MarketPriceCreateReportPage).isReview || (widget as MarketPriceCreateReportPage).isCreate) return;
    if (isProvince) {
      if (_provinces.isEmpty) {
        if (loadProvince) bloc!.add(LoadProvinceEvent(showLocation: true));
        return;
      }
      UtilUI.showOptionDialog(context, MultiLanguage.get(languageKey.lblProvince), _provinces, _locationProvinces.id)
          .then((value) {
        if (value != null) _setLocation(value, isProvince);
      });
    } else {
      if (_locationProvinces.name.isEmpty) return;
      if (_district.isEmpty && idProvince.isNotEmpty) {
        if (loadDistrict) bloc!.add(LoadDistrictEvent(showLocation: true, idProvince: idProvince));
        return;
      }
      UtilUI.showOptionDialog(context, MultiLanguage.get(languageKey.lblDistrict), _district, _locationDistrict.id).then((value) {
        if (value != null) _setLocation(value, isProvince);
      });
    }
  }

  _focusListeners(TextEditingController ctr, FocusNode focus,
      {TextEditingController? minCtrComp, TextEditingController? maxCtrComp}) {
    focus.addListener(() {
      if (focus.hasFocus) {
        double tmp = Util.stringToDouble(ctr.text, locale: constants.localeVILang);
        if (tmp > 0) {
          ctr.text = tmp.toString();
          //if (_locale == Constants.localeVILang)
          ctr.text = ctr.text.replaceFirst('.0', '', ctr.text.length - 2);
        } else
          ctr.text = '';
      } else {
        int count = 0;
        String tmp = ctr.text;
        for (int i = 0; i < tmp.length - 1; i++) {
          if (tmp.substring(i, i + 1) == '.') count++;
        }

        for (int i = count - 1; i > 0; i--) tmp = tmp.replaceFirst('.', '');

        ctr.text = tmp;
        ctr.text =
            Util.doubleToString(Util.stringToDouble(ctr.text, locale: constants.localeVILang), locale: constants.localeVILang);
      }
    });
  }

  _onTextChanged(TextEditingController ctr, String value) {
    int count = 0;
    String tmp = value;
    for (int i = 0; i < tmp.length - 1; i++) {
      if (tmp.substring(i, i + 1) == '.') count++;
    }

    for (int i = count - 1; i > 0; i--) tmp = tmp.replaceFirst('.', '');

    double rs = Util.stringToDouble(tmp, locale: constants.localeVILang);
    if (rs > 9999999999999999) {
      ctr.text = value.substring(0, value.length - 1);
      ctr.selection = TextSelection.collapsed(offset: ctr.text.length);
    }
  }

  void _setLocation(ItemModel value, bool isProvince) {
    if (isProvince) {
      if (_locationProvinces.id == value.id) return;
      _locationProvinces.id = value.id;
      _locationProvinces.name = value.name;
      _locationDistrict.name = '';
      _locationDistrict.id = '';
      _district.clear();
    } else {
      if (_locationDistrict.id == value.id) return;
      _locationDistrict.id = value.id;
      _locationDistrict.name = value.name;
    }
    bloc!.add(SetLocationEvent());
  }

  void _setStatus(String status) => bloc!.add(UpdateStatusEvent(_marketPriceModel!.lastDetail.id.toString(), status));
}
