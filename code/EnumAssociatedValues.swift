
/// 含关联值的枚举.

/// 条形码
///
/// - upc: 一维条形码, 关联值的内容是包含四个整数的元组
/// - qrCode: 二维码, 关联值的内容是一个字符串
enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}

// 此时 Barcode.upc 枚举的关联值是元组 (8, 85909, 51226, 3)
var productBarcode = Barcode.upc(8, 85909, 51226, 3)

// 此时 .qrCode 枚举的关联值是字符串 "ABCDEFGHIJKLMNOP
productBarcode = .qrCode("ABCDEFGHIJKLMNOP")


// 关联值可以作为 switch 语句的一部分被取出
switch productBarcode {
case .upc(let numberSystem, let manufacturer, let product, let check):
    print("UPC: \(numberSystem), \(manufacturer), \(product), \(check).")
case .qrCode(let productCode):
    print("QR code: \(productCode).")
}
// Prints "QR code: ABCDEFGHIJKLMNOP."


// 如果关联值都是常量或都是变量, 则可以把 let 或 var 统一放在枚举类型前面.
switch productBarcode {
case let .upc(numberSystem, manufacturer, product, check):
    print("UPC: \(numberSystem), \(manufacturer), \(product), \(check).")
case let .qrCode(productCode):
    print("QR code: \(productCode).")
}
// Prints "QR code: ABCDEFGHIJKLMNOP."
