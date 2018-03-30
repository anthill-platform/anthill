Game Server Spawn Flow
======================

In order to spawn a game server right, few steps is done.

1. Creating a room
~~~~~~~~~~~~~~~~~~

The Player decides to create a room, or just join to first room that matches required criteria. In case of second option, if no rooms found that match the criteria, a new one is created.

2. Resolving a Region
~~~~~~~~~~~~~~~~~~~~~

Using the IP address of the Player, the closest Region is resolved (the one with closest geo distance to the Player). If no geo information is known upon Player’s IP address, the default Region is chosen instead.

3. Resolving a Host
~~~~~~~~~~~~~~~~~~~

On the Region from previous step, the least loaded Host it resolved (using Memory / CPU information provided using heartbeats). If a healthy Host cannot be found (either all of them are overloaded or lost connection on heartbeats), and error is returned to the Player.

4. Spawn Request
~~~~~~~~~~~~~~~~

One the Host is resolved, an HTTP ``spawn`` request is sent to that Host. At that point, any result returned is redirected to the Player.

Yet, the Player’s request is not responded until the Game Server instance is spawned and completely initialized. If any error occurs during spawning process, the Player is responded with that error.

5. Spawning Game Server instance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

At this point, all communication is happens on the Host the spawning process is happen on.

On the Host machine, depending of which Game Server Configuration is being spawned, a new process is instantiated. That process is completely game-specific. Upon starting a process, multiple command line arguments are passed:

``<binary>`` ``<unix domain socket path>`` ``<ports>`` ``<other> ...``

-  *<binary>* A binary file that is actually being instantiated.
-  *<unix domain socket path>* A path to a special `Unix Domain Socket <https://en.wikipedia.org/wiki/Unix_domain_socket>`__ that Controller will communicate with a Game Server upon.
-  *<ports>* A comma separated list of ports us made available for that particular Game Server instance. For example, ``32765,32766``. Game Server instance may listen on that ports as Player may connect to them.
-  *<other> …* Additional command line arguments, that may appear as defined in ``Additional Command Line Arguments`` section of the Game Server Configuration.

Alongside with those arguments, depending of Game Server Configuration, a bunch of Environment variables can be defined:

- Those who defined in ``Environment Variables`` section of the Game Server Configuration.
- ``login:access_token`` A complete and working :ref:`access-token` instance of server-side use.
- ``discovery:services`` A JSON Object with predefined key/value list of service locations for server-side use. See ``Discover Services`` section of the Game Server Configuration.
- ``game:max_players`` Maximum players the room can take (on which this Game Server is spawned upon).
- ``room:settings`` A JSON Object with custom room settings as defined by player.
- ``server:settings`` A JSON Object with Custom Server Configuration Settings (see according section of the Game Server Configuration).

|

6. Communication between Game Server and Controller Service
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After being spawned, the Game Server instance is required to communicate with Controller Service using `JSON-RPC <http://www.jsonrpc.org/specification>`__ protocol.

In short, a JSON-RPC protocol allows two nodes to send each other requests, end receive responses (in form of JSON objects):

::

    Node A -> { request JSON object } -> Node B
    Node A <- { response JSON object } <- Node B

JSON-RPC is a high-level protocol, so the `ZeroMQ library <http://zeromq.org/>`__ is used to proceed transport-level communication:

-  The Game Server instance must create `ØMQ Pair <http://learning-0mq-with-pyzmq.readthedocs.io/en/latest/pyzmq/patterns/pair.html>`__ socket instance
-  Then, the Game Server instance must bind that socket with `Inter-Process Communication <http://api.zeromq.org/2-1:zmq-ipc>`__ transport of the ZeroMQ to listen on that Unix Domain Socket
-  On top of that, each ZeroMQ message should be a complete JSON-RPC object (either request or response).

Examples of opening a ZeroMQ channel for communication:

.. tabs::
    .. code-tab:: python

        context = zmq.Context()
        socket = context.socket(zmq.PAIR)
        socket.connect("ipc://<path to unix domain socket file>")

    .. code-tab:: java

        context = new ZContext();
        socket = context.createSocket(ZMQ.PAIR);
        socket.connect("ipc://<path to unix domain socket file>")

    .. code-tab:: c++

        m_context = std::shared_ptr<zmqpp::context>(new zmqpp::context());
        zmqpp::socket_type type = zmqpp::socket_type::pair;
        m_socket = std::shared_ptr<zmqpp::socket>(new zmqpp::socket(*m_context, type));
        zmqpp::endpoint_t endpoint = "ipc://<path to unix domain socket file>";
        m_socket->set(zmqpp::socket_option::linger, 1);
        m_socket->connect(endpoint);

7. Game Server initialization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once the Game Server instance is completely initialized and ready to receive connections, the ``inited`` request should be sent to the Controller.

.. toggle-header::
    :header: Example of the JSON-RPC Request object **Show/Hide Code**

    .. code:: json

        {
            "jsonrpc": "2.0",
            "method": "inited",
            "params": {
                "settings": {
                    "test": 5
                }
            },
            "id": 1
        }

-  If the argument ``settings`` passed along the request, the rooms settings is updated with that argument. For example, if player requested to create a room with ``{"map": "badone"}`` and the Game Server instance realized there is no such map, in can choose the other map instead, and pass ``{"map": "goodone"}`` as the ``settings`` argument to the ``inited`` call. That would lead to the room have correct map setting no matter what setting the Player have passed.
-  The Controller will respond ``{"status": "OK"}`` to that request if everything went fine. If the error is returned instead, the Game Server instance should exit the process (and will be forced to at some point).

The Game Server instance has around 30 seconds (as defined in ``SPAWN_TIMEOUT``) to send the ``inited`` request to the Controller that the Game Server is completely initialized.

**Warning**: If the Game Server would not manage to initialize within that time, the Game Server instance will be killed, and the error is returned to the Player.

8. The Game Server instance details
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once the ``inited`` request is called, the Master Service will return the Game Server instance details to the player (as described in step 4):

-  The host location of the Game Server instance
-  The ports made available for that particular Game Server instance
-  The room Registration Key
-  The room Settings (original or as Game Server instance modified them)

That information is need to be used by Player to perform a connection to the Game Server Instance.

9. The Game Server instance status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After complete initialization, Game Controller service with periodically check (or heartbeat) the Game Server instance status using ``status`` request.

Please note that this request comes from the Game Controller side, to the Game Controller instance:

::

    Controller Service -> { request 'status' } -> Game Server instance

The Game Server instance is required to respond to that request with ``{"status": "ok"}`` object. If other response is received, or no response received in certain time, the Game Server instance will be shot down as “hang”.


Join Room Flow
==============

No matter if the Game Server instance is spawned or not, the Player is required to be joined into the room in order to connect to the Game Server.

The join process ensures that no extra player can join the Game Server due to concurrency issues (as hundreds of Players are constantly join to different Game Servers).

Also, the join process makes the :ref:`access-token` of the Player to be available on the Game Server, yet with no :ref:`access-token` being sent directly to the Game Server (for server-side use) as :ref:`access-token` is a sensitive piece of information and communication between the Game Server instance and the Player if often unencrypted.

1. Room Registration
~~~~~~~~~~~~~~~~~~~~

After the join call, no matter if the Game Server instance have just spawned, or it’s an old room, a registration process on that room is performed. Registration process ensures that:

-  Player has a valid access token for a join
-  Player has not exceeded the join rate limits
-  There is enough space for that Player in the room

Due to concurrency, multiple Players can perform a join request on the same room at the same time, yet it may has only one free slot left. Is that case, only the first one will succeed.

As a response to a successful registration the Master Service will respond to the Player with some information:

-  The host location of the Game Server instance for that room
-  The ports made available for that particular Game Server instance
-  The room registration Key
-  The room Settings (original or as Game Server instance modified them)

The room registration Key is important and acts as a proof that the Player has the right to join that room.

At that point, the registration is temporary and will be released automatically within 30 seconds (as described in ``AUTO_REMOVE_TIME``). To ensure the registration is permanent, the Player need to do the next steps.

2. Connecting
~~~~~~~~~~~~~

Then, the Player connects to the Game Sever instance, using the information in the previous step (such as a host location, or ports). The connection protocol (either UDP or TCP or even both) is completely up to the game.

After the successful connection, the Player sends the room registration Key to the Game Server instance (again, the way it is sent is completely up to the game). If no registration Key is sent within some time, the Game Server instance must drop that connection.

Then, the Game Server instance should try to exchange the registration Key using a JSON-RPC request ``joined``.

Arguments for that command are:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``key``
     - The registration Key
   * - ``extend_token``, ``extend_scopes``
     - (Optional) See step 2a for more information.

.. toggle-header::
    :header: Example of the JSON-RPC Request object

    .. code:: json

        {
            "jsonrpc": "2.0",
            "method": "joined",
            "params": {
                "key": "<Player's registration key>",
                "extend_token": "<see step 2a>",
                "extend_scopes": "<see step 2a>"
            },
            "id": 2
        }

If the request is successful, the Controller will respond:

.. code:: json

    {
        "access_token": "<Player's access token>",
        "account": "<Player's account id>",
        "info": { ... custom player's info },
        "scopes": ["<A list of Player's access token scopes>"]
    }

That token then should be used by the Game Server Instance to communicate with any service in behalf ot the Player (for example, update the Player’s profile, or post a score to a leaderboard etc). The scopes field may be used to give the Player certain admin rights inside the game.

Also, a successful request will make room registration permanent (until the Player leaves the server).

2a. Token Extension
~~~~~~~~~~~~~~~~~~~

If both ``extend_token`` and ``extend_scopes`` are passed diring the ``joined`` request, the :ref:`access-token` of the
player will be `extended <https://github.com/anthill-services/anthill-login/blob/master/doc/API.md#extend-access-token>`__ using ``extend_token``
as master token and ``extend_scopes`` as a list of scopes the Player’s :ref:`access-token` should be extended with.

Token extention is used to do strict actions server side in behalf of the Player while the Player itself cannot. For example,

1. User Authenticates asking for ``profile`` scope. This scope allows only to read user profile, but not to write;
2. The Game Server instance Authenticates itself with ``profile_write`` scope access (allows to modify the profile);
3. The Game Server extends this token to the more powerful one, so server can write the profile in behalf of the Player;
4. At the same time, user still have perfectly working access token, without such possibility;
5. So player can only read Player’s profile, but the Game Server can also write it.

3. Disconnecting
~~~~~~~~~~~~~~~~

Once player left the Game Server instance (intentionally or due to connection error), the Controller needs to be notified about it using the ``left`` request.

Arguments for that command are:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``key``
     - The registration Key

.. toggle-header::
    :header: Example of the JSON-RPC Request object

    .. code:: json

        {
            "jsonrpc": "2.0",
            "method": "left",
            "params": {
                "key": "<Player's registration key>"
            },
            "id": 3
        }

After a successful response, a slot it room is freed for future joins.
