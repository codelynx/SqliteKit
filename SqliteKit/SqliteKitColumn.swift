//
//  SqliteKitColumn.swift
//  SqliteKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2018 Electricwoods LLC, Kaz Yoshikawa.
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


public class SqliteKitColumn {

	public let table: SqliteKitTable
	let cid: Int?
	public let name: String?
	public let type: String?
	let notnull: Int?
	let pk: Int?

	public init(table: SqliteKitTable, attributes: [String: Any]) {
		self.table = table
		self.cid = (attributes["cid"] as AnyObject).intValue
		self.name = attributes["name"] as? String
		self.type = attributes["type"] as? String
		self.notnull = (attributes["notnull"] as AnyObject).intValue
		self.pk = (attributes["pk"] as AnyObject).intValue
	}
}
