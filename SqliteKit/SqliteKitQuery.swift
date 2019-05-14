//
//	SqliteKitQuery.swift
//	SqliteKit
//
//	The MIT License (MIT)
//
//	Copyright (c) 2018 Electricwoods LLC, Kaz Yoshikawa.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy 
//	of this software and associated documentation files (the "Software"), to deal 
//	in the Software without restriction, including without limitation the rights 
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//	copies of the Software, and to permit persons to whom the Software is 
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

import Foundation
import sqlite


public class SqliteKitQuery: CustomStringConvertible {

	fileprivate var _database : SqliteKitDatabase
	fileprivate var _query : String
	fileprivate var _stmt : OpaquePointer? = nil

	public init(query: String, database: SqliteKitDatabase) {
		_database = database
		_query = query
		var tail : UnsafePointer<Int8>? = nil
		let status = sqlite3_prepare_v2(database.sqlite, query, -1, &_stmt, &tail)
		SqliteKitReportError(status)
	}

	deinit {
		if _stmt != nil {
			sqlite3_finalize(_stmt)
			_stmt = nil
		}
	}
	
	public func bind(_ args: AnyObject...) {
		self.bind(args.map { $0 })
	}

	public func bind(_ args: [AnyObject]) {

		sqlite3_reset(_stmt);
		sqlite3_clear_bindings(_stmt);
		var index : Int32 = 1

		for arg : AnyObject in args {
			switch arg {
			case let text as String:
				let _ = sqlite3_bind_text(_stmt, index, text, -1, nil)
			case let value as Double:
				let _ = sqlite3_bind_double(_stmt, index, value)
			case let value as Int:
				let _ = sqlite3_bind_int64(_stmt, index, sqlite3_int64(value))
			case let data as Data:
				data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
					if let bytes = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) {
						sqlite3_bind_blob(_stmt, index, bytes, Int32(data.count), nil)
					}
				}
			default:
				break
			}
			index += 1
		}
	}

	public var database : SqliteKitDatabase {
		return _database
	}

	var statement : OpaquePointer {
		assert(_stmt != nil)
		return _stmt!
	}
	
	public func execute() -> SqliteKitResult {
		return SqliteKitResult(query: self)
	}
	
	public var description: String {
		return "SqliteKit: " + _query
	}
}
