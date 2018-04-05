
.. title:: REST API

Matchmaking
===========

.. contents::
   :local:
   :depth: 1

Search Rooms
------------

Returns a list of rooms.

← Request
~~~~~~~~~

.. code-block:: bash

    GET /rooms/<application_name>/<application_version>/<game_server_name>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``application_name``
     - Name of the game, see :ref:`application-name`
   * - ``application_version``
     - Version of the game, see :ref:`application-version`
   * - ``game_server_name``
     - Game Server Configuration name, see :ref:`game-master-concepts`
   * - ``settings``
     - Optional. A JSON object, filtering room's settings.
   * - ``show_full``
     - Optional, default is ``true``. To return rooms with maximum players capacity reached, or not.
   * - ``my_region_only``
     - Optional, default is ``false``. Return only rooms from my Region. See :ref:`game-master-concepts`
   * - ``region``
     - Optional. Return only rooms from a specific region. Contradicts with ``my_region_only``

Access scope ``game`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with rooms is returned:

::

    {
       "rooms": [<room>, <room>, <room>, ...]
    }

A room object would be::

   {
      "id": <room id>,
      "settings": <room settings>,
      "players": <number of players>,
      "max_players": <maximum number of players>,
      "game_name": <application_name for the room>,
      "game_version": <application_version for the room>,
      "location": <location>
   }

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, rooms follow.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.
   * - ``404 Not Found``
     - No such ``application_name`` / ``application_version`` / ``game_server_name`` combination found


Join to a Room
--------------

"Joins" a player to specific Room by its ID.


← Request
~~~~~~~~~

.. code-block:: bash

    POST /rooms/<application_name>/<room_id>/join

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``application_name``
     - Name of the game, see :ref:`application-name`
   * - ``room_id``
     - A Room ID to join into

Access scope ``game`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with room is returned:

::

   {
      "id": <room id>,
      "settings": <room settings>,
      "players": <number of players>,
      "max_players": <maximum number of players>,
      "game_name": <application_name for the room>,
      "game_version": <application_version for the room>,

      "key": <key>,
      "location": <location>
   }

At that point, the player has very little time window to actually to connect to the Game Server. The last two arguments
in the example above should be used to proceed with connecting to the Game Server.
See :ref:`join-room-flow` for more information.

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, join info follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.
   * - ``404 Not Found``
     - No such room
   * - ``423 Banned``
     - The player has been banned from participating in the Matchmaking.
       See ``X-Ban-Until``, ``X-Ban-Id`` and ``X-Ban-Reason`` HTTP return headers for additional information.


Find a Room and Join into it
----------------------------

Performs a search for appropriate Room and does automatic join into it. Useful for "quick play" type of joins, where
you don't see any rooms before joining.

← Request
~~~~~~~~~

.. code-block:: bash

    POST /join/<application_name>/<application_version>/<game_server_name>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``application_name``
     - Name of the game, see :ref:`application-name`
   * - ``application_version``
     - Version of the game, see :ref:`application-version`
   * - ``game_server_name``
     - Game Server Configuration name, see :ref:`game-master-concepts`
   * - ``settings``
     - Optional. A JSON object, filtering room's settings.
   * - ``auto_create``
     - Optional, default is ``true``. Create a new Room, if there is no suitable one. This will instantiate a new
       Game Server instance. If ``false``, and there is no suitable room, a ``404 Not Found`` will be returned.
   * - ``create_settings``
     - Optional. If ``auto_create`` is ``true``, and new room is being created, these settings will be used for a new
       room.
   * - ``my_region_only``
     - Optional, default is ``false``. Join only in rooms from my Region. See :ref:`game-master-concepts`
   * - ``region``
     - Optional. Join only rooms from a specific region. Contradicts with ``my_region_only``

Access scope ``game`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with room is returned:

::

   {
      "id": <room id>,
      "settings": <room settings>,
      "players": <number of players>,
      "max_players": <maximum number of players>,
      "game_name": <application_name for the room>,
      "game_version": <application_version for the room>,

      "key": <key>,
      "location": <location>
   }

At that point, the player has very little time window to actually to connect to the Game Server. The last two arguments
in the example above should be used to proceed with connecting to the Game Server.
See :ref:`join-room-flow` for more information.

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, join info follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.
   * - ``404 Not Found``
     - No suitable rooms has been found
   * - ``423 Banned``
     - The player has been banned from participating in the Matchmaking.
       See HTTP headers ``X-Ban-Until``, ``X-Ban-Id`` and ``X-Ban-Reason`` returned for additional information.


Find a Room and Join into it for several players
------------------------------------------------

Performs a search for appropriate Room and does automatic join into it, in behalf of several players. Usually done by
authoritative party since ``game_multi`` scope is required. May be useful to perform "quick play" with friends, but
somehow difficult due to the fact that you need authoritative party for it (for example, a Game Server instance itself).

← Request
~~~~~~~~~

.. code-block:: bash

    POST /join/multi/<application_name>/<application_version>/<game_server_name>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``application_name``
     - Name of the game, see :ref:`application-name`
   * - ``application_version``
     - Version of the game, see :ref:`application-version`
   * - ``game_server_name``
     - Game Server Configuration name, see :ref:`game-master-concepts`
   * - ``accounts``
     - A JSON list of accounts ``[1, 20, 444, 888]`` the search fill be performed for. The more accounts the
       more room in the destination room is required.
   * - ``settings``
     - Optional. A JSON object, filtering room's settings.
   * - ``auto_create``
     - Optional, default is ``true``. Create a new Room, if there is no suitable one. This will instantiate a new
       Game Server instance. If ``false``, and there is no suitable room, a ``404 Not Found`` will be returned.
   * - ``create_settings``
     - Optional. If ``auto_create`` is ``true``, and new room is being created, these settings will be used for a new
       room.
   * - ``my_region_only``
     - Optional, default is ``false``. Join only in rooms from my Region. See :ref:`game-master-concepts`.
       Please note, that "my" context is determined from the caller's IP.
   * - ``region``
     - Optional. Join only rooms from a specific region. Contradicts with ``my_region_only``

Access scopes ``game`` and ``game_multi`` are required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with room information is returned, along with keys for individual accounts:

::

   {
      "id": <room id>,
      "settings": <room settings>,

      "slots": <slots>,
      "location": <location>
   }

The slots object is made from keys as account ID's being requested::

   {
      <account-id>: {
         "slot": <slot-id>,
         "key": <key for account>
      },

      1: { "slot": <slot-id>, "key": <a key for account 1> },
      20: { ... },
      444: { ... },
      888: { ... }
   }

The entity that has requested the join needs to pass the information to the appropriate members for them to to proceed
with connecting to the Game Server. See :ref:`join-room-flow` for more information.

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, join info follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.
   * - ``404 Not Found``
     - No suitable rooms has been found


Create Room
-----------

Spawns a new Room (and new Game Server instance) and does automatic join into it.
Useful for cases when existing rooms should be ignored and there should be always a new one.

← Request
~~~~~~~~~

.. code-block:: bash

    POST /create/<application_name>/<application_version>/<game_server_name>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``application_name``
     - Name of the game, see :ref:`application-name`
   * - ``application_version``
     - Version of the game, see :ref:`application-version`
   * - ``game_server_name``
     - Game Server Configuration name, see :ref:`game-master-concepts`
   * - ``settings``
     - These settings will be used for a new room.

.. warning::
   Creating new Room does not allow to pick a region, as it always automatically chosen by caller's geo location.

.. note::
   The caller gets automatically "joined" into the Room, meaning there is no way to create an empty room.

Access scope ``game`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with a new room info is returned:

::

   {
      "id": <room id>,
      "settings": <room settings>,
      "players": <number of players>,
      "max_players": <maximum number of players>,
      "game_name": <application_name for the room>,
      "game_version": <application_version for the room>,

      "key": <key>,
      "location": <location>
   }

At that point, the player has very little time window to actually to connect to the Game Server. The last two arguments
in the example above should be used to proceed with connecting to the Game Server.
See :ref:`join-room-flow` for more information.

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, join info follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.
   * - ``404 Not Found``
     - No suitable rooms has been found
   * - ``423 Banned``
     - The player has been banned from participating in the Matchmaking.
       See HTTP headers ``X-Ban-Until``, ``X-Ban-Id`` and ``X-Ban-Reason`` returned for additional information.

Create Room for several players
-------------------------------

Spawns a new Room (and new Game Server instance) and does automatic join for several players into it.
Useful for cases when a player's list is known beforehand. Usually done by authoritative party since
``game_multi`` scope is required.

← Request
~~~~~~~~~

.. code-block:: bash

    POST /create/multi/<application_name>/<application_version>/<game_server_name>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``application_name``
     - Name of the game, see :ref:`application-name`
   * - ``application_version``
     - Version of the game, see :ref:`application-version`
   * - ``game_server_name``
     - Game Server Configuration name, see :ref:`game-master-concepts`
   * - ``accounts``
     - A JSON list of accounts ``[1, 20, 444, 888]`` the creation fill be performed for.
   * - ``settings``
     - These settings will be used for a new room.

.. warning::
   Creating new Room does not allow to pick a region, as it always automatically chosen by caller's geo location.

.. note::
   The caller gets automatically "joined" into the Room, meaning there is no way to create an empty room.

Access scopes ``game`` and ``game_multi`` are required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with room information is returned, along with keys for individual accounts:

::

   {
      "id": <room id>,
      "settings": <room settings>,

      "slots": <slots>,
      "location": <location>
   }

The slots object is made from keys as account ID's being requested::

   {
      <account-id>: {
         "slot": <slot-id>,
         "key": <key for account>
      },

      1: { "slot": <slot-id>, "key": <a key for account 1> },
      20: { ... },
      444: { ... },
      888: { ... }
   }

The entity that has requested the creation of the Room needs to pass the information to the appropriate members
for them to to proceed with connecting to the Game Server. See :ref:`join-room-flow` for more information.

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, join info follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.
   * - ``404 Not Found``
     - No such Game Server Configuration found


Get Region List
---------------

Returns a current list of regions. Useful as way for the Player to pick the region to look into.

← Request
~~~~~~~~~

.. code-block:: bash

    GET /regions

Access scope ``game`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with regions is returned:

::

   {
      "regions": {
         "<region-id>": <region>,
         "<region-id>": <region>,
         "<region-id>": <region>,
         "<region-id>": <region>
      },
      "my_region": "<region-id>"
   }

``my_region`` is an automatically detected region of the caller.

A region object would be::

   {
      "settings": <custom settings>,
      "location": {
         "x": <Longitude location>,
         "y": <Latitude geo location>
      }
   }

``settings`` are custom JSON object defined in :ref:`admin-tool` and can be used to display additional
information (like title, icon, etc). ``location`` can be used to display that region on a map.

Get Player Game Status
----------------------

Returns Player's "playing" information. If a Player is playing, a record with information would be returned.
Useful to display Player's status, like "playing", "offline", etc.


← Request
~~~~~~~~~

.. code-block:: bash

    GET /player/<account_id>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``account_id``
     - Account ID of the Player in question

Access scope ``game`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with associated records is returned::

   {
      "records": [<record>, <record>]
   }

It is possible for a fraction of a time, for a Player, to have multiple records (for example, player is joining into
some game while being in "lobby" server).

Each of the records would be::

   {
      "id": <room id>,
      "settings": <room settings>,
      "players": <number of players>,
      "max_players": <maximum number of players>,
      "game_name": <application_name for the room>,
      "game_version": <application_version for the room>
   }

Empty ``records`` yield means the Player in question is not playing anywhere.

Get Game Status for several players
-----------------------------------

Returns "playing" information for several players. If Players are playing, a record with information would be returned.
Useful to display Player's status in batch, when you know ID's of each of them, for example, from a leaderboard.

← Request
~~~~~~~~~

.. code-block:: bash

    GET /players

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``accounts``
     - a JSON list of Account ID's ``[1, 2, 444, 888]`` of the Player's in question

Access scope ``game`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with associated records for each player is returned::

   {
      "records": {
         "1": [<record>, <record>],
         "2": [<record>],
         "444": [],
         "888": [<record>]
      }
   }

It is possible for a fraction of a time, for a Player, to have multiple records (for example, player is joining into
some game while being in "lobby" server).

Each of the records would be::

   {
      "id": <room id>,
      "settings": <room settings>,
      "players": <number of players>,
      "max_players": <maximum number of players>,
      "game_name": <application_name for the room>,
      "game_version": <application_version for the room>
   }

Empty ``records`` yield means the Player in question is not playing anywhere.

Banning System
==============

.. contents::
   :local:
   :depth: 1

Issue a ban
-----------

Bans a certain account from participating in Matchmaking (joining servers, etc).

.. note:: Once issued, the player would not be able to join a server with certain account.
    Upon first attempt of player’s join, player’s IP address would be also associated with that ban,
    so joining servers would not be possible from that IP from now on, regardless of the account in question.

← Request
~~~~~~~~~

.. code-block:: bash

    POST /ban/issue

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``account``
     - Player’s account in question
   * - ``reason``
     - Human-readable description of the ban
   * - ``expires``
     - When the ban expires, a date in ``%Y-%m-%d %H:%M:%S`` format.

Access scope ``game_ban`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with ban id is returned:

::

    {
       "id": <ban id>
    }

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, ban information follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.
   * - ``406 Not Acceptable``
     - This user have already been banned

Get ban information
-------------------

Returns existing ban’s information by its ID.

← Request
~~~~~~~~~

.. code-block:: bash

    GET /ban/<ban-id>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``ban-id``
     - Ban ID in question

Access scope ``game_ban`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with ban information is returned:

.. code:: json

    {
        "id": "<ban-id>",
        "reason": "<ban-reason>",
        "expires": "<ban-expire-date>",
        "account": "<account-id>",
        "ip": "<account's-ip>"
    }

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, ban information follows.
   * - ``404 Not Found``
     - Not such ban.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Updated ban information
-----------------------

Updates existing ban by its ID.

← Request
~~~~~~~~~

.. code-block:: bash

    POST /ban/<ban-id>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``ban-id``
     - Ban ID in question
   * - ``reason``
     - Human-readable description of the ban
   * - ``expires``
     - When the ban expires, a date in ``%Y-%m-%d %H:%M:%S`` format.

Access scope ``game_ban`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, nothing is returned.

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, ban has been updated.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Invalidate a ban
----------------

Invalidates existing ban by its ID.

← Request
~~~~~~~~~

.. code-block:: bash

    DELETE /ban/<ban-id>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``ban-id``
     - Ban ID in question

Access scope ``game_ban`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, nothing is returned.

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, ban has been invalidated.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Parties
=======

.. contents::
   :local:
   :depth: 1

Create Party
------------

Creates a fresh new :ref:`party` and returns its information. Please note this request does not open :ref:`party-session`.

← Request
~~~~~~~~~

.. code-block:: bash

    POST /party/create/<application_name>/<application_version>/<game_server_name>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``application_name``
     - Name of the game, see :ref:`application-name`
   * - ``application_version``
     - Version of the game, see :ref:`application-version`
   * - ``game_server_name``
     - Game Server Configuration name, see :ref:`game-master-concepts`
   * - ``party_settings``
     - See :ref:`party-properties`
   * - ``room_settings``
     - See :ref:`party-properties`
   * - ``max_members``
     - See :ref:`party-properties`
   * - ``region``
     - See :ref:`party-properties`
   * - ``auto_start``
     - See :ref:`party-properties`
   * - ``auto_close``
     - See :ref:`party-properties`
   * - ``close_callback``
     - See :ref:`party-properties`

Access scope ``party_create`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with party information is returned:

::

    {
       "party": {
          "id": "<party-id>",
          "num_members": <number-of-members>,
          "max_memvers": <meximum-numver-of-members>,
          "settings": { ... }
       }
    }

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, room information follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Get Party Information
---------------------

Returns :ref:`party` information.

← Request
~~~~~~~~~

.. code-block:: bash

    GET /party/<party-id>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``party-id``
     - Id of the party in question


Access scope ``party`` is required for this request.

→ Response
~~~~~~~~~~

In case of success, a JSON object with party information is returned:

::

    {
       "party": {
          "id": "<party-id>",
          "num_members": <number-of-members>,
          "max_memvers": <meximum-numver-of-members>,
          "settings": { ... }
       }
    }

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, room information follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Close Party
-----------

Closes an existing :ref:`party`.
The called does not have to be the creator of the party, but scope ``party_close`` is required.

← Request
~~~~~~~~~

.. code-block:: bash

    DELETE /party/<party-id>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``party-id``
     - Id of the party in question

Access scope ``party_close`` is required for this request.

→ Response
~~~~~~~~~~

If the party had ``close_callback`` defined, a result of execution of such callback will be returned. Otherwise, and empty ``{}`` is returned.

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, room information follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

.. _create-party-and-open-session:

Create Party And Open Session
------------------------------

Creates a fresh new party and opens a :ref:`party-session` on it.

Web Socket Request
~~~~~~~~~~~~~~~~~~

.. note:: This request is a Web Socket request, meaning that ``HTTP`` session will be upgraded to a Web Socket session.

.. code-block:: bash

    WEB SOCKET /party/create/<application_name>/<application_version>/<game_server_name>/session

.. list-table::`
   :header-rows: 1

   * - Argument
     - Description
   * - ``application_name``
     - Name of the game, see :ref:`application-version`
   * - ``application_version``
     - Version of the game, see :ref:`application-version`
   * - ``game_server_name``
     - Game Server Configuration name, see :ref:`game-master-concepts`

Additional query artuments:

.. list-table::
   :header-rows: 1

   * - Query Argument
     - Description
   * - ``party_settings``
     - See :ref:`party-properties`
   * - ``room_settings``
     - See :ref:`party-properties`
   * - ``max_members``
     - See :ref:`party-properties`
   * - ``region``
     - See :ref:`party-properties`
   * - ``auto_start``
     - See :ref:`party-properties`
   * - ``auto_close``
     - See :ref:`party-properties`
   * - ``close_callback``
     - See :ref:`party-properties`
   * - ``auto_join``
     - If ``true`` (default), the current memmber will be joined to a new session automatically.
   * - ``member_profile``
     - If ``auto_join`` is ``true``, this would be used to define member’s profile. See Member Properties

Access scope ``party_create`` is required for this request.

Connect To Existing Party
--------------------------

Connects to existing :ref:`party` and opens a :ref:`party-session` on it.

Web Socket Request
~~~~~~~~~~~~~~~~~~

.. note:: This request is a Web Socket request, meaning that ``HTTP`` session will be upgraded to a Web Socket session.

.. code-block:: bash

    WEB SOCKET /party/<party_id>/session

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``party_id``
     - Id of the party in question

Additional query artuments:

.. list-table::
   :header-rows: 1

   * - Query Argument
     - Description
   * - ``auto_join``
     - If ``true`` (default), the current memmber will be joined to a new session automatically.
   * - ``member_profile``
     - If ``auto_join`` is ``true``, this would be used to define member’s profile. See Member Properties
   * - ``check_members``
     - If ``auto_join`` is ``true``, this Profile Object may be used to theck ALL of the members for certain condition, or the automatic join will fail.

Access scope ``party`` is required for this request.

Find A Party And Open Session
------------------------------

Find a :ref:`party` (possibly creates a new one) and opens a :ref:`party-session` on it.

Web Socket Request
~~~~~~~~~~~~~~~~~~

.. note:: This request is a Web Socket request, meaning that ``HTTP`` session will be upgraded to a Web Socket session.

.. code-block:: bash

    WEB SOCKET /parties/<application_name>/<application_version>/<game_server_name>/session

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``application_name``
     - Name of the game, see :ref:`application-name`
   * - ``application_version``
     - Version of the game, see :ref:`application-version`
   * - ``game_server_name``
     - Game Server Configuration name, see :ref:`game-master-concepts`

Additional query arguments:

.. list-table::
   :header-rows: 1

   * - Query Argument
     - Description
   * - ``party_filter``
     - A filter to search the parties for. This argument is required.
   * - ``auto_create``
     - To automatically create a new party if there’s no party that satisfies ``party_filter``. Please note that if ``auto_create`` is ``true``, access scope ``party_create`` is required.
   * - ``member_profile``
     - Member’s profile. See :ref:`party-member-properties`

If ``auto_create`` is ``true``, these arguments are expected:

.. list-table::
   :header-rows: 1

   * - Query Argument
     - Description
   * - ``create_party_settings``
     - ``party_settings`` in :ref:`party-properties`
   * - ``create_room_settings``
     - ``room_settings`` in :ref:`party-properties`
   * - ``create_room_filters``
     - ``room_filters`` in :ref:`party-properties`
   * - ``max_members``
     - See :ref:`party-properties`
   * - ``region``
     - See :ref:`party-properties`
   * - ``create_auto_start``
     - ``auto_start`` in :ref:`party-properties`
   * - ``create_auto_close``
     - ``auto_close`` in :ref:`party-properties`
   * - ``create_close_callback``
     - ``close_callback`` in :ref:`party-properties`

The ``auto_join`` cannot be defined in this argumend as it will always do automatically join.

Access scope ``party`` is required for this request.
