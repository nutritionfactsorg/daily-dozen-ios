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

        public override init(){
            super.init()
        }
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
    defaultValue: (() -> AnyObject?)? = nil


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
    [UInt8]
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


Column Shortcuts (Fields)
--------------------------

Amigo also provides a series pre-baked column types.

https://github.com/blitzagency/amigo-swift/blob/master/Amigo/Fields.swift

They take the same arguments as a :code:`Column`, but the type can be omitted.

.. code-block:: swift

    UUIDField
    CharField
    BooleanField
    IntegerField
    FloatField
    DoubleField
    BinaryField
    DateTimeField // needs some work

.. note::

    The UUIDField, in SQLite, will store your data as a 16 byte BLOB
    but it on the model itself it will be realized as a :code:`String`.


Lets take a look at how using these might look:

.. code-block:: swift

    class MyModel: AmigoModel{
        dynamic var id: Int = 0
        dynamic var objId: String?

        public override init(){
            super.init()
        }
    }

    let myModel = ORMModel(MyModel.self,
        IntegerField("id", primaryKey: true),
        UUIDField("objId", indexed: true, unique: true)
    )

    // now initialize Amigo
    // specifying 'echo: true' will have amigo print out
    // all of the SQL commands it's generating.
    let engine = SQLiteEngineFactory(":memory:", echo: true)
    let amigo = Amigo([myModel], factory: engine)
    amigo.createAll()

    let objId = NSUUID().UUIDString
    let obj = MyModel()
    obj.objId = objId

    let session = amigo.session
    session.add(obj)

    let results = session
        .query(MyModel)
        .filter("objId = '\(objId)'")
        .all()

Remember above how we said that the :code:`UUIDField` stores it's data
as a BLOB. The above filter does the right thing, it will convert the
privided string when filtering on the :code:`UUIDField` to it's data
representation.


UUIDField
--------------------------

The UUIDField will serve you best if you provide a :code:`defaultValue`
function. 99% of the time you will likely want something like this
when you define the column unless you want to be responsible for always
setting the value yourself:

.. code-block:: swift

    import Amigo

    class MyModel: AmigoModel{
        dynamic var id: Int = 0
        dynamic var objId: String?

        public override init(){
            super.init()
        }
    }

    let myModel = ORMModel(MyModel.self,
            IntegerField("id", primaryKey: true)
            UUIDField("objId", indexed: true, unique: true){
                // the input case doesn't actually matter, but
                // rfc 4122 states that:
                //
                // The hexadecimal values "a" through "f" are output as
                // lower case characters and are case insensitive on input.
                //
                // See: https://www.ietf.org/rfc/rfc4122.txt
                // Declaration of syntactic structure
                return NSUUID().UUIDString.lowercaseString
            }
        )

.. note::

    The deserialization of the UUIDField will return you a String that is lowercased
    per RFC 4122.


One additional type exists for Column initialization and that's :code:`Amigo.ForeignKey`

.. _foreign-key:

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
        dynamic var id = 0
        dynamic var label = "New Dog"

        public override init(){
            super.init()
        }
    }

    class Person: AmigoModel{
        dynamic var id = 0
        dynamic var label = "New Person"
        dynamic var dog: Dog?

        public override init(){
            super.init()
        }
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

**or using the column itself**

.. code-block:: swift

    // OR you can use the column:
    let person = ORMModel(Person.self,
        Column("id", type: Int.self, primaryKey: true)
        Column("label", type: String.self)
        Column("dog", type: ForeignKey(dog.table.c["id"]))
    )


.. _one-to-many:

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

        public override init(){
            super.init()
        }
    }

    class Person: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!
        dynamic var dog: Dog!

        public override init(){
            super.init()
        }
    }

    let dog = ORMModel(Dog.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("label", type: String.self),
        OneToMany("people", using: Person.self)
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
        .query(People)          // We want the People objects
        .using(d1)              // by using the d1 (Dog) object
        .relationship("people") // and following the d1 model's "people" relationship
        .all()

.. _many-to-many:

Many To Many
-------------------


Amigo can also represent Many To Many Relationships. It will build the
intermediate table for you as well.

In the case of a Managed Object Model, a Many To Many is represented by a
**Relationship** that has a type on :code:`To Many` on one side and
:code:`To Many` on the other side, aka the inverse relationship.

Starting with the following data models:

.. code-block:: swift

    import Amigo

    // ---- Many To Many ----
    // A Parent can have Many Children
    // and children can have Many Parents

    class Parent: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!

        public override init(){
            super.init()
        }
    }

    class Child: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!

        public override init(){
            super.init()
        }
    }

Now, lets manually map them and create the relationship:

.. code-block:: swift

    let parent = ORMModel(Parent.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("label", type: String.self),
        ManyToMany("children", using: Child.self)
    )

    let child = ORMModel(Child.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("label", type: String.self),
    )

    // specifying 'echo: true' will have amigo print out
    // all of the SQL commands it's generating.
    let engine = SQLiteEngineFactory(":memory:", echo: true)
    amigo = Amigo([parent, child], factory: engine)
    amigo.createAll()

    let session = amigo.session

    let p1 = Parent()
    p1.label = "Foo"

    let c1 = Child()
    c1.label = "Baz"

    let c2 = Child()
    c2.label = "Qux"

    session.add(p1,  c1, c2)

    // add 2 children to p1
    session.using(p1).relationship("children").add(c1, c2)

    var results = session
        .query(Child)             // We want the Child objects
        .using(p1)                // by using the p1 (Parent) object
        .relationship("children") // and following the p1 model's "children" relationship
        .all()

    print(results.count)


.. _many-to-many-through-models:

Extra Fields on Many To Many Relationships
-------------------------------------------

Sometimes you need more information on a Many To Many Relationship
than just the 2 original models. We have shamelessly taken this concept
from Django and matched their name: "Though" Models.

In the case of a Managed Object Model, a Many To Many with a "Through" models
is represented by a **Relationship** that has a type on :code:`To Many` on one side and
:code:`To Many` on the other side, aka the inverse relationship. Additionally,
the :code:`User Info` of the relationship has the following key value pair:

**throughModel** = **Fully Qualified AmigoModel Subclass Name**

Lets make a manual example.

.. code-block:: swift

    import Amigo


    // ---- Many To Many (through model) ----
    // A Workout can have Many Exercises
    // An exercise can belong to Many Workouts
    // We attach some extra Meta information to
    // the relationship though.

    class Workout: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!

        public override init(){
            super.init()
        }
    }

    class WorkoutExercise: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var label: String!

        public override init(){
            super.init()
        }
    }

    class WorkoutMeta: AmigoModel{
        dynamic var id: NSNumber!
        dynamic var duration: NSNumber!
        dynamic var position: NSNumber!
        dynamic var exercise: WorkoutExercise!
        dynamic var workout: Workout!
    }


Now, lets manually map them and create the relationship:

.. code-block:: swift

    let workout = ORMModel(Workout.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("label", type: String.self),
        ManyToMany("exercises", using: WorkoutExercise.self, throughModel: WorkoutMeta.self)
    )

    let workoutExercise = ORMModel(WorkoutExercise.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("label", type: String.self),
    )

    let workoutMeta = ORMModel(WorkoutMeta.self,
        Column("id", type: Int.self, primaryKey: true),
        Column("duration", type: Int.self),
        Column("position", type: Int.self),
        Column("exercise", type: ForeignKey(workoutExercise)),
        Column("workout", type: ForeignKey(workout))
    )


.. note ::

    Look at the mapping for :code:`WorkoutMeta`. If you are going to
    use a :code:`throughModel` the model that will we will go though
    **MUST** contain 2 :code:`ForeignKey` columns. They **MUST** map to
    the 2 columns that are required for the many-to-many relationship.


Now that we are mapped, lets try adding an exercise **without** using
the WorkoutMeta.

.. code-block:: swift

    let session = amigo.session

    let w1 = Workout()
    w1.label = "foo"

    let e1 = WorkoutExercise()
    e1.label = "Jumping Jacks"

    session.add(w1)
    session.add(e1)

    // This will cause a fatal error.
    session.using(w1).relationship("exercises").add(e1)

Because we have instructed Amigo that this many-to-many relationship
uses a "through" model, we can no longer use the many-to-many add or delete
functionality, as the :code:`WorkoutMeta` model is required.

Instead, you simply add a :code:`WorkoutMeta` model like any other model.
Amigo handles the insert into the intermediate table for you.

.. code-block:: swift

    let session = amigo.session

    let w1 = Workout()
    w1.label = "foo"

    let e1 = WorkoutExercise()
    e1.label = "Jumping Jacks"

    let m1 = WorkoutMeta()
    m1.workout = w1
    m1.exercise = e1
    m1.duration = 60000
    m1.position = 1

    session.add(w1, e1, m1)

    // querying the many-to-many however is the same.
    var results = session
        .query(WorkoutMeta)                    // We want the WorkoutMeta objects
        .using(w1)                             // by using the w1 (Workout) object
        .relationship("exercises")             // and following the w1 model's "exercises" relationship
        .orderBy("position", ascending: true)  // order the results by WorkoutMeta.position ascending
        .all()
