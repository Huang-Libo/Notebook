# Keychain Services <!-- omit in toc -->

> Source: [*Apple Documentation: Keychain services*](https://developer.apple.com/documentation/security/keychain_services)  
> Digest Date: *Nov 5, 2023*  

- [1. Overview](#1-overview)
- [2. Keychain items](#2-keychain-items)
- [3. Keychains](#3-keychains)
- [4. Access Control Lists](#4-access-control-lists)

## 1. Overview

> Securely store small chunks of data on behalf of the user.

Computer users often have small secrets that they need to store securely. For example, most people manage numerous online accounts.

- Remembering a complex, unique password for each is impossible, but writing them down is both insecure and tedious.
- Users typically respond to this situation by recycling simple passwords across many accounts, which is also insecure.

The *keychain services* API helps you solve this problem by giving your app a mechanism to store small bits of user data in an **encrypted database** called a **keychain**. When you securely remember the password for them, you free the user to choose a complicated one.

The keychain is not limited to *passwords*, as shown in *Figure 1*.

- You can store other secrets that the user explicitly cares about, such as *credit card information* or even *short notes*.
- You can also store items that the user needs but may not be aware of. For example, the *cryptographic keys* and *certificates* that you manage with [Certificate, Key, and Trust Services](https://developer.apple.com/documentation/security/certificate_key_and_trust_services) enable the user to engage in secure communications and to establish trust with other users and devices. You use the keychain to store these items as well.

**Figure 1** Securing the user's secrets in a keychain

<img src="../../media/iOS/AppleDocumentation/keychain_services.png" width="60%"/>

## 2. Keychain items

> Embed confidential information in items that you store in a keychain.

When you want to store a secret such as a *password* or *cryptographic key*, you package it as a **keychain item**. Along with the data itself, you provide a set of publicly visible attributes both to control the item’s accessibility and to make it searchable. As shown in *Figure 1*, keychain services handles data encryption and storage (including data attributes) in a keychain, which is an encrypted database stored on disk. Later, authorized processes use keychain services to find the item and decrypt its data.

**Figure 1** Putting data and attributes into a keychain

## 3. Keychains

> Create and manage entire keychains in macOS.

In **iOS**, apps have access to a single keychain (which logically encompasses the iCloud keychain). This keychain is automatically unlocked when the user unlocks the device and then locked when the device is locked. **An app can access only its own keychain items, or those shared with a group to which the app belongs.** It can't manage the keychain container itself.

In **macOS**, however, the system supports an arbitrary number of keychains. You typically rely on the user to manage these with the "*Keychain Access*" App and work implicitly with the default keychain, much as you would in iOS. Nevertheless, the keychain services API does provide functions that you can use to manipulate keychains directly. For example, you can create and manage a keychain that is private to your app. On the other hand, robust access control mechanisms typically make this unnecessary for anything other than an app trying to replicate the keychain access utility.

## 4. Access Control Lists
