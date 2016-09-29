Setup
=================================


Carthage
----------------------------------

FMDB (https://github.com/ccgus/fmdb),
as of v 2.6 FMDB, does suport Carthage.

Drop this into your :code:`Cartfile`:

::

    github "blitzagency/amigo-swift" ~> 0.3.1

Admittedly, we are probably not the best at the whole,
*"How do you share an Xcode Project"* thing, so any recommendations
to imporve this process are welcome.

Initialization Using A Closure
----------------------------------

Initialize Amigo into a global variable so all the initialization
is done in one place:

 .. code-block:: swift

    import Amigo


    class Dog: AmigoModel{
        dynamic var id = 0
        dynamic var label = ""
    }

    let amigo: Amigo = {
        let dog = ORMModel(Dog.self,
            IntegerField("id", primaryKey: true),
            CharField("label")
        )

        // now initialize Amigo
        // specifying 'echo: true' will have amigo print out
        // all of the SQL commands it's generating.
        let engine = SQLiteEngineFactory(":memory:", echo: true)
        let amigo = Amigo([dog], factory: engine)
        amigo.createAll()

        return amigo
    }()


.. note::

    This creates the :code:`amigo` object lazily, which means it's not
    created until it's actually needed. This delays the initial
    output of the app information details. Because of this,
    we recommend forcing the :code:`amigo` object to be created
    at app launch by just referencing :code:`amigo` at the top of
    your :code:`didFinishLaunching` method if you don't
    already use the :code:`amigo` object for something on app launch.
    This style and description was taken directly from [XCGLogger]_


A Note About Threads and Async
-------------------------------

Out of the box, Amigo uses FMDB's :code:`FMDatabaseQueue` to perform all
of it work. This should set you up to user Amigo from any thread you like.

Keep in mind though, the dispatch queue that :code:`FMDatabasesQueue` uses
is a serial queue. So if you invoke multiple long running amigo commands
from separate threads you will be waiting your turn in the serial queue
before your command is executed. It's probably best to:

.. code-block:: swift

    func doStuff(callback: ([YourModelType]) -> ()){
        let session = amigo.session
        // any background queue you  like
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        disptatch_async(queue) {
            let results = session.query(YourModelType).all() // whatever amigo command you want
            dispatch_async(dispatch_get_main_queue()){
                callback(results)
            }
        }
    }

If that's too verbose for your liking you are also welcome to use the
:code:`async` convenience methods provided by the amigo session. The
above code would then look like this:

.. code-block:: swift

    func doStuff(callback: ([YourModelType]) -> ()){
        let session = amigo.session
        session.async{ () -> [YourModelType] in
            let results = session.query(YourModelType).all()
            return results
        }.then(callback)
    }

There are a few ways to use these async handlers. The variations revolve
around weather or not you are returning results. Check out the unit tests
[AmigoSessionAsyncTests]_ for more examples.

For example, you don't have to return any result at all:

.. code-block:: swift

    func addObject(){
        let session = amigo.session
        session.async{
            let dog = Dog()
            dog.label = "Lucy"
            session.add(dog)
        }
    }

    func addBatch(){
        let session = amigo.session
        session.async{

            let d1 = Dog()
            d1.label = "Lucy"

            let d2 = Dog()
            d2.label = "Ollie"

            session.batch{ batch in
                batch.add([d1, d2])
            }
        }
    }

You can also specify your own background queue to execute on:

.. code-block:: swift

    let queue = dispatch_queue_create("com.amigo.async.tests", nil)

    func addDoStuffOnMyOwnQueue(){
        let session = amigo.session
        session.async(queue: queue){
            let dog = Dog()
            dog.label = "Lucy"
            session.add(dog)
        }
    }


Contents:

.. toctree::
   :maxdepth: 2

   engine


.. [XCGLogger] XCGLogger Closure Initialization
   https://github.com/DaveWoodCom/XCGLogger#initialization-using-a-closure

.. [AmigoSessionAsyncTests] AmigoSessionAsyncTests
    https://github.com/blitzagency/amigo-swift/blob/master/AmigoTests/AmigoSessionAsyncTests.swift
