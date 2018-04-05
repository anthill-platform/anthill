
.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation
   puppet
   services
   development
   runtimes
   concepts

Anthill Platform
================

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

Please refer to :doc:`runtimes` for additional information.

Installation
------------

Please see :doc:`installation` for a simple instruction on how to install
Anthill Platform on a Linux machine.

If you'd like to test it out on Mac, please see :doc:`development`.

Core Services List
------------------

.. list-table::
   :widths: 20 60 20
   :header-rows: 1

   * - Service
     - Description
     - Source Code
   * - :doc:`services/environment`
     - Define a set of environments and dynamically assign each game version to any of those
     - :anthill-service-source:`Source Code <environment>`
   * - :doc:`services/discovery`
     - Discover each service location dynamically by it’s ID
     - :anthill-service-source:`Source Code <discovery>`
   * - :doc:`services/login`
     - Login using any kind of credential (like google or facebook), or your own
     - :anthill-service-source:`Source Code <login>`
   * - :doc:`services/profile`
     - Manages user profiles, plain JSON objects, completely defined by a game
     - :anthill-service-source:`Source Code <profile>`
   * - :doc:`services/social`
     - Social interactions (social network’s friend list etc)
     - :anthill-service-source:`Source Code <social>`
   * - :doc:`services/config`
     - Delivers dynamic configuration to the user using handy schema editor
     - :anthill-service-source:`Source Code <config>`
   * - :doc:`services/leaderboard`
     - Competes users around by anything
     - :anthill-service-source:`Source Code <leaderboard>`
   * - :doc:`services/exec`
     - Server-side game-depended javascript code execution (validation and so on)
     - :anthill-service-source:`Source Code <exec>`
   * - :doc:`services/event`
     - Time-Limited events service
     - :anthill-service-source:`Source Code <event>`
   * - :doc:`services/common`
     - A shared library with common functionality for each service
     - :anthill-service-source:`Source Code <common>`
   * - :doc:`services/admin`
     - Manage every service using a web browser
     - :anthill-service-source:`Source Code <admin>`
   * - :doc:`services/dlc`
     - Downloadable content delivery service
     - :anthill-service-source:`Source Code <dlc>`
   * - :doc:`services/game`
     - Matchmaking service, hosts any game server, and matches users around it
     - :anthill-service-source:`Source Code <game>`
   * - :doc:`services/message`
     - Delivers messages from anything to anything, realtime
     - :anthill-service-source:`Source Code <message>`
   * - :doc:`services/store`
     - Monetization service
     - :anthill-service-source:`Source Code <store>`
   * - :doc:`services/promo`
     - Promo codes service
     - :anthill-service-source:`Source Code <promo>`
   * - :doc:`services/static`
     - Simple static files hosting service (for players to upload)
     - :anthill-service-source:`Source Code <static>`
   * - :doc:`services/report`
     - Service for players to post reports to the service
     - :anthill-service-source:`Source Code <report>`
