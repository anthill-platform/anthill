
.. _party:

Party
=====

Party is an group of members (potentially players) that can be created without actually instantiating a Game Server.

In certain cases, partying players together is even required before the actual Game Server being started up:

-  You want to start the Game Server only when full room of people is matched;
-  Players want to discuss the future map / game mode before starting the game;
-  Players want to join a random game with their friends.

If you would like to see the REST API for the parties, see Party REST API section below.

Party Flow
==========

Each party has several “states”. The final goal of the party is to find or create a Game Server, then destroy itself.

1. Party is created either by some player or by a service;
2. Members open a Party Session upon it, using it the members can join into the party, send messages to eachother etc.
3. Either by autometic trigger, or manually by some member, the party can be “started”, meaning an actuall Game Server is instantiated, with appropriate party settings;
4. The memberss are relocated into the Game Server and become players by receving a notification from the Party Session;
5. The party itself is destroyed.

.. _party-properties:

Party Properties
================

Each party has a set of properties:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Name
     - Description
   * - ``party_settings``
     - Abstract JSON object of party-related settings, completely defined by the game. Parties can be found using these settings (see ``party_filter`` argument on some requests below)
   * - ``room_setting``
     - Abstract JSON object of the actual room settings that will be applied to the Game Server once the party starts (if the ``room_filter`` below is defined, and an existing room has been found, this field is ignored)
   * - ``room_filter``
     - (Optional) If defined the party will search for appropriate room first upon party startup, instead of creating a new one.

Additional properties:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Name
     - Description
   * - ``max_members``
     - (Optional) Maximum number of party members, default is ``8``
   * - ``auto_start``
     - (Optional) If ``true`` (default), the party will automatically start once the party gets full (reaching ``max_members`` number of members). If ``false``, nothing will happen.
   * - ``auto_close``
     - (Optional) If ``true`` (default), the party will be destroyed automatically once the last member leaves. If ``false``, the empty party will remain.
   * - ``region``
     - (Optional) A Region to start the Game Server on, default is picked automatically upon party creator’s IP.
   * - ``close_callback``
     - (Optional) If defined, a callback function of the Exec Service with that name that will be called once the party is closed (see ``Server Code``). Please note that this function should allow calling (``allow_call = true``)

.. _party-member-properties:

Member Properties
=================

Besides the actual party, each member in it can have his unique properties:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Name
     - Description
   * - ``member_profile``
     - A small JSON Object to represent the member. For example, that might be a desired color, or avatar URL of caching. This object is passed to the Game Server, so it can be used by it.
   * - ``member_role``
     - A number, defining how much power the member has within the party`. This number is also passed to the Game Server.

Roles are as follows:

-  At least ``500`` role is required to start the party manually.
-  At least ``1000`` role is required to close the party manually.
-  The creator of the party gets ``1000`` role.
-  The regular member of the party gets ``0`` role.
-  As of currently, there is no way to change roles, so only the creator of the party can start is manually or force party closure.

.. _party-session:

Party Session
=============

Party Session is a Web Socket session that allows members to have real-time communication within a party.

The actual communication is made within JSON-RPC 2.0 protocol.
In short, a JSON-RPC protocol allows two nodes to send each other requests,
end receive responses (in form of JSON objects):

::

    Current Party Member -> { request JSON object } -> Game Service
    Current Party Member  <- { response JSON object } <- Game Service

.. _party-session-initialization:

Party Session Initialization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Party Session is is initialized in few steps:

1. The user opens a Web Socket connection on the one of the :ref:`possible endpoints <create-party-and-open-session>`
2. The user then waits for the ``party`` :ref:`Session Callback <party-session-callbacks>`
3. Once the callback is received, the Party Session is now considered initialized and the user is free to do the :ref:`party-session-methods`

.. warning::
    Please note that a Party Session is not considered successfully initialized until a ``party`` session callback
    had been received. Please see :ref:`party-session-callbacks`.

Party Session Joining
~~~~~~~~~~~~~~~~~~~~~

The member can either join the party, or not. In both cases the connection can still remain.
``max_members`` only applies to joined members, so there can be more connected sessions to a
party than a maximum members capacity.

Party members can be “not joined” into the party and still send and receive messages.
That make the whole ``join`` functionality to be more like ``ready``.

.. _party-session-methods:

Session Methods
~~~~~~~~~~~~~~~

.. toggle-header::
    :header: Example of the JSON-RPC Request **Show/Hide Code**

    .. code:: json

        {
            "jsonrpc": "2.0",
            "method": "send_message",
            "params": {
                "payload": {
                    "text": "hello"
                }
            },
            "id": 1
        }

    Response Object:

    .. code:: json

        {
            "jsonrpc": "2.0",
            "result": "OK",
            "id": 1
        }

``send_message(payload)`` – to send any message object (defined with argument ``payload``) to all other members of the session.

    This could be used for chat or in-game requests etc

``close_party(message)`` – to close the current party.

    ``message`` argument defines any object that would be delivered to other party members upon closing the party.

    Please note that party member needs to have at least ``1000`` role to close a party.

``leave_party`` – to leave the current party.

    As the connection still open, the member will still receive any in-party members, but if the party starts, the members who left the party won’t be transferred to a Game Server.

``join_party(member_profile, check_members)`` – to join the party back.

    This can be done automatically upon session creation.

    ``member_profile`` – see Member Properties.

    ``check_members`` – optional Profile Object that may be used to theck ALL of the members for certain condition, or the join will fail.

    .. toggle-header::
        :header: Example **Show**

        This complex function will ensure that no more 2 members in the party, that have field ``clan-name`` of their
        ``member_profile`` equal to ``TEST_CLAN``, meaning there could be only two members total from clan ``TEST_CLAN``.

        .. code:: json

             {
                 "members": {
                     "@func": "<",
                     "@cond": 2,
                     "@value": {
                         "@func": "num_child_where",
                         "@test": "==",
                         "@field": "clan-name",
                         "@value": "TEST_CLAN"
                     }
                 }
             }

``start_game(message)`` – to manually start the game.

   ``message`` argument defines any object that would be delivered to other party members upon starting the game.

   Please note that party member needs to have at least ``500`` role to start the game manually.

.. _party-session-callbacks:

Session Callbacks
~~~~~~~~~~~~~~~~~

The party session may call some reqests methods too, meaning a Game Service initiates conversation.

::

    Game Service -> { request JSON object } -> Current Party Member
    Game Service <- { response JSON object } <- Current Party Member

``party(party_info)`` – The party in question has been initialized

    .. toggle-header::
        :header: JSON-RPC Example Of "party" message **Show**

        .. code-block:: json

            {
                "jsonrpc": "2.0",
                "method": "party",
                "params": {
                    "party_info": {
                        "party": {
                            "id": "10",
                            "num_members": 1,
                            "max_members": 2,
                            "settings": {}
                        },
                        "members": [
                            {
                                "account": "10", "role": 1000, "profile": {}
                            }
                        ]
                    }
                },
                "id": 1
            }

    ``party_info`` is a JSON object of following format::

        {
            "party": {
                "id": "<party-id>",
                "num_members": <current number of party members>,
                "max_members": <maximum number of party members>,
                "settings": <current party settings>
            },
            "members": [<member>, <member>, <member>, ...]
        }

    Where each ``member`` would be::

        {
            "account": "<account-id>",
            "role": <role>,
            "profile": <member-profile>
        }

``message(message_type, payload)`` – some message has been received by a party member

    .. toggle-header::
        :header: JSON-RPC Example Of "message" message **Show**

        .. code-block:: json

            {
                "jsonrpc": "2.0",
                "method": "message",
                "params": {
                    "message_type": "custom",
                    "payload": {
                        "text": "hello"
                    }
                },
                "id": 1
            }

    ``message_type`` is a type of message, the ``payload`` depends on the ``message_type``

    .. list-table::
        :header-rows: 1

        * - Message Type
          - Description
          - Payload
        * - ``player_joined``
          - A new member has joined the party.
          - A JSON Object with fields: ``account`` – an account ID of the member, ``profile`` – a ``member_profile`` of the member
        * - ``player_left``
          - A member has left the party.
          - A JSON Object with fields: ``account`` – an account ID of the member, ``profile`` – a ``member_profile`` of the member
        * - ``game_starting``
          - The game is about to start as a Game Server is being instantiated
          - As described in ``start_game`` request
        * - ``game_start_failed``
          - Somehow the Game Server instantiation has failed
          - A JSON Object with fields: ``reason``, ``code``
        * - ``game_started``
          - A game has successfully started, now the party is about to be closed. The client has now connect to the Game Server as described here
          - A JSON Object with fields: ``id`` – room ID, ``slot`` – current player’s slot in this room, ``key`` – a room secret key, ``location`` – a location of the instantiated Game Server, ``settings`` – newly created room’s settings
        * - ``custom``
          - A custom message, being sent by ``send_message``
          - As described in ``send_message``
        * - ``party_closed``
          - The party is being closed, expect the WebSocket communication to be closed as well.
          - As described in ``close_party``

Please refer to :ref:`party-session-initialization` on how to open a Party Session.

Identifying A Party
===================

A Game Server can detect if it’s being launched in a party context with environment variables.

-  ``party:id`` is such environment variable exists, then the Game Server is started in party context, and the variable contains id of the party. Please note this can be used for references only as the actual party may be destroyed at that point.
-  ``party:settings`` a ``party_settings`` from Party Properties.
-  ``party:members`` a JSON object with initial party members list in following format:

   ::

       {
          "<account-id>": {
             "profile": <member-profile>,
             "role": <member-role>
          }
       }

   Please note that this list is not exslusionary as players can connect from another parties later (see below)

Late connection
~~~~~~~~~~~~~~~

In some cases, party members can join the Game Server way after creation of it. For example, if ``room_filter`` is defined inside the party, the existing Game Server will be searched before creating a new one. In that case the party members may connect to existing Game Server that was spawned by another party (or without any party at all).

To deal with this, a Game Server can identify a party member by parsing the ``info`` object of the ``joined`` controller request response. The ``info`` object may contain these fields: ``party:id``, ``party:profile``, ``party:role``, their definitions are described above.

See Game Controller Connecting Flow for the information about the ``joined`` request.
