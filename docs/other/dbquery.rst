.. _json-db-query:

JSON Database Query
===================

JSON Database Query is a special JSON object designed to perform queries against other JSON objects
(for example, :ref:`User Profiles <user-profile>` or :ref:`Rooms / Parties <game-master-concepts>`), much like SQL
language, except its very simplified.

    ::

        {
            "apple": "green",
            "age": {
                "@func": ">=",
                "@value": 18
            }
        }

Is equivalent of this SQL query:

    .. code-block:: sql

         SELECT *
         FROM `table`
         WHERE `apple`='green' AND `age`>=18;

For example, consider this object:

   ::

       {
          "username": "player",
          "level": 50,
          "progress": {
              ...
          }
       }

If you have such an object in the database, you can find it in the database, using this simple JSON Database Query:

    ::

        {
            "username": "player"
        }


Query Format
------------

In general, JSON Database Query has such format:

    ::

        {
            <field>: value or function,
            <field>: value or function,
            ...
        }

It only works with ``AND`` condition, meaning **ALL** fields of the querying object have to satisfy the query.

* ``value``

    If you specify a value, for example ``"string"`` or ``15``, the query will search for exact value in that field.

* ``function``

    You can pass a function along the way. It will test the field on certain conditions.

Functions
---------

A function is a JSON object itself, with this exact format:

    ::

        {
            "@func": "<function name>",
            "@value": <a value to test the function against>
        }

Supported functions are: ``>``, ``<``, ``=``, ``>=``, ``<=``, ``!=``, ``between`` and ``in``.

The mathematical ones are obvious, as they do as they're named.

* ``between``

    A special function for searching a field with value between ``a`` and ``b``. It has this exclusive format:

    ::

        {
            "@func": "between",
            "@a": 10,
            "@b": 15,
        }

* ``in``

    A special function for searching a field with value listed in an array. It has this exclusive format:

    ::

        {
            "@func": "in",
            "@values": [1, 2, 4, 8, 16, 32]
        }
