//
//  LEPDFParser.swift
//  LEPDFParser
//
//  Created by Ludvig Eriksson on 2018-05-03.
//  Copyright © 2018 Ludvig Eriksson. All rights reserved.
//

import PDFKit

public extension PDFPage {
    public var dicitionary: [String: Any]? {
        guard let document = self.document else { return nil }
        let pageNumber = document.index(for: self)
        guard let documentRef = document.documentRef,
            let page = documentRef.page(at: pageNumber + 1),
            let dict = page.dictionary else { return nil }
        var results = NSMutableDictionary()
        CGPDFDictionaryApplyFunction(dict, dumpDictionary, &results)
        return results as? [String: Any]
    }
}

import CoreGraphics

func dump(object: CGPDFObjectRef) -> Any? {
    let type = CGPDFObjectGetType(object)
    switch type {
    case .boolean:
        var bool = CGPDFBoolean()
        if CGPDFObjectGetValue(object, .boolean, &bool) {
            return NSNumber(value: bool).boolValue
        }
    case .integer:
        var int = CGPDFInteger()
        if CGPDFObjectGetValue(object, .integer, &int) {
            return Int(int)
        }
    case .real:
        var real = CGPDFReal()
        if CGPDFObjectGetValue(object, .real, &real) {
            return Double(real)
        }
    case .name:
        var name: UnsafePointer<Int8>? = nil
        if CGPDFObjectGetValue(object, .name, &name) {
            guard let name = name, let string = String(validatingUTF8: name) else { break }
            return string
        }
    case .string:
        var string: CGPDFStringRef? = nil
        if CGPDFObjectGetValue(object, .string, &string) {
            guard let string = string, let cfstr = CGPDFStringCopyTextString(string) else { break }
            return cfstr as String
        }
    case .array:
        var array: CGPDFArrayRef? = nil
        if CGPDFObjectGetValue(object, .array, &array) {
            guard let array = array else { break }
            var entries = [Any]()
            let count = CGPDFArrayGetCount(array)
            for i in 0..<count {
                var entry: CGPDFObjectRef? = nil
                CGPDFArrayGetObject(array, i, &entry)
                if let entry = entry, let value = dump(object: entry) {
                    entries.append(value)
                }
            }
            return entries
        }
    case .dictionary:
        var dictionary: CGPDFDictionaryRef? = nil
        if CGPDFObjectGetValue(object, .dictionary, &dictionary) {
            guard let dictionary = dictionary else { break }
            var results = NSMutableDictionary()
            CGPDFDictionaryApplyFunction(dictionary, dumpDictionary, &results)
            return results
        }
    case .null:
        return NSNull()
    case .stream:
        var objectStream: CGPDFStreamRef? = nil
        if CGPDFObjectGetValue(object, .stream, &objectStream) {
            var format: CGPDFDataFormat = .raw
            guard let objectStream = objectStream,
                let data = CGPDFStreamCopyData(objectStream, &format) as Data? else { break }
            return data
        }
    }
    return nil
}

func dumpDictionary(key: UnsafePointer<Int8>, object: OpaquePointer, info: UnsafeMutableRawPointer?) {
    guard let results = info?.load(as: NSMutableDictionary.self),
        let key = String(validatingUTF8: key),
        key.lowercased() != "parent" else { return }
    results.setValue(dump(object: object), forKey: key)
}
