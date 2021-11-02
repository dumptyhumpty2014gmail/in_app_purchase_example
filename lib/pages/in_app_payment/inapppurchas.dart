import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_example/share/app_colors.dart';
import 'package:in_app_purchase_example/share/app_constraints.dart';
import 'package:in_app_purchase_example/share/text_styles.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String id_notads = 'withoutads';
const String id_ycard = 'mycards';

class IAPConnection {
  // обертка для возможности тестирования
  static InAppPurchase? _instance;
  static set instance(InAppPurchase value) {
    _instance = value;
  }

  static InAppPurchase get instance {
    _instance ??= InAppPurchase.instance;
    return _instance!;
  }
}

void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  // слушаем изменения в покупках

  purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
    Hive.box('in_apppurhase').put(
        'inapploger',
        Hive.box('in_apppurhase').get(
              'inapploger',
              defaultValue: '',
            ) +
            "; " +
            DateTime.now().toString() +
            ': ' +
            purchaseDetails.status.toString());
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // покупка в процессе. пока ни разу не отловил
      if (purchaseDetails.productID != '') {
        Hive.box('in_apppurhase').put(purchaseDetails.productID, 'pending');
      }
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        // print(purchaseDetails.pendingCompletePurchase); //false
        // print(purchaseDetails.error!.code); //
        // print(purchaseDetails.error!.message); //BillingResponse.userCanceled
        // print(purchaseDetails.error!.details);
        // print(purchaseDetails.error!.source); //google_play
      } else if (purchaseDetails.status == PurchaseStatus.purchased
          //     purchaseDetails.status == PurchaseStatus.restored не отлавливаем
          ) {
        if (purchaseDetails.productID != '') {
          Hive.box('in_apppurhase').put(purchaseDetails.productID, 'purchased');
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        // нужно запустить процесс завершения покупки
        await InAppPurchase.instance.completePurchase(
            purchaseDetails);
      }
    }
  });
}

class InAppPurchasesPage extends StatefulWidget {
  InAppPurchasesPage() : super();

  @override
  _InAppPurchasesPageState createState() => _InAppPurchasesPageState();
}

class _InAppPurchasesPageState extends State<InAppPurchasesPage> {
  bool _isAvailable = false;
  void checkAvailable() async {
    final bool isAvailable = await IAPConnection.instance.isAvailable();
    if (_isAvailable != isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
      });
    }
  }

  @override
  void initState() {
    checkAvailable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Покупки'),
      ),
      backgroundColor: AppColors.baseBackgroundColor,
      body: _isAvailable
          ? const InAppList()
          : Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const Text(
                    'Play Market недоступен.',
                    style: TextStyles.whiteTextStyle1Small,
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Возможно, отсутствует интернет или учетная запись.',
                    style: TextStyles.whiteTextStyle1Small,
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                      onPressed: checkAvailable,
                      child: const Text(
                        'Проверить доступность',
                        style: TextStyles.whiteTextStyle1Small,
                      )),
                ],
              ),
            ),
    );
  }
}

class InAppList extends StatefulWidget {
  const InAppList() : super();

  @override
  _InAppListState createState() => _InAppListState();
}

class _InAppListState extends State<InAppList> {
  String _messageDetail = ''; // сообщение служебное
  //List<String> _notFoundIds = []; // Не найденные id продуктов. Не используем, так как выводим только найденные
  List<ProductDetails> _products = []; // найденные продукты
  void getProductDetail() async {
    ProductDetailsResponse productDetailResponse =
        await IAPConnection.instance.queryProductDetails({id_notads, id_ycard});
    if (productDetailResponse.error != null) {
      setState(() {
        _messageDetail = productDetailResponse.error!.message;
        _products = productDetailResponse.productDetails;
      });
      return;
    }
    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _messageDetail = '';
        _products = productDetailResponse.productDetails;
      });
      return;
    }
    // Нужно еще проверить, какие из них куплены и не делать из них кнопки
    setState(() {
      _messageDetail = '';
      _products = productDetailResponse.productDetails;
    });
    return;
  }

  @override
  void initState() {
    getProductDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Wrap(
            direction: Axis.horizontal,
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              _messageDetail != ''
                  ? Text(
                      _messageDetail,
                      style: TextStyles.whiteTextStyle1Small,
                    )
                  : Container(),
              ..._products.map((e) => PurchaseButton(e)).toList(),
              Container(
                width: double.infinity,
                child: ValueListenableBuilder(
                  builder: (BuildContext context, value, Widget? child) {
                    return Text(
                      Hive.box('in_apppurhase')
                          .get('inapploger', defaultValue: 'Пусто'),
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                  valueListenable:
                      Hive.box('in_apppurhase').listenable(keys: ['inapploger']),
                ),
              ),
            ]),
      ),
    );
  }
}

class PurchaseButton extends StatelessWidget {
  final ProductDetails product;
  const PurchaseButton(this.product) : super();

  void buyProduct() {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    IAPConnection.instance.buyConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    String _buttonText = '';
    if (product.id == id_notads) _buttonText = 'Отключить рекламу';
    if (product.id == id_ycard)
      _buttonText = 'Создавать свои наборы и карточки';
    return Container(
      child: ValueListenableBuilder(
        valueListenable:
            Hive.box('in_apppurhase').listenable(keys: [product.id]),
        builder: (BuildContext context, Box<dynamic> value, Widget? child) {
          String messageAboutPurchase = product.rawPrice.toString() + ' руб';
          bool _isAvailable = true;
          if (Hive.box('in_apppurhase').get(product.id, defaultValue: 'not') ==
              'pending') {
            messageAboutPurchase = 'Покупка обрабатывается';
            _isAvailable = false;
          }
          if (Hive.box('in_apppurhase').get(product.id, defaultValue: 'not') ==
              'purchased') {
            messageAboutPurchase =
                'Покупка совершена';
            _isAvailable = false;
          }
          return GestureDetector(
              onTap: _isAvailable ? buyProduct : () {},
              child: Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                // maxWidth: 300,
                constraints: AppConstraints.gestureConstraintsBaseButton3Line,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    //gradient: baseGradient1
                    ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _buttonText,
                      style: TextStyles.whiteTextStyle1Small,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      messageAboutPurchase,
                      style: TextStyles.whiteTextStyle1Small,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
