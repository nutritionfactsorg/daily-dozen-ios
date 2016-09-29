Sessions
=================================


When you go though :code:`amigo.session` using the provided
:code:`SQLiteEngine` you automatically begin a SQL Transaction.

If you would like your information to actually be persisted you must
:code:`commit` the transaction. Once committed, the session will
automatically begin a new transaciton for you.


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

    let session = amigo.session
    let d1 = Dog()
    let d2 = Dog()

    d1.label = "Lucy"
    d2.label = "Ollie"

    session.add(d1, d2)
    session.commit()


Upsert
------------------------

When inserting a model, you have the option to choose weather or not
you would like this to be done as an insert or an upsert. In sqlite
this translates to :code:`INSERT OR REPLACE`. To take advantage of this
you need to pass an additional argument to :code:`session.add`.

.. code-block:: swift

    session.add(myModel, upsert: true)


Batching
------------------------

If you would like to batch a significant number of queries
Amigo supports this for add and delete.

.. code-block:: swift

    let session = amigo.session

    session.batch{ bacth in
        myAdds.forEach(batch.add)
        myDeletes.forEach(batch.add)
        myUpserts.forEach{ batch.add($0, upsert: true) }
    }

This will take all of the generated sql and execute at once. It's a
convenience over FMDB :code:`executeStatements`
https://github.com/ccgus/fmdb#multiple-statements-and-batch-stuff

.. important::

    When you use this functionality Amigo does not make any
    updates to the source models.  For example, doing an
    :code:`session.add` will modify the source model with
    the primary key assigned to it by immediately issuing a
    :code:`SELECT last_insert_rowid();`. However, :code:`batch.add`
    will not do this.

.. warning::

    If you use batching with Many-To-Many + Through Models you should
    have all of the information necessary in advance for the
    relationship. It's not required, but if you don't have all of the
    Foreign Keys and Primary Key for the record, Amigo will skip batching
    those items in favor of a regular :code:`session.add` to ensure
    it has the proper information.
