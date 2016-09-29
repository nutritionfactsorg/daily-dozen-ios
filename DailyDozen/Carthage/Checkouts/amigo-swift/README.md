# Amigo
A SQLite ORM for Swift 2.1+ powered by FMDB

Docs in progress are here:

http://amigo.readthedocs.org/en/latest/



## Carthage

FMDB (https://github.com/ccgus/fmdb),
as of v 2.6 FMDB, supports Carthage.

Drop this into your `Cartfile`:

```
github "blitzagency/amigo-swift" ~> 0.3.0
```


## Fire it up

Lets create a schema:


```swift

import Amigo
import CoreData

// the first arg can be ":memory:" for an in-memory
// database, or it can be the absolute path to your
// sqlite database.
//
// echo : Boolean
// true prints out the SQL statements with params
// the default value of false does nothing.

let mom = NSManagedObjectModel(contentsOfURL: url)!

// specifying 'echo: true' will have amigo print out
// all of the SQL commands it's generating.
let engine = SQLiteEngineFactory(":memory:", echo: true)
amigo = Amigo(mom, factory: engine)
amigo.createAll()
```

Yup, Amigo can turn NSEntityDescriptions along with their relationships
into your tables for you.

Read more about it here:

http://amigo.readthedocs.org/en/latest/models/mom.html

There are only a couple things to know.

1. Unlike CoreData, you need to specify your primary key field. This could
totally be automated for you, we havent decided if we like that or not yet.
You do this by picking your attribute in your entity and adding the following
to the User Info: `primaryKey` `true`. Crack open the `App.xcdatamodeld`
and look at any of the entities for more info.

2. You need to be sure the Class you assign to the entity in your `xcdatamodeld`
is a subclass of `AmigoModel`

You do not have to use a `ManagedObjectModel` either you can just define your
mappings yourself as follows:

Read more about it here:

http://amigo.readthedocs.org/en/latest/models/orm_models.html

```swift
import Amigo

class Dog: AmigoModel{
    dynamic var id: Int = 0
    dynamic var label: String!
}

let dog = ORMModel(Dog.self,
    Column("id", type: Int.self, primaryKey: true)
    Column("label", type: String.self)
    Index("dog_label_idx", "label")
)

// you could achieve the same mapping this way:

let dog = ORMModel(Dog.self,
    Column("id", type: Int.self, primaryKey: true)
    Column("label", type: String.self, indexed: true)
)

// now initialize Amigo
// specifying 'echo: true' will have amigo print out
// all of the SQL commands it's generating.
let engine = SQLiteEngineFactory(":memory:", echo: true)
amigo = Amigo([dog], factory: engine)
amigo.createAll()
```

Amigo Supports `ForeignKeys`, `OneToMany` and `ManyToMany` relationships.
More on that later.

## Querying

Using our mapping above, lets do some simple querying:

You can also read more about this here:

http://amigo.readthedocs.org/en/latest/querying/index.html


```swift
import Amigo

class Dog: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var label: String!
}

let dog = ORMModel(Dog.self,
    Column("id", type: Int.self, primaryKey: true)
    Column("label", type: String.self)
)

// specifying 'echo: true' will have amigo print out
// all of the SQL commands it's generating.
let engine = SQLiteEngineFactory(":memory:", echo: true)
amigo = Amigo([dog], factory: engine)
amigo.createAll()

// first lets add a dog

let session = amigo.session
let d1 = Dog()
d1.label = "Lucy"

session.add(d1)

// now lets query:
let results = session.query(Dog).all()
print(results.count)
```













