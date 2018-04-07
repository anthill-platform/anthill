
.. _controller-service-json-rpc:

Controller Service JSON-RPC API
===============================

This section describes API calls that Game Server instance can make to the Controller Service.

Initialized Request
-------------------

Called when the Game Server instance is completely initialized and ready to accept new players.

← Request
^^^^^^^^^

Method Name: ``inited``. Arguments:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``settings``
     - (Optional) Update room settings along with initialization

If the argument ``settings`` passed along the request, the rooms settings is updated with that argument. For example, if player requested to create a room with ``{"map": "badone"}`` and the Game Server instance realized there is no such map, in can choose the other map instead, and pass ``{"map": "goodone"}`` as the ``settings`` argument to the ``inited`` call. That would lead to the room have correct map setting no matter what setting the Player have passed.

→ Response
^^^^^^^^^^

The Controller will respond ``{"status": "OK"}`` to that request if everything went fine. If the error is returned instead, the Game Server instance should exit the process (and will be forced to at some point).

Player Joined Request
---------------------

Called once a Player connected to the Game Server instance. That call with exchange a Player’s registration Key for Player’s ``Access Token``, at the same time making Player registration inside of the Room permanent.

.. _request-1:

← Request
^^^^^^^^^

Method Name: ``joined``. Arguments:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``key``
     - The registration Key
   * - ``extend_token``, ``extend_scopes``
     - (Optional) See step 2a for more information.

If both ``extend_token`` and ``extend_scopes`` are passed diring the ``joined`` request, the ``Access Token`` of the player will be `extended <https://github.com/anthill-services/anthill-login/blob/master/doc/API.md#extend-access-token>`__ using ``extend_token`` as master token and ``extend_scopes`` as a list of scopes the Player’s ``Access Token`` should be extended with.

Token extention is used to do strict actions server side in behalf of the Player while the Player itself cannot. For example,

1. User Authenticates asking for ``profile`` scope. This scope allows only to read user profile, but not to write;
2. The Game Server instance Authenticates itself with ``profile_write`` scope access (allows to modify the profile);
3. The Game Server extends this token to the more powerful one, so server can write the profile in behalf of the Player;
4. At the same time, user still have perfectly working access token, without such possibility;
5. So player can only read Player’s profile, but the Game Server can also write it.

.. _response-1:

→ Response
^^^^^^^^^^

If the request is successful, the Controller will respond:

.. code:: json

    {
        "access_token": "<Player's access token>",
        "scopes": ["<A list of Player's access token scopes>"]
    }

Player Left Request
-------------------

Called once a Player disconnected from the Game Server instance. That call will remove Player’s registration from the Room allowing other Players to connect to the Room.

.. _request-2:

← Request
^^^^^^^^^

Method Name: ``left``. Arguments:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``key``
     - The registration Key

.. _response-2:

→ Response
^^^^^^^^^^

If the request is successful, the Controller will respond with empty object ``{}``

Update Room Settings Request
----------------------------

Called once Game Server instance decided to update room settings (for example, a map or mode have just changed)

.. _request-3:

← Request
^^^^^^^^^

Method Name: ``update_settings``. Arguments:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``settings``
     - New settings for the Room

.. _response-3:

→ Response
^^^^^^^^^^

If the request is successful, the Controller will respond with empty object ``{}``

Check Game Server Deployment Request
------------------------------------

Called to check if the Game Server instance is still up to date (the game version may be disabled from spawning, or a new Game Server Deployment is available). Once the deployment is not valid anymore, the Game Server instance may decide to gracefully shut down at the end of

.. _request-4:

← Request
^^^^^^^^^

Method Name: ``check_deployment``. No arguments.

.. _response-4:

→ Response
^^^^^^^^^^

If the deployment is still up to date, the Controller will respond with empty object ``{}``. Otherwise, an error will be returned, with the explanation.

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Error Code
     - Description
   * - 404
     - The game version is turned off or there is no such game version
   * - 410
     - Current deployment is outdated

d like to have a few keys with same name, put a new one under different gamespace.
