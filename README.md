# SqliteKit

SqliteKit is a piece of code for accessing Sqlite database from Cocoa.

Written by Kaz Yoshikawa.
Based on 

- Version 0.1

### Status
- Under Development

Some features are functioning but not ready too use.

### Swift Version
- Swift 3.0


## Code Usage


```.swift
let filepath = ...
let db = SqliteKitDatabase(file: filepath, readonly: false)
let _ = db.executeQuery("CREATE TABLE IF NOT EXISTS product (id INTEGER AUTO INCREMENT, name VARCHAR(32), price DOUBLE);")
let _ = db.executeQuery("INSERT INTO product('name', 'price') VALUES('Apple', '100');")
let results = db.executeQuery("SELECT * FROM product;")
for row in results {
	let name = row["name"] as? String
	let price = row["price"] as? Double
	print("row: name=\(name), price=\(price)")
}	
```

### Creating a database

```
let db = SqliteKitDatabase(file: filepath, readonly: false)
```

### Creating a query

```
let query = db.query("SELECT * FROM product;")
```

### Fetching rows

```
for row in query.execute() {
	let name = row["name"] as? String
	let price = row["price"] as? Double
	// ...
}
```


## TO DO LIST
- More Test
- Better BLOB support
- More data type support

## License
The MIT License (MIT)

