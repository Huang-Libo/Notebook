# Using Alamofire

- [Using Alamofire](#using-alamofire)
  - [Introduction](#introduction)
    - [Aside: The `AF` Namespace and Reference](#aside-the-af-namespace-and-reference)

## Introduction

Alamofire provides an elegant and composable interface to HTTP network requests. It does not implement its own HTTP networking functionality. Instead it builds on top of Apple's [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system/) provided by the Foundation framework. At the core of the system is [`URLSession`](https://developer.apple.com/documentation/foundation/urlsession) and the [`URLSessionTask`](https://developer.apple.com/documentation/foundation/urlsessiontask) subclasses.

Alamofire wraps these APIs, and many others, in an easier to use interface and provides a variety of functionality necessary for modern application development using HTTP networking.

However, it's important to know where many of Alamofire's core behaviors come from, so familiarity with the *URL Loading System* is important.

Ultimately, the networking features of Alamofire are limited by the capabilities of that system, and the behaviors and best practices should always be remembered and observed.

Additionally, networking in Alamofire (and the *URL Loading System* in general) is done *asynchronously*. Asynchronous programming may be a source of frustration to programmers unfamiliar with the concept, but there are [very good reasons](https://developer.apple.com/library/ios/qa/qa1693/_index.html) for doing it this way.

### Aside: The `AF` Namespace and Reference

Previous versions of Alamofire's documentation used examples like `Alamofire.request()`. This API, while it appeared to require the `Alamofire` prefix, in fact worked fine without it. The `request` method and other functions were available globally in any file with `import Alamofire`. Starting in Alamofire 5, this functionality has been removed and instead the `AF` global is a reference to `Session.default`. This allows Alamofire to offer the same convenience functionality while not having to pollute the global namespace every time Alamofire is used and not having to duplicate the `Session` API globally. Similarly, types extended by Alamofire will use an `af` property extension to separate the functionality Alamofire adds from other extensions.
