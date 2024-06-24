import '../../utilities/date_time_extensions.dart';
import '../metadata.dart';

class TFToolMetadata extends Metadata {

  String? type;
  String? brand;
  String? modelNumber;
  String? serialNumber;
  double? price;
  DateTime? purchaseDate;
  DateTime? warrantyExpirationDate;

  TFToolMetadata({required super.name, required super.createdAt, required super.lastModified});

  factory TFToolMetadata.name(String? name) {
    DateTime now = DateTime.now();
    return TFToolMetadata(name: name, createdAt: now, lastModified: now);
  }

  factory TFToolMetadata.empty() {
    return TFToolMetadata.name(null);
  }

  TFToolMetadata.fromJson(super.json) :
    type = json['type'],
    brand = json['brand'],
    modelNumber = json['modelNumber'],
    serialNumber = json['serialNumber'],
    price = json['price'],
    purchaseDate = DateTimeExtensions.safeParse(json['purchaseDate']),
    warrantyExpirationDate = DateTimeExtensions.safeParse(json['warrantyExpirationDate']),
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
