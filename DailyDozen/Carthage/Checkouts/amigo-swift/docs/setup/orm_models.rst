ORM Model Mapping
===================================


Amigo can parse a :code:`NSManagedObjectModel` but all it's doing is
converting the :code:`NSEntityDescriptions` into :code:`ORMModel`
instances. Lets take a look at how we do that.


.. important::
   When performing a model mapping your data models **MUST**
   inherit from :code:`Amigo.AmigoModel`


.. code-block:: swift

    import Amigo

    class Dog: AmigoModel{
        dynamic var id: NSNumber!
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


Column Options
------------------------

Columns can be initialized with the following options (default values presented):

.. code-block:: swift

    type: // See Column Types below
    primaryKey: Bool = false
    indexed: Bool = false
    optional: Bool = true
    unique: Bool = false


Column Types
------------------------

Your avavilable options for `Column` types are as follows:

.. code-block:: swift

    NSString
    String
    Int16
    Int32
    Int64
    Int
    NSDate
    NSData
    NSDecimalNumber
    Double
    Float
    Bool

These effectvely map to the following :code:`NSAttributeType`
found in :code:`CoreData` which you may also use for your column initialization:

.. code-block:: swift

    NSAttributeType.StringAttributeType
    NSAttributeType.Integer16AttributeType
    NSAttributeType.Integer32AttributeType
    NSAttributeType.Integer64AttributeType
    NSAttributeType.DateAttributeType
    NSAttributeType.BinaryDataAttributeType
    NSAttributeType.DecimalAttributeType
    NSAttributeType.DoubleAttributeType
    NSAttributeType.FloatAttributeType
    NSAttributeType.BooleanAttributeType
    NSAttributeType.UndefinedAttributeType


See the initializers in:

https://github.com/blitzagency/amigo-swift/blob/master/Amigo/Column.swift


One additional type exists for Column initialization and that's :code:`Amigo.ForeignKey`


ForeignKeys
-------------------

Amigo allows you to make Foreign Key Relationships. You can do though through
the Managed Object Model or manually.

In the Managed Object Model, ForeignKeys are represented by a **Relationship**
that has a type of :code:`To One`. That gets translated to the :code:`ORMModel`
mapping as follows:

.. code-block:: swift


    import Amigo

    class Dog: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!
    }

    class Person: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!
        dynamic var dog: Dog!
    }


    let dog = ORMModel(Dog.self,
        Column("id", type: Int.self, primaryKey: true)
        Column("label", type: String.self)
    )

    // You can use the ORMModel
    let person = ORMModel(Person.self,
        Column("id", type: Int.self, primaryKey: true)
        Column("label", type: String.self)
        Column("dog", type: ForeignKey(dog))
    )


**OR** using the column itself:

.. code-block:: swift

    // OR you can use the column:
    let person = ORMModel(Person.self,
        Column("id", type: Int.self, primaryKey: true)
        Column("label", type: String.self)
        Column("dog", type: ForeignKey(dog.table.c["id"]))
    )



One To Many
-------------------

Using our :code:`Person/Dog` example above, we can also represent a
One To Many relationship.

In the case of a Managed Object Model, a One To Many is represented by a
**Relationship** that has a type on :code:`To One` on one side and
:code:`To Many` on the other side, aka the inverse relationship.

In code it would look like this:


.. code-block:: swift

    import Amigo

    class Dog: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!
    }

    class Person: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!
        dynamic var dog: Dog!
    }

    let dog = ORMModel(Dog.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("label", type: String.self),
        OneToMany("people", using: Person.self, on: "dog")
    )

    let person = ORMModel(Person.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("label", type: String.self),
        Column("dog", type: ForeignKey(dog))
    )

    // specifying 'echo: true' will have amigo print out
    // all of the SQL commands it's generating.
    let engine = SQLiteEngineFactory(":memory:", echo: true)
    amigo = Amigo([dog, person], factory: engine)
    amigo.createAll()


We can then query the One To Many Relationship this way:

.. code-block:: swift

    let session = amigo.session

    let d1 = Dog()
    d1.label = "Lucy"

    let p1 = People()
    p1.label = "Foo"
    p1.dog = d1

    let p2 = People()
    p2.label = "Bar"
    p2.dog = d1

    session.add(d1, p1, p2)

    var results = session
        .query(People)
        .using(d1)
        .relationship("people")
        .all()

Many To Many
-------------------
