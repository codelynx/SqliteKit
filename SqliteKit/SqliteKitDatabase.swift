//
//	SqliteKitDatabase.swift
//	SqliteKit
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


enum ZSqliteError: Error, CustomStringConvertible {

	case status(Int32)
	
	var description: String {
		switch self {
		case .status(let code):
			switch code {
			case SQLITE_OK: return "SQLITE_OK"
			case SQLITE_ROW: return "SQLITE_ROW"
			case SQLITE_DONE: return "SQLITE_DONE"

			case SQLITE_ERROR: return "SQLITE_ERROR: SQL error or missing database"
			case SQLITE_INTERNAL: return "SQLITE_INTERNAL: Internal logic error in SQLite"
			case SQLITE_PERM: return "SQLITE_PERM: Access permission denied"
			case SQLITE_ABORT: return "SQLITE_ABORT: Callback routine requested an abort"
			case SQLITE_BUSY: return "SQLITE_BUSY: The database file is locked"
			case SQLITE_LOCKED: return "SQLITE_LOCKED: A table in the database is locked"
			case SQLITE_NOMEM: return "SQLITE_NOMEM: A malloc() failed"
			case SQLITE_READONLY: return "SQLITE_READONLY: Attempt to write a readonly database"
			case SQLITE_INTERRUPT: return "SQLITE_INTERRUPT: Operation terminated by sqlite3_interrupt()"
			case SQLITE_IOERR: return "SQLITE_IOERR: Some kind of disk I/O error occurred"
			case SQLITE_CORRUPT: return "SQLITE_CORRUPT: The database disk image is malformed"
			case SQLITE_NOTFOUND: return "SQLITE_NOTFOUND: Unknown opcode in sqlite3_file_control()"
			case SQLITE_FULL: return "SQLITE_FULL: Insertion failed because database is full"
			case SQLITE_CANTOPEN: return "SQLITE_CANTOPEN: Unable to open the database file"
			case SQLITE_PROTOCOL: return "SQLITE_PROTOCOL: Database lock protocol error"
			case SQLITE_EMPTY: return "SQLITE_EMPTY: Database is empty"
			case SQLITE_SCHEMA: return "SQLITE_SCHEMA: The database schema changed"
			case SQLITE_TOOBIG: return "SQLITE_TOOBIG: String or BLOB exceeds size limit"
			case SQLITE_CONSTRAINT: return "SQLITE_CONSTRAINT: Abort due to constraint violation"
			case SQLITE_MISMATCH: return "SQLITE_MISMATCH: Data type mismatch"
			case SQLITE_MISUSE: return "SQLITE_MISUSE: Library used incorrectly"
			case SQLITE_NOLFS: return "SQLITE_NOLFS: Uses OS features not supported on host"
			case SQLITE_AUTH: return "SQLITE_AUTH: Authorization denied"
			case SQLITE_FORMAT: return "SQLITE_FORMAT: Auxiliary database format error"
			case SQLITE_RANGE: return "SQLITE_RANGE: 2nd parameter to sqlite3_bind out of range"
			case SQLITE_NOTADB: return "SQLITE_NOTADB: File opened that is not a database file"
			case SQLITE_NOTICE: return "SQLITE_NOTICE: Notifications from sqlite3_log()"
			case SQLITE_WARNING: return "SQLITE_WARNING: Warnings from sqlite3_log()"
			default: return "Unknown status(\(code))"
			}
		}
	}

}


func SqliteKitReportIfError(_ status: Int32, _ query: SqliteKitQuery? = nil) {
	switch status {
	case SQLITE_OK, SQLITE_ROW, SQLITE_DONE: break
    default:
		NSLog("sqlite3: \(ZSqliteError.status(status).description)")
		NSLog("\(query.debugDescription)")
	}
}


public class SqliteKitDatabase {

	var file : String? = nil
	fileprivate var _sqlite: OpaquePointer? = nil
	fileprivate var _tableNames : [String]?
	
	public init?(file: String, readonly: Bool) {
		let filepath = FileManager.default.fileSystemRepresentation(withPath: file)
		let flags = readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
		let status = sqlite3_open_v2(filepath, &_sqlite, flags, nil)
		if status != SQLITE_OK {
			return nil
		}
	}

	deinit {
		sqlite3_close(_sqlite)
		_sqlite = nil
	}

	var sqlite : OpaquePointer {
		return _sqlite!
	}

	var dictionary = [String: SqliteKitTable]()
	
	public func query(_ string: String) -> SqliteKitQuery {
		return SqliteKitQuery(query: string, database: self)
	}
	
	public func executeQuery(_ string: String) -> SqliteKitResult {
		let query = SqliteKitQuery(query: string, database: self)
		return query.execute()
	}

	public func tableNames() -> [String] {
		var tables = [String]()
		let query = self.query("SELECT name FROM sqlite_master WHERE type = \"table\";")
		let result = query.execute()
		for row in result {
			let name = row["name"] as! String
			tables.append(name)
		}
		return tables
	}

	public func tableNamed(_ name: String) -> SqliteKitTable {
		var table = self.dictionary[name]
		if table == nil {
			if self.tableNames().contains(name) {
				table = SqliteKitTable(name: name, database: self)
				self.dictionary[name] = table
			}
		}
		return table!
	}
	
	func tables() -> [SqliteKitTable] {
		var tables = [SqliteKitTable]()
		for object in self.tableNames() {
			let name = object as String
			let table = self.tableNamed(name)
			tables.append(table)
		}
		return tables
	}
	
	public var foreignKeys : Bool {
		get {
			let result = self.query("PRAGMA foreign_keys;").execute()
			let row = result.nextRow()
			let value = row!["foreign_keys"] as? Bool
			assert(value != nil)
			return value!
		}
		set {
			let state = newValue ? "ON" : "OFF"
			let result = self.query("PRAGMA foreign_keys = \(state);").execute()
			SqliteKitReportIfError(result.status)
		}
	}

}
