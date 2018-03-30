
Issue a ban
===========

Bans a certain account from participating in game service (joining servers, etc).

.. note:: Once issued, the player would not be able to join a server with certain account.
    Upon first attempt of player’s join, player’s IP address would be also associated with that ban,
    so joining servers would not be possible from that IP from now on, regardless of the account in question.

← Request
---------

.. code-block:: bash

    POST /ban/issue

.. list-table::
   :widths: 50 50
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
----------

In case of success, a JSON object with ban id is returned:

::

    {
       "id": <ban id>
    }

.. list-table::
   :widths: 50 50
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
===================

Returns existing ban’s information by its ID.

← Request
---------

.. code-block:: bash

    GET /ban/<ban-id>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``ban-id``
     - Ban ID in question

Access scope ``game_ban`` is required for this request.

→ Response
----------

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
   :widths: 50 50
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
=======================

Updates existing ban by its ID.

← Request
---------

.. code-block:: bash

    POST /ban/<ban-id>

.. list-table::
   :widths: 50 50
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
----------

In case of success, nothing is returned.

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, ban has been updated.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Invalidate a ban
================

Invalidates existing ban by its ID.

← Request
---------

.. code-block:: bash

    DELETE /ban/<ban-id>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``ban-id``
     - Ban ID in question

Access scope ``game_ban`` is required for this request.

→ Response
----------

In case of success, nothing is returned.

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, ban has been invalidated.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Create Party
============

Creates a fresh new :ref:`party` and returns its information. Please note this request does not open :ref:`party-session`.

← Request
---------

.. code-block:: bash

    POST /party/create/<game_name>/<game_version>/<game_server_name>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``game_name``
     - Name of the game
   * - ``game_version``
     - Version of the game
   * - ``game_server_name``
     - Game-related preset of the server, must be defined as with usual Game Server instantiation
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
----------

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
   :widths: 50 50
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, room information follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Get Party Information
=====================

Returns :ref:`party` information.

← Request
---------

.. code-block:: bash

    GET /party/<party-id>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``party-id``
     - Id of the party in question


Access scope ``party`` is required for this request.

→ Response
----------

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
   :widths: 50 50
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, room information follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Close Party
===========

Closes an existing :ref:`party`.
The called does not have to be the creator of the party, but scope ``party_close`` is required.

← Request
---------

.. code-block:: bash

    DELETE /party/<party-id>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``party-id``
     - Id of the party in question

Access scope ``party_close`` is required for this request.

→ Response
----------

If the party had ``close_callback`` defined, a result of execution of such callback will be returned. Otherwise, and empty ``{}`` is returned.

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, room information follows.
   * - ``400 Bad Arguments``
     - Some arguments are missing or wrong.

Create Party And Open Session
==============================

Creates a fresh new party and opens a Party Session on it.

← Web Socket Request
--------------------

.. note:: This request is a Web Socket request, meaning that ``HTTP`` session will be upgraded to a Web Socket session.

.. code-block:: bash

    WEB SOCKET /party/create/<game_name>/<game_version>/<game_server_name>/session

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``game_name``
     - Name of the game
   * - ``game_version``
     - Version of the game
   * - ``game_server_name``
     - Game-related preset of the server, must be defined as with usual Game Server instantiation

Additional query artuments:

.. list-table::
   :widths: 50 50
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
==========================

Connects to existing :ref:`party` and opens a :ref:`party-session` on it.

← Web Socket Request
--------------------

.. note:: This request is a Web Socket request, meaning that ``HTTP`` session will be upgraded to a Web Socket session.

.. code-block:: bash

    WEB SOCKET /party/<party_id>/session

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``party_id``
     - Id of the party in question

Additional query artuments:

.. list-table::
   :widths: 50 50
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
==============================

Find a :ref:`party` (possibly creates a new one) and opens a :ref:`party-session` on it.

← Web Socket Request
--------------------

.. note:: This request is a Web Socket request, meaning that ``HTTP`` session will be upgraded to a Web Socket session.

.. code-block:: bash

    WEB SOCKET /parties/<game_name>/<game_version>/<game_server_name>/session

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``game_name``
     - Name of the game
   * - ``game_version``
     - Version of the game
   * - ``game_server_name``
     - Game-related preset of the server, must be defined as with usual Game Server instantiation

Additional query arguments:

.. list-table::
   :widths: 50 50
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
   :widths: 50 50
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
