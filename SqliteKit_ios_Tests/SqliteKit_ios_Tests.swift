//
//	SqliteKit_ios_Tests.swift
//	SqliteKit_ios_Tests
//
//	Created by Kaz Yoshikawa on 9/19/16.
//
//

import Foundation
import XCTest
import SqliteKit_ios

class SqliteKit_ios_Tests: XCTestCase {
	
	class func file(named: String) -> String {
		let filename = (named as NSString).appendingPathExtension("sqlite")!
		let filepath = (NSTemporaryDirectory() as NSString).appendingPathComponent(filename)
		if !FileManager.default.fileExists(atPath: filepath) {
			FileManager.default.createFile(atPath: filepath, contents: nil, attributes: nil)
		}
		return filepath
	}
	
	class func database(name: String) -> SqliteKitDatabase {
		let filepath = self.file(named: "test1")
		guard let database = SqliteKitDatabase(file: filepath, readonly: false) else { fatalError("failed creating SqliteKitDatabase") }
		return database
	}
	
	lazy var database1: SqliteKitDatabase = { return SqliteKit_ios_Tests.database(name: "test1") }()
	lazy var database2: SqliteKitDatabase = { return SqliteKit_ios_Tests.database(name: "test2") }()
	
	
	
	
	override func setUp() {
		super.setUp()
		let directory = NSTemporaryDirectory()
		for item in try! FileManager.default.contentsOfDirectory(atPath: directory) {
			let fiepath = (directory as NSString).appendingPathComponent(item)
			try! FileManager.default.removeItem(atPath: fiepath)
		}
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testExample() {
		let db = self.database1
		let _ = db.executeQuery("CREATE TABLE IF NOT EXISTS product (pid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price DOUBLE);")
		let _ = db.executeQuery("INSERT INTO product('name', 'price') VALUES('Apple', '100');")
		let results = db.executeQuery("SELECT * FROM product;")
		for row in results {
			let name = row["name"] as? String
			let price = row["price"] as? Double
			XCTAssert(name == "Apple")
			XCTAssert(price == 100.0)
		}
	}
	
	func testLastInsertRowID() {
		let db = self.database2
		let _ = db.executeQuery("CREATE TABLE IF NOT EXISTS product (pid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price DOUBLE);")
		let rowid = db.executeQuery("INSERT INTO product('name', 'price') VALUES('Apple', '100');").lastInsertRowID
		let results = db.executeQuery("SELECT * FROM product where rowid == \(rowid);")
		if let row = results.nextRow() {
			let name = row["name"] as? String
			let value = row["price"] as? Double
			XCTAssert(name == "Apple")
			XCTAssert(value == 100.0)
		}
		else { XCTAssert(false) }
		XCTAssert(results.nextRow() == nil)
	}
	
	
	func testPerformanceExample() {
		self.measure {
		}
	}
	
}
