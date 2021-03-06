Game Master Service
===================

When it comes to hosting a server for a multiplayer game, major problems appear:

1. Game servers actually need to be put somewhere;
2. The life cycle of the game server need to be maintained (as game servers may crash or become outdated);
3. The players should be “matchmaked” either by region (to ensure low latency) or by custom set or/and rules (completely game-specific, for example, a user level, map, or game mode);
4. The system overall must be scalable to add new servers into the pool when the concurrent players number explode;
5. Binary files of the game server need to be deployed to all host machines (the more machines are, harder it is).

This service solves them all, the rest is completely up to the game.

.. note::
   Game Master Service covers one part of the matchmaking services only. See :doc:`game-controller` for another part.

.. seealso::
   :anthill-service-source:`Source Code <game-master>`

.. _game-master-concepts:

Concepts
--------

Game Service is actually made out of two services: a Master Service and a Controller Service.

.. glossary::

   Master Service
      Master Service is a part of Game Service that holds the information about all rooms and balances Players
      across multiple Hosts. Also it heartbeats health status of each Host and routes Players to a
      healthy one if some Host dies.

   Controller Service
      Controller Service is a second part of Game Service. It runs on a certain Host and spawns Game Server instance
      on it when requested by Master Service. Also it heartbeats health status of each Game Server running on Host and
      stops it if it stops responding or crashes. See Controller Service documentation.

   Room
      Room represents a single game instance the player may join. Each room has a limit of maximum players on it
      and may contain custom setting to search upon.

   Game Server
      Game Server (GS) is a completely game-specific piece of software that runs server side, holds a single game
      instance and a may be addressed by according room.

   Game Server Configuration
      Game Server Configuration is a way to launch same piece of software (particularly Game Servers) in different
      "modes", each of whom could serve totally different purpose.

      For example, you can have a ``lobby`` configuration to gather players together before actual games, and
      ``main`` configuration for actual games. These two configurations have different options tuned, but ran by the
      same software.

   Host
      Host is actually a single hardware machine that can run multiple Game Servers on itself.
      Since only limited number of Game Servers can be spawned on each host due to hardware limitations,
      multiple hosts may be grouped by a Region.

   Region
      Region is a group of Hosts (even with a single one) that physically located on a same geographical region
      (or Data Center). Players may search rooms only on certain Region to ensure low latency.

   Party
      In certain cases, partying players together is required before (or without)
      the actual Game Server being instantiated:

         -  You want to start the Game Server only when full room of people is matched;
         -  Players want to discuss the future map / game mode before starting the game;
         -  Players want to join a random game with their friends.

Overall Architecture
--------------------

.. image:: images/game_service_architecture.png
    :width: 760px

Flow charts
-----------

.. toctree::
   :maxdepth: 1

   game-master/flow

REST API
--------

.. toctree::
   :maxdepth: 2

   game-master/api


Party documentation
-------------------

.. toctree::
   :maxdepth: 1

   game-master/party


JSON-RPC Communication Flow
---------------------------

.. toctree::
   :maxdepth: 1

   game-master/json-rpc
