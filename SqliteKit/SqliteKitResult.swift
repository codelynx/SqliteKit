//
//  SqliteKitResult.swift
//  SqliteKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Electricwoods LLC, Kaz Yoshikawa.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy 
//  of this software and associated documentation files (the "Software"), to deal 
//  in the Software without restriction, including without limitation the rights 
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//  copies of the Software, and to permit persons to whom the Software is 
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import sqlite


public class SqliteKitResult: Sequence, CustomStringConvertible {

	var query: SqliteKitQuery
	var _columns: [String]?
	var status: Int32

	public init (query: SqliteKitQuery) {
		self.query = query
		self.status = sqlite3_step(query.statement)
		SqliteKitReportIfError(status, query)
	}

	var statement : OpaquePointer {
		return query.statement
	}

	internal func execute() -> Int {
		let status = sqlite3_step(self.statement)
		return Int(status)
	}

	public var lastInsertRowID : Int64 {
		return sqlite3_last_insert_rowid(query.database.sqlite)
	}

	public var columns : [String] {
		if _columns == nil {
			let statement = self.statement
			var columns = [String]()
			let numberOfColumns = sqlite3_column_count(statement)
			for index in 0...numberOfColumns {
				let buffer = sqlite3_column_name(statement, Int32(index))
				let text = String(utf8String: unsafeBitCast(buffer, to: UnsafePointer<Int8>.self)) ?? ""
				columns.append(text)
			}
			_columns = columns
		}
		return _columns!
	}

	public func nextRow() -> [String: Any]? {
		if self.status == SQLITE_ROW {
			var dictionary = [String: Any]()
			let statement = self.statement
			let numberOfColumns = sqlite3_column_count(statement)
			for index in 0 ..< numberOfColumns {
				if let namebuffer = sqlite3_column_name(statement, Int32(index)),
				   let name = String(utf8String: namebuffer) {

					switch (sqlite3_column_type(statement, index)) {
					case SQLITE_INTEGER:
						let value = sqlite3_column_int64(statement, index)
						dictionary[name] = Int(value)
						break
					case SQLITE_FLOAT:
						let value = sqlite3_column_double(statement, index)
						dictionary[name] = value
						break
					case SQLITE_TEXT:
						let textbuffer: UnsafePointer<UInt8> = sqlite3_column_text(statement, index)
						let text = String(utf8String: unsafeBitCast(textbuffer, to: UnsafePointer<Int8>.self))
						dictionary[name] = text
						break
					case SQLITE_BLOB:
						let length = sqlite3_column_bytes(statement, index)
						let buffer = sqlite3_column_blob(statement, index)
						let data = NSData(bytes: buffer, length: Int(length))
						dictionary[name] = data
						break
					case SQLITE_NULL:
						dictionary[name] = NSNull()
						break
					default:
						break
					}
				}
			}
			self.status = sqlite3_step(statement)
			return dictionary
		}
		return nil
	}

	public func makeIterator() -> AnyIterator<[String: Any]> {
		return AnyIterator {
			return self.nextRow()
		}
	}
	
	public var description: String {
		let description = self.query.description
		NSLog(description)
		return description
	}

}
