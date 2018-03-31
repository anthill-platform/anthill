Exec Service
============

Every multiplayer project needs to run the game code on the backend side. :doc:`game-master` perfectly does that task.
But sometimes you don’t need that kind of complicity and just to want a simple script that players can connect to
and do things here and there. In Javascript!

The service uses Git to host your code on, so you can setup a repository, put your javascript there, configure it on
the service, and you’re all set.

Javascript support
------------------

EcmaScript 8 is supported.

Hello, world
------------

.. code-block:: javascript

    function hello_world(args) {
        return "Hello, world!";
    }

    hello_world.allow_call = true;

As simple at it looks like. Then you can call it:

.. code-block:: bash

    POST /call/test/1.0/hello_world
    > Hello, world!

.. note::
   Only the functions that defined ``allow_call = true`` can be called by the client,
   thus declaring some functios “API ready”, others private.

Sessions
--------

Calling simple function is not always enough. Often the state between the calls has to be saved,
wrapping the whole call sequence in a “session”. That’s what the Sessions are for.

.. code-block:: javascript

    function SessionHelloWorld(args)
    {
        // this function is called upon session initialization
        this.name = "unknown";
    }

    SessionHelloWorld.allow_session = true;

    SessionHelloWorld.prototype.my_name_is = function(args)
    {
        this.name = args["name"];
        return "Gotcha!"
    };

    SessionHelloWorld.prototype.hello = function(args)
    {
        return "Hello, " + this.name + "!";
    };

Sessions are run by WebSockets, with JSON-RPC as transport protocol.

.. code-block:: bash

    WebSocket /session/test/1.0/SessionHelloWorld

    call("hello")
    > Hello, unknown!
    call("my_name_is", {"name": "world"})
    > Gotcha!
    call("hello")
    > Hello, world!

.. note::
   Only constructor functions (``SessionHelloWorld`` from example above) that define ``allow_session = true``
   will be allowed to open session on. Also, methods that start with underscore are not allowed to call:

   .. code-block:: javascript

       SessionHelloWorld.prototype._internal_method = function(args)
       {
           return "I am so internal";
       };

API
---

.. toctree::
   :maxdepth: 1

   exec/api