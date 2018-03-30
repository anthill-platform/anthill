.. _environment-service-rest-api:

Get the Environment information
===============================

Returns the environment information based on the application version.
Please note, the environment service location, along with game name and
version should be hardcoded inside the game.

← Request
---------

.. code-block:: bash

    GET /<game-name>/<game-version>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``<game-name>``
     - Name of the current application
   * - ``<game-version>``
     - Current version of the application

→ Response
----------

In case of success, a JSON object with environment information returned:

.. code:: json

    {
        "discovery": "https://dicovery-test.example.com",
        "<custom attribute>": "<custom attribute value defined for the environment>"
    }

