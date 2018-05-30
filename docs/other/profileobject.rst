.. _profile-object:

Profile Object
==============

Profile Object is a JSON object stored on the server side that can be altered concurrently with functions.

As a storage media, it is literally just a plain JSON object, and can be received by user only as a JSON object, but
while altering, a special :ref:`profile-object-functions` can be applied to it, making possible to implement
things like:

- Increment/decrement/change a field;
- Make sure some field is passes to certain condition while updating the value concurrently;

.. _profile-object-concurrency:

Concurrency is the Key
----------------------

    :ref:`profile-object-functions` make a lot of sense in concurrent environment (for example, if two clients
    are applying increment at the same time to the same field, the resulting value would be a sum of those increments).
    With normal approach, one of the changes will be lost.

.. _profile-object-functions:

Functions
---------

    Functions are special mathematical operations that can be applied to certain JSON field.

    Consider this JSON object:

    .. code-block:: json

        {
            "test": 10
        }

    You can apply a function to a field ``test`` in the example above, and depending on the function, the value of
    the field might get changed, or certain condition might be required.

    .. seealso::
        :ref:`profile-object-function-list`

How to apply a function
~~~~~~~~~~~~~~~~~~~~~~~

    To apply a function, you must replace a value the field in question, with a special magic object:

    .. code-block:: json

        {
            "<field>": {
                "@func": "<a function name>",
                "@value": "<a value that will be applied to the function>",
                "@cond": "<optional condition parameter>"
            }
        }

    .. glossary::

        ``@func``

            A name of the function to be applied to the field. See :ref:`profile-object-function-list` for reference

        ``@value``, ``@cond``, etc

            Optional arguments might be required for certain functions.


    Mathematically speaking, function is applied like so:

        .. code::

            object["field"] = @func(object["field"], @value)

    For example:

        .. code-block:: json

            {
                "foo": 10,
                "bar": 50
            }

    To apply function :ref:`profile-object-function-increment` to the field ``foo``,
    you must supply this JSON object while updated the Profile Object:

        .. code-block:: json

            {
                "foo": {
                    "@func": "increment",
                    "@value": 5
                }
            }

    The function will take the original value ``10``, do mathematical stuff over it, and update the object's
    field with a new value:

        .. code-block:: json

            {
                "foo": 15,
                "bar": 50
            }

    You can apply functions to multiple fields with one call:

        .. code-block:: json

            {
                "foo": {
                    "@func": "increment",
                    "@value": 10
                },
                "bar": {
                    "@func": "decrement",
                    "@value": 25
                }
            }

    That will result in:

        .. code-block:: json

            {
                "foo": 5,
                "bar": 25
            }

    Functions can be even nested (meaning ``@value`` of the functions can be functions themselves).
    For example, if we apply a such update to previous object:

    .. code-block:: json

        {
            "bar": {
                "@func": "<",
                "@cond": 50,
                "@then": {
                    "@func": "increment",
                    "@value": 1
                }
            }
        }

    Then the field ``bar`` will be incremented by 1 (with concurrency support) but only if ``bar`` is smaller than 50,
    thus guaranteeing the total amount cannot be greater than 50 concurrently. In more traditional way, this can be
    viewed like so:

    .. code-block:: javascript

        var bar = object["bar"];

        if (bar < 50) {
            object["bar"] = bar + 1;
        }

.. _profile-object-function-list:

Function List
-------------

.. contents::
   :local:
   :depth: 1

.. _profile-object-function-increment:

Increment a Value
~~~~~~~~~~~~~~~~~

Can be referenced by ``increment`` or ``++``. Increments a field value by ``@value``.

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``@value``
      - The value to increment the field value with

Example:

.. code-block:: json

    {
        "field": {
            "@func": "++",
            "@value": 10
        }
    }

.. _profile-object-function-decrement:

Decrement a Value
~~~~~~~~~~~~~~~~~

Can be referenced by ``decrement`` or ``--``. Decrements a field value by ``@value``.

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``@value``
      - The value to decrement the field value with

Example:

.. code-block:: json

    {
        "field": {
            "@func": "--",
            "@value": 55
        }
    }

.. _profile-object-function-decrement-0:

Decrement a Value But Keep Greater Than Zero
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Can be referenced by ``decrement_greater_zero`` or ``--/0``.
Decrements a field value by ``@value`` but only if the resulting value is positive/zero. If the resulting value
is less than zero, produces ``not_enough`` error.

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``@value``
      - The value to decrement the field value with

Example:

.. code-block:: json

    {
        "field": {
            "@func": "--/0",
            "@value": 55
        }
    }


.. _profile-object-function-comparators:

Comparators (``==``, ``!=``, ``>``, ``>=``, ``<``, ``<=``)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section covers comparators. These have same arguments, but different behaviour:

.. list-table::
    :widths: 15 15 70
    :header-rows: 1

    * - Function
      - Reference
      - Description
    * - Equal
      - ``==``
      - Ensures a field is equal to ``@cond``
    * - Not equal
      - ``!=``
      - Ensures a field is not equal to ``@cond``
    * - Greater
      - ``>``
      - Ensures a field is greater than ``@cond``
    * - Greater or equal
      - ``>=``
      - Ensures a field is greater or equal to ``@cond``
    * - Smaller
      - ``<``
      - Ensures a field is smaller than ``@cond``
    * - Smaller or equal
      - ``<=``
      - Ensures a field is smaller or equal to ``@cond``

.. note::
    These functions do not change field, unless ``@then`` or ``@else`` fields provided.

All of the functions listed above have same arguments:

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``@cond``
      - An object to compare the value to
    * - ``@value``
      - (Optional) a value to use instead of object's value (see below), useful for nesting
    * - ``@then``
      - (Optional) a value to use, if the condition **true**. If condition is **true**,
        and ``@then`` is not defined, nothing happens (object's value remains the same)
    * - ``@else``
      - (Optional) a value to use, if the condition is **false**. If the condition **false**,
        and ``@else`` is not defined, error is raised.

Example:

.. code-block:: json

    {
        "field": {
            "@func": "==",
            "@cond": 10,
            "@then": 20,
            "@else": 0
        }
    }

If the ``field`` value is 10, then set it to 20, or set it to zero otherwise.

.. _profile-object-function-exists:

Exists
~~~~~~

Can be referenced by ``exists``. Ensures a field exists (opposite to :ref:`profile-object-function-not-exists`)

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``@then``
      - (Optional) a value to use, if the object exists. If object exists,
        and ``@then`` is not defined, nothing happens (object remains present)
    * - ``@else``
      - (Optional) a value to use, if the object does not exist. If object does not exist,
        and ``@else`` is not defined, error ``not_exists`` is raised.

Example:

.. code-block:: json

    {
        "field": {
            "@func": "exists",
            "@then": {
                "@func": "--/0",
                "@value": 1
            },
            "@else": 100
        }
    }

If the ``field`` exists, decrement its value until it reaches zero, otherwise set it to 100.

.. _profile-object-function-not-exists:

Not Exists
~~~~~~~~~~

Can be referenced by ``not_exists``. Ensures a field does not exist (opposite to :ref:`profile-object-function-exists`)

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``@then``
      - (Optional) a value to use, if the object does not exist. If object does not exist,
        and ``@then`` is not defined, nothing happens (object remains not present)
    * - ``@else``
      - (Optional) a value to use, if the object does exist. If object does exist,
        and @else is not defined, error ``exists`` is raised.

Example:

.. code-block:: json

    {
        "field": {
            "@func": "not_exists",
            "@then": 100,
            "@else": {
                "@func": "--/0",
                "@value": 1
            }
        }
    }

If the ``field`` does not exists, set it to 100, otherwise decrement its value until it reaches zero.

.. _profile-object-function-array-append:

Append A Value To An Array
~~~~~~~~~~~~~~~~~~~~~~~~~~

Can be referenced by ``array_append``. Appends a new value to the end of an array `[]`.

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``@value``
      - A value to append to the array
    * - ``@limit``
      - (Optional) A maximum size of the array. If the limit is reached, error ``limit_exceeded`` is raised.
    * - ``@shift``
      - (Optional) If ``true``, and limit is reached, the first element will be deleted to free space

Example:

.. code-block:: json

    {
        "field": {
            "@func": "array_append",
            "@value": 5
            "@limit": 3,
            "@shift": true
        }
    }

Appends a value 5 to the end of the array ``field``, but keeps the maximum limit of the items 3 by shifting.

.. _profile-object-function-num-child-where:

Count Number Of Child Fields Which Pass Condition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Can be referenced by ``num_child_where``. This complicated function can count a number of child fields
which pass a certain test condition. The function itself is useless, but it can be wrapped in other function to
ensure the resulting number qualifies the quota.

Consider this example:

.. code-block:: json

    {
        "members": {
            "1": {
                "color": "red"
            },
            "2": {
                "color": "red"
            },
            "1": {
                "color": "green"
            }
        }
    }

The function might be useful to ensure there's no more than 2 members with ``color=red`` (see example below).

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``@field``
      - A field name of the each child to perform tests on
    * - ``@test``
      - Name of the function the tests will rely on
    * - Other
      - The ``@test`` function will require additional arguments. For example,
        a :ref:`comparator <profile-object-function-comparators>` function will require ``@cond`` argument

Example:

.. code-block:: json

    {
        "members": {
            "@func": "<",
            "@cond": 2
            "@value": {
                "@func": "num_child_where",
                "@test": "==",
                "@cond": "red"
            }
        }
    }

Such formula will do nothing if a total number of child objects of the ``members`` object that match the criteria
``color=red`` does not exceed a value of 2. If it does exceed, the error will be raised.

.. note::
    This particular function might be used in ``join_party`` method of :ref:`party-session-methods` to test against
    Party Members while joining the party.

Examples
--------

Increment likes/stats/etc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: json

    {
        "likes-x": {
            "@func": "++",
            "@value": 1
        }
    }

Claim a reward, but only once
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: json

    {
        "reward-x": {
            "@func": "!=",
            "@cond": true,
            "@then": true
        }
    }

Set a value to a filed, only if it didn't exist earlier
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: json

    {
        "value-x": {
            "@func": "not_exists",
            "@then": 55
        }
    }

Applications
------------

- :ref:`user-profile`
- ``join_party`` method of :ref:`party-session-methods`
