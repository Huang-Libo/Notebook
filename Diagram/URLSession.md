# URLSession <!-- omit in toc -->

- [1. Introduction](#1-introduction)
- [2. URLSessionConfiguration](#2-urlsessionconfiguration)
  - [2.1. Types of Session Configurations](#21-types-of-session-configurations)
- [3. URLSessionDelegate](#3-urlsessiondelegate)
- [4. NSURLRequest.CachePolicy](#4-nsurlrequestcachepolicy)
  - [4.1. useProtocolCachePolicy](#41-useprotocolcachepolicy)
- [5. Reference](#5-reference)

## 1. Introduction

`NSURLSession` instances are **thread-safe**.

The default `NSURLSession` uses a system provided `delegate`.

An `NSURLSession` creates `NSURLSessionTask` objects which represent the
action of a resource being loaded.

`NSURLSessionTask` objects are always created in a **suspended** state and must be sent the `resume()` message before they will execute.

Subclasses of `NSURLSessionTask` are used to syntactically differentiate between *data* and *file downloads*.

- An `NSURLSessionDataTask` receives the resource as a series of calls to the `URLSession:dataTask:didReceiveData:` delegate method. This is type of task most commonly associated with retrieving objects for immediate parsing by the consumer.
- An `NSURLSessionUploadTask` differs from an `NSURLSessionDataTask` in how its instance is constructed. Upload tasks are explicitly created by **referencing** a *file* or *data object* to upload, or by utilizing the `URLSession:task:needNewBodyStream:` delegate message to supply an upload body.
- An `NSURLSessionDownloadTask` will directly write the response data to a **temporary** file. When completed, the `delegate` is sent `URLSession:downloadTask:didFinishDownloadingToURL:` and given an opportunity to move this file to a **permanent** location in its sandboxed container, or to otherwise read the file. If canceled, an `NSURLSessionDownloadTask` can produce a data blob that can be used to `resume` a download at a later time.

Beginning with *iOS 9* and *Mac OS X 10.11*, `NSURLSessionStream` is available as a task type.  This allows for **direct TCP/IP connection** to a given host and port with optional secure handshaking and navigation of proxies. *Data tasks* may also be **upgraded** to a `NSURLSessionStream` task via the HTTP `Upgrade:` header and appropriate use of the pipelining option of `NSURLSessionConfiguration`.  See *RFC 2817* and *RFC 6455* for information about the `Upgrade:` header, and comments below on turning data tasks into stream tasks.

An `NSURLSessionWebSocketTask` is a task that allows clients to connect to servers supporting *WebSocket*. The task will perform the HTTP handshake to **upgrade** the connection and once the WebSocket handshake is successful, the client can read and write messages that will be framed using the WebSocket protocol by the framework.

- *DataTask objects* receive the payload through **zero** or **more** delegate messages;
- *UploadTask objects* receive **periodic** progress updates but do *not* return a body;
- *DownloadTask objects* represent an active download to disk. They can provide *resume data* when canceled;
- *StreamTask objects* may be used to create `NSInput` and `NSOutputStreams`, or used directly in reading and writing;
- *WebSocket objects* perform a WebSocket handshake with the server and can be used to send and receive WebSocket messages.

## 2. URLSessionConfiguration

An `URLSessionConfiguration` object defines the behavior and policies to use when uploading and downloading data using an URLSession object. When uploading or downloading data, creating a configuration object is always the first step you must take. You use this object to configure the timeout values, caching policies, connection requirements, and other types of information that you intend to use with your URLSession object.

It is important to configure your `URLSessionConfiguration` object appropriately before using it to initialize a session object. Session objects **make a copy** of the configuration settings you provide and use those settings to configure the session.

- Once configured, the session object **ignores** any changes you make to the `URLSessionConfiguration` object.
- If you need to modify your transfer policies, you must update the session configuration object and use it to **create a new URLSession object**.

> **Note**:
> In some cases, the policies defined in this configuration may be *overridden* by policies specified by an `NSURLRequest` object provided for a task. Any policy specified on the request object is respected unless the session’s policy is more restrictive. For example, if the session configuration specifies that cellular networking should not be allowed, the `NSURLRequest` object cannot request cellular networking.

### 2.1. Types of Session Configurations

The behavior and capabilities of a URL session are largely determined by the kind of configuration used to create the session.

The *singleton shared session* (which **has no configuration object**) is for basic requests. It’s not as customizable as sessions that you create, but it serves as a good starting point if you have very limited requirements. You access this session by calling the `shared` class method (which is defined in `URLSession`).

- *Default sessions* behave much like the *shared session* (unless you customize them further), but let you obtain data incrementally using a delegate. You can create a default session configuration by calling the `default` method on the `URLSessionConfiguration` class.
- *Ephemeral sessions* are similar to default sessions, but they **don’t write caches, cookies, or credentials** to disk. You can create an ephemeral session configuration by calling the ephemeral method on the `URLSessionConfiguration` class.
- *Background sessions* let you **perform uploads and downloads of content in the background while your app isn’t running**. You can create a background session configuration by calling the `backgroundSessionConfiguration(_:)` method on the `URLSessionConfiguration` class.

## 3. URLSessionDelegate

A protocol that defines methods that URL session instances call on their delegates to handle **session-level events**, like session life cycle changes.

In addition to the methods defined in this protocol, most delegates should also implement some or all of the methods in the `URLSessionTaskDelegate`, `URLSessionDataDelegate`, and `URLSessionDownloadDelegate` protocols to handle **task-level events**. These include events like the beginning and end of individual tasks, and periodic progress updates from data or download tasks.

**Note**: Your `URLSession` object doesn’t need to have a delegate. If no delegate is assigned, a *system-provided* delegate is used, and you must provide a completion callback to obtain the data.

## 4. NSURLRequest.CachePolicy

Use the caching logic defined in the **protocol implementation**, if any, for a particular URL load request.

### 4.1. useProtocolCachePolicy

This is the *default* policy for URL load requests.

For the HTTP and HTTPS protocols, `NSURLRequest.CachePolicy.useProtocolCachePolicy` performs the following behavior:

1. If a cached response does *not* exist for the request, the *URL loading system* fetches the data from the originating source.
2. Otherwise, if the cached response does not indicate that it must be revalidated every time, and if the cached response is not stale (past its expiration date), the *URL loading system* returns the cached response.
3. If the cached response is stale or requires revalidation, the *URL loading system* makes a `HEAD` request to the originating source to see if the resource has changed. If so, the *URL loading system* fetches the data from the originating source. Otherwise, it returns the cached response.

![useProtocolCachePolicy](../media/iOS/AppleDocumentation/useProtocolCachePolicy.png)

## 5. Reference

- [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system)
