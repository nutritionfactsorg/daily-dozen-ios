Managed Object Model
===================================


Yup, Amigo can turn :code:`NSEntityDescriptions` along with their
relationships into your tables for you. There are only a couple things to know.


1. Unlike :code:`CoreData`, you need to specify your primary key field.
   This could totally be automated for you, we havent decided if we like
   that or not yet. You do this by picking your attribute in your entity
   and adding the following to the User Info: primaryKey true.
   Crack open the :code:`App.xcdatamodeld` and look at any of the entities
   for more info.

2. You need to be sure the `Class` you assign to the entity in your
   `xcdatamodeld` is a subclass of AmigoModel


You do not have to use a :code:`NSManagedObjectModel` at all. In fact,
we just use it to convert the :code:`NSEntityDescriptions` into
:code: `ORMModel` instances. It's fine if you want to do the mappings
yourself. See :doc:`orm_models` for more.
