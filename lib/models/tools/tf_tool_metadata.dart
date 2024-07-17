import '../../utilities/date_time_extensions_util.dart';
import '../metadata.dart';

class TfToolMetadata extends Metadata {

  String? type;
  String? brand;
  String? modelNumber;
  String? serialNumber;
  double? price;
  DateTime? purchaseDate;
  DateTime? warrantyExpirationDate;

  TfToolMetadata({required super.name, required super.createdAt, required super.lastModified});

  factory TfToolMetadata.name(String? name) {
    DateTime now = DateTime.now();
    return TfToolMetadata(name: name, createdAt: now, lastModified: now);
  }

  factory TfToolMetadata.empty() {
    return TfToolMetadata.name(null);
  }

  TfToolMetadata.fromJson(super.json) :
    type = json['type'],
    brand = json['brand'],
    modelNumber = json['modelNumber'],
    serialNumber = json['serialNumber'],
    price = json['price'],
    purchaseDate = DateTimeExtensionsUtil.safeParse(json['purchaseDate']),
    warrantyExpirationDate = DateTimeExtensionsUtil.safeParse(json['warrantyExpirationDate']),
    super.fromJson();

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'type': type,
    'brand': brand,
    'modelNumber': modelNumber,
    'serialNumber': serialNumber,
    'price': price,
    'purchaseDate': purchaseDate?.toIso8601String(),
    'warrantyExpirationDate': warrantyExpirationDate?.toIso8601String()
  };

}
