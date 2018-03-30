
.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation
   puppet
   services
   development

Anthill Platform
==============================

An open source back-end platform for games that solves the **online** problem.

-  **Self-hosted**. You have full control over the system. That makes it cheaper to maintain and a lot easier to modify.
-  **Open Source**. Under MIT License, actively maintained, with no black box stuff inside.
-  **Scalable**. Each service is easily scalable since the whole system works like an anthill itself: add more workers into it and they will do the job.
-  **Easy to customise**. It can hold any type of game, because it's designed to be as much abstract as possible. The way it acts is completely up to the game.
-  **Unified**. Each service follows standards so its behaviour is predictable. Implement few interfaces and your new service is ready to be plugged in!
-  **A platform**. Not just a complete solution, it's a platform. If there is no service that meets your exact requirements, you can easily create a new one!

Runtimes
--------

It also comes with game client runtimes for various programming
languages for quick start. They allow to interact with services and
handle most of core tasks under the hood.

- `Java`_
- `Unity`_
- `C++`_

Installation
------------

Please see :doc:`installation` for a simple instruction on how to install
Anthill Platform on a Linux machine.

If you'd like to test it out on Mac, please see :doc:`development`.

Core services
-------------

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Service
     - Description
   * - `environment`_
     - Define a set of environments and dynamically assign each game version to any of those
   * - `discovery`_
     - Discover each service location dynamically by it’s ID
   * - `login`_
     - Solves authentication. Login using any kind of credential (like google or facebook), or your own
   * - `profile`_
     - Manages user profiles. Just a plain JSON object, completely defined by a game
   * - `social`_
     - Social interactions (social network’s friend list etc)
   * - `config`_
     - Delivers dynamic configuration to the user using handy schema editor
   * - `leaderboard`_
     - Competes users around by anything
   * - `exec`_
     - Server-side game-depended javascript code execution (validation and so on)
   * - `event`_
     - Time-Limited events service
   * - `common`_
     - A shared library with common functionality for each service
   * - `admin`_
     - Internal service, allows to manage every service across the environment using web browser
   * - `dlc`_
     - Downloadable content delivery service
   * - `game`_
     - Matchmaking service, allows to start any game server to a server side, and match users around it
   * - `message`_
     - Delivers messages from anything to anything, realtime
   * - `store`_
     - Monetization service
   * - `promo`_
     - Promo codes service
   * - `static`_
     - Simple static files hosting service (for players to upload)
   * - `report`_
     - Service for players to post reports to the service. Later the reports can be analyzed and used.

.. _Java: https://github.com/anthill-platform/anthill-runtime-java/
.. _Unity: https://github.com/anthill-platform/anthill-runtime-unity/
.. _C++: https://github.com/anthill-platform/anthill-runtime-cpp/

.. _environment: https://github.com/anthill-platform/anthill-environment/
.. _discovery: https://github.com/anthill-platform/anthill-discovery/
.. _login: https://github.com/anthill-platform/anthill-login/
.. _profile: https://github.com/anthill-platform/anthill-profile/
.. _social: https://github.com/anthill-platform/anthill-social/
.. _config: https://github.com/anthill-platform/anthill-config/
.. _leaderboard: https://github.com/anthill-platform/anthill-leaderboard/
.. _exec: https://github.com/anthill-platform/anthill-exec/
.. _event: https://github.com/anthill-platform/anthill-event/
.. _common: https://github.com/anthill-platform/anthill-common/
.. _admin: https://github.com/anthill-platform/anthill-admin/
.. _dlc: https://github.com/anthill-platform/anthill-dlc/
.. _game: https://github.com/anthill-platform/anthill-game-master/
.. _message: https://github.com/anthill-platform/anthill-message/
.. _store: https://github.com/anthill-platform/anthill-store/
.. _promo: https://github.com/anthill-platform/anthill-promo/
.. _static: https://github.com/anthill-platform/anthill-static/
.. _report: https://github.com/anthill-platform/anthill-report/

