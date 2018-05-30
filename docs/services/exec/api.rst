
.. title:: API

.. |star| image:: star.png
   :width: 16px

Concepts
========

Plain Function definition
-------------------------

Plain functions can be defined as follows:

.. code-block:: javascript

    function function_name(args)
    {
        return "I am the result";
    }

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``args``
      - JSON dictionary of arguments, than might be passed to the function with ``call`` (se below)

.. _throwing-an-error:

Throwing an error
-----------------

To notify the client that error is happened during function/method call, this construction must be called:

.. code-block:: javascript

    throw new Error(error_code, error_message)

    // for example
    throw new Error(404, "No such hero!")

Asynchronous Functions
----------------------

EcmaScript 8 states that functions can be defined as asynchronous.

The API allows that with the ``async`` / ``await`` keywords:

.. code-block:: javascript

    async function test(args) { 
        // wait for one second 
        await sleep(1.0) 
        // get the user profile 
        var my_profile = await profile.get(); 
        return "Hello," + my_profile.name; 
    }

    test.prototype.allow_call = true;

.. code-block:: bash

    POST /call/test/1.0/test
    # waits for one, second, gets the profile
    > Hello, %username%


REST API
========

Call the plain function
-----------------------

Calls the given function server-side, returning its result.

The function must have ``allow_call = true`` to be defined, otherwise the ``404 Not Found`` will be returned. 

← Request
~~~~~~~~~

.. code-block:: bash

    POST /call/<application_name>/<application_version>/<function_name>


.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``application_name``
      - A name of the application to call the function about, see :ref:`application-name`
    * - ``application_version``
      - A version of the application to call the function about, see :ref:`application-version`
    * - ``function_name``
      - Name of the function to call

Access scope ``exec_func_call`` is required for this request.

→ Response
~~~~~~~~~~

Function response is returned as is.

.. list-table::
    :header-rows: 1

    * - Response
      - Description
    * - ``200 OK``
      - Everything went OK, result follows.
    * - ``404 Not Found``
      - No such function
    * - custom errors
      - Function may throw errors with custom codes for the client application to process

WebSocket API
=============

Open a new Session
------------------

To open a new session, a new WebSocket connection on this location should be established:

WebSocket connection
~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    WEBSOCKET /session/<application_name>/<application_version>/<class_name>


.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``application_name``
      - A name of the application to call the function about, see :ref:`application-name`
    * - ``application_version``
      - A version of the application to call the function about, see :ref:`application-version`
    * - ``class_name``
      - Name of the Construction Function to be used on this session
    * - ``args``
      - JSON dictionary of arguments that will be passed as `args` argument to the Construction Function

Access scope ``exec_func_call`` is required for this request.

.. note::
    For the session to be successfully be opened, a Constructor Function with name ``class_name`` should exists, and
    should have ``allow_session = true`` to be defined:

.. code-block:: javascript

    function Test(args) {}
    Test.allow_session = true;

Communication protocol
~~~~~~~~~~~~~~~~~~~~~~

JSON-RPC is used as transport protocol to call the methods of the session, and get the responses.

Call a method
~~~~~~~~~~~~~

To call a method, a request named ``call`` should be sent.

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``method_name``
      - Name of method to be called.
    * - ``arguments``
      - JSON dictionary of arguments that will be passed as ``args`` argument to method

Example of calling a method:

::

    -> {"jsonrpc": "2.0", "method": "call", "params": {"method_name": "test", "arguments": {}}, "id": 1}
    <- {"jsonrpc": "2.0", "result": "Testing!", "id": 1}

.. code-block:: javascript

    function Test(args) {}

    Test.prototype.test = function(args) {
        return "Testing!";
    };

    Test.allow_session = true;

.. note:: Methods don’t need ``allow_call`` since all public method of the Constructor function are allowed to call.
    To make the method private, start its name with underscore.

"released" method
^^^^^^^^^^^^^^^^^

If the session needs to run some code once the connections is lost, a method ``released`` could be defined:

.. code-block:: javascript

    Test.prototype.released = function(args) {
        log("I am being released");
    };

It will be called automatically upon session being closed. This method cannot be called manually,
and should return no result, as it will be ignored. Also, this method allowed to be asynchronous.

Standard API
============

Along with standard Javascript functions, several are added by the API.

.. note:: Functions, marked |star| with are asynchronous. They return Promise that required to be ``await``' ed.

- ``Error(code, message)``

    See :ref:`throwing-an-error`.

    +-------------+----------------------------------+
    | Argument    | Description                      |
    +=============+==================================+
    | ``code``    | The code indicating the problem. |
    +-------------+----------------------------------+
    | ``message`` | Error description                |
    +-------------+----------------------------------+

- ``log(message)``

    To issue a log message, use ``log(message)``

    +-------------+-------------+
    | Argument    | Description |
    +=============+=============+
    | ``message`` | Log message |
    +-------------+-------------+

- |star| ``sleep(delay)``

    Delays the execution for some time.

    +-----------+---------------------------+
    | Argument  | Description               |
    +===========+===========================+
    | ``delay`` | Time for delay in seconds |
    +-----------+---------------------------+

web
---

An object to access to the internet

- |star| ``web.get(url, [headers])``

    Downloads the file at the ``url`` and returns its contents.

    +-------------+-------------------------------------------------+
    | Argument    | Description                                     |
    +=============+=================================================+
    | ``url``     | An URI to download the contents from            |
    +-------------+-------------------------------------------------+
    | ``headers`` | (Optional). JSON object of HTTP headers to send |
    +-------------+-------------------------------------------------+

config
------

An object to access to the :doc:`../config`

- |star| ``config.get()``

    Returns the Configuration Info for the game name / game version.

store
-----

An object to access to the :doc:`../store`

- |star| ``store.get(name)``

    Returns the configuration of the given Store

    +----------+-------------+
    | Argument | Description |
    +==========+=============+
    | ``name`` | Store name  |
    +----------+-------------+

- |star| ``store.new_order(store, item, currency, amount, component)``

    Places a new order in the Store. Returns the new order id.

    +---------------+---------------+
    | Argument      | Description   |
    +===============+===============+
    | ``store``     | Store name    |
    +---------------+---------------+
    | ``item``      | Item name     |
    +---------------+---------------+
    | ``currency``  | Currency name |
    +---------------+---------------+
    | ``amount``    | Items amount  |
    +---------------+---------------+
    | ``component`` | Component     |
    +---------------+---------------+

- |star| ``store.update_order(order_id)``

    Updates the given order. No additional documentation so far.

    +--------------+--------------------+
    | Argument     | Description        |
    +==============+====================+
    | ``order_id`` | Order id to update |
    +--------------+--------------------+

- |star| ``store.update_orders()``

    Updates all unfinished orders of the user. No additional documentation so far.

profile
-------

An object to access to the :doc:`../profile`

- |star| ``profile.get([path])``

    Returns the user’s profile.

    +----------+---------------------------------------------------------------------------------------+
    | Argument | Description                                                                           |
    +==========+=======================================================================================+
    | ``path`` | (Optional). Path of the profile to get. If not defined, the whole profile is returned |
    +----------+---------------------------------------------------------------------------------------+

- |star| ``profile.update(profile, [path], [merge])``

    Updates the user’s profile.

    +-------------+-------------------------------------------------------------------------------------------------------------------------------------+
    | Argument    | Description                                                                                                                         |
    +=============+=====================================================================================================================================+
    | ``profile`` | A JSON object for the profile to update                                                                                             |
    +-------------+-------------------------------------------------------------------------------------------------------------------------------------+
    | ``path``    | (Optional). Path of the profile to update. If not defined, the whole profile is updated                                             |
    +-------------+-------------------------------------------------------------------------------------------------------------------------------------+
    | ``merge``   | (Optional). If true (default), the JSON objects of existing profile and updated one are mixed, otherwise the old object is replaces |
    +-------------+-------------------------------------------------------------------------------------------------------------------------------------+

- |star| ``profile.query(query, [limit])``

    Search for user profiles with :ref:`json-db-query`.

    .. list-table::
        :header-rows: 1
        :widths: 20 80

        * - Argument
          - Description
        * - ``profile``
          - :ref:`json-db-query`
        * - ``limit``
          - (Optional) Limit number of resulting profiles, default is 1000.

    A result is a JSON object:

    ::

        {
            "results": {
                "1": {
                    "profile": { ... profile object ... }
                },
                "12": {
                    "profile": { ... profile object ... }
                },
                ...
            },
            "total_count": <total amount of profiles found>
        }

admin
-----

An object for the administrative purposes. Can be accessed only from a server context, and clients have no ways to
access it.

- |star| ``admin.delete_accounts(accounts, [gamespace_only])``

    .. warning::
        This actions is destructive and should be proceed with caution. Regular database backups are required before
        using this.

    Triggers **PERMANENT** deletion of certain accounts from all and every service.

    .. list-table::
        :header-rows: 1
        :widths: 20 80

        * - Argument
          - Description
        * - ``accounts``
          - A JSON list of accounts to delete
        * - ``gamespace_only``
          - (Optional) Keep the account ID and credentials, so the user can still access data from other gamespaces.
            Default is true. If true, data will be deleted only from current gamespace.
            If false, ALL USER DATA FROM ALL GAMESPACES WILL BE PERMANENTLY DELETED.
