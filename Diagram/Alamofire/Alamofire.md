# Alamofire <!-- omit in toc -->

- [1. Core](#1-core)
  - [1.1. Session](#11-session)
  - [1.2. Request](#12-request)
- [2. Feature](#2-feature)
  - [2.1. RedirectHandler](#21-redirecthandler)
  - [2.2. Server Trust](#22-server-trust)
  - [2.3. AlamofireExtended](#23-alamofireextended)
    - [2.3.1. `AlamofireExtended` protocol](#231-alamofireextended-protocol)
    - [2.3.2. `AlamofireExtension` struct](#232-alamofireextension-struct)
    - [2.3.3. `AlamofireExtension+URLSessionConfiguration`](#233-alamofireextensionurlsessionconfiguration)
    - [2.3.4. `AlamofireExtension+Bundle`](#234-alamofireextensionbundle)
    - [2.3.5. `AlamofireExtension+SecTrust`](#235-alamofireextensionsectrust)
    - [2.3.6. `AlamofireExtension+SecPolicy`](#236-alamofireextensionsecpolicy)
    - [2.3.7. `AlamofireExtension+SecTrustResultType`](#237-alamofireextensionsectrustresulttype)
    - [2.3.8. `AlamofireExtension+SecCertificate`](#238-alamofireextensionseccertificate)
    - [2.3.9. `AlamofireExtension+Array`](#239-alamofireextensionarray)
    - [2.3.10. `AlamofireExtension+OSStatus`](#2310-alamofireextensionosstatus)

## 1. Core

### 1.1. Session

### 1.2. Request

## 2. Feature

### 2.1. RedirectHandler

### 2.2. Server Trust

`ServerTrustManager`: Responsible for managing the mapping of `ServerTrustEvaluating` values to given hosts.

### 2.3. AlamofireExtended

![Class Diagram](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/Huang-Libo/Notebook/master/Diagram/Alamofire/Alamofire-Extended.puml)

#### 2.3.1. `AlamofireExtended` protocol

The `AlamofireExtended` protocol is used as **namespace** of all `public` extensions.

**Note**: Since `AlamofireExtended` has default implementations, so the *class*/*struct* which conform this protocol can use these default implementation of `af` directly without implement them.

```swift
/// Protocol describing the `af` extension points for Alamofire extended types.
public protocol AlamofireExtended {
    /// Type being extended.
    associatedtype ExtendedType

    /// Static Alamofire extension point.
    static var af: AlamofireExtension<ExtendedType>.Type { get set }
    /// Instance Alamofire extension point.
    var af: AlamofireExtension<ExtendedType> { get set }
}

/// Add default implementation of the protocol functions
extension AlamofireExtended {
    /// Static Alamofire extension point.
    public static var af: AlamofireExtension<Self>.Type {
        get { AlamofireExtension<Self>.self }
        set {}
    }

    /// Instance Alamofire extension point.
    public var af: AlamofireExtension<Self> {
        get { AlamofireExtension(self) }
        set {}
    }
}
```

#### 2.3.2. `AlamofireExtension` struct

All the `public` extension functions in Alamofire are implemented under the `AlamofireExtension` type.

Definition of `AlamofireExtension`:

```swift
/// Type that acts as a generic extension point for all `AlamofireExtended` types.
public struct AlamofireExtension<ExtendedType> {
    /// Stores the type or meta-type of any extended type.
    public private(set) var type: ExtendedType

    /// Create an instance from the provided value.
    ///
    /// - Parameter type: Instance being extended.
    public init(_ type: ExtendedType) {
        self.type = type
    }
}
```

#### 2.3.3. `AlamofireExtension+URLSessionConfiguration`

**Use case 1**, adding extension for `URLSessionConfiguration`:

```swift
extension URLSessionConfiguration: AlamofireExtended {}
extension AlamofireExtension where ExtendedType: URLSessionConfiguration {
    /// Alamofire's default configuration. Same as `URLSessionConfiguration.default` but adds Alamofire default
    /// `Accept-Language`, `Accept-Encoding`, and `User-Agent` headers.
    public static var `default`: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default

        return configuration
    }

    /// `.ephemeral` configuration with Alamofire's default `Accept-Language`, `Accept-Encoding`, and `User-Agent`
    /// headers.
    public static var ephemeral: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.headers = .default

        return configuration
    }
}
```

Call the extension functions:

```swift
URLSessionConfiguration.af.default
```

**Note**: As you can see in this example, extension functions are implemented under the `AlamofireExtension`, `af` returns an instance of `AlamofireExtension`.

Other `public` extensions defined in Alamofire are listed below.

#### 2.3.4. `AlamofireExtension+Bundle`

```swift
extension Bundle: AlamofireExtended {}
extension AlamofireExtension where ExtendedType: Bundle {

    public var certificates: [SecCertificate] {
        ...
    }

    public var publicKeys: [SecKey] {
        ...
    }

    public func paths(forResourcesOfTypes types: [String]) -> [String] {
        ...
    }

}
```

#### 2.3.5. `AlamofireExtension+SecTrust`

```swift
extension SecTrust: AlamofireExtended {}
extension AlamofireExtension where ExtendedType == SecTrust {

    public func evaluate(afterApplying policy: SecPolicy) throws {
        ...
    }

    public func validate(policy: SecPolicy, errorProducer: (_ status: OSStatus, _ result: SecTrustResultType) -> Error) throws {
        ...
    }

    public func apply(policy: SecPolicy) throws -> SecTrust {
        ...
    }

    public func evaluate() throws {
        ...
    }

    public func validate(errorProducer: (_ status: OSStatus, _ result: SecTrustResultType) -> Error) throws {
        ...
    }

    public func setAnchorCertificates(_ certificates: [SecCertificate]) throws {
        ...
    }

    public var publicKeys: [SecKey] {
        ...
    }

    public var certificates: [SecCertificate] {
        ...
    }

    public var certificateData: [Data] {
        ...
    }

    public func performDefaultValidation(forHost host: String) throws {
        ...
    }

    public func performValidation(forHost host: String) throws {
        ...
    }

}
```

#### 2.3.6. `AlamofireExtension+SecPolicy`

```swift
extension SecPolicy: AlamofireExtended {}
extension AlamofireExtension where ExtendedType == SecPolicy {

    public static let `default` = SecPolicyCreateSSL(true, nil)

    public static func hostname(_ hostname: String) -> SecPolicy {
        ...
    }

    public static func revocation(options: RevocationTrustEvaluator.Options) throws -> SecPolicy {
        ...
    }

}
```

#### 2.3.7. `AlamofireExtension+SecTrustResultType`

```swift
extension SecTrustResultType: AlamofireExtended {}
extension AlamofireExtension where ExtendedType == SecTrustResultType {
    public var isSuccess: Bool {
        ...
    }
}
```

#### 2.3.8. `AlamofireExtension+SecCertificate`

```swift
extension SecCertificate: AlamofireExtended {}
extension AlamofireExtension where ExtendedType == SecCertificate {
    public var publicKey: SecKey? {
        ...
    }
}
```

#### 2.3.9. `AlamofireExtension+Array`

```swift
extension Array: AlamofireExtended {}
extension AlamofireExtension where ExtendedType == [SecCertificate] {

    public var data: [Data] {
        ...
    }

    public var publicKeys: [SecKey] {
        ...
    }
}
```

#### 2.3.10. `AlamofireExtension+OSStatus`

```swift
extension OSStatus: AlamofireExtended {}
extension AlamofireExtension where ExtendedType == OSStatus {
    public var isSuccess: Bool { ... }
}
```