About Multiple networks
=======================

Often services need to use internal routes to communicate with other
services for security reasons. That’s why discovery service has multiple
networks defined: ``external`` and ``internal``. The ``external``
network is used by end users, and available online from the web.

On the other hand, the ``internal`` network is only accessible from
inside of the Anthill Platform. Often, services give more privileges for
internal requests. Some requests can only be called from the inside.
Even the ``internal`` location of a service can be discovered only from
the inside.

Each service has a list of IP addresses, request from who is considered
to be internal, usually it’s a local subnet, like ``10.0.0.0/24``.

Discover service
================

Returns the service’s ``external`` location.

← Request
---------

.. code-block:: bash

    GET /service/<service-id>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``<service-id>``
     - ID of the required service

→ Response
----------

In case of success, a complete URL of the service is returned:

.. code-block:: bash

    https://login-dev.anthillplatfrom.org/v0.1

This URL should be used as a base. For example, if service provides api
called ``auth``, the request would be:

.. code-block:: bash

    POST https://login-dev.anthillplatfrom.org/v0.1/auth

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, service location follows.
   * - ``404 Not Found``
     - No such Service found

Discover multiple services
==========================

Returns a location for multiple services at a same time. Same as request
above, but for multiple services.

← Request
---------

.. code-block:: bash

    GET /services/<services>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``<services>``
     - Comma-separated list of service ID’s to return location about

→ Response
----------

In case of success, a JSON object with complete URLs of the services is
returned:

.. code:: json

    {
        "login": "https://login-dev.anthillplatfrom.org/v0.1",
        "profile": "https://profile-dev.anthillplatfrom.org/v0.1"
    }

These URLs should be used as a base, same as in request above.

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, locations of services follows.
   * - ``404 Not Found``
     - One of the requested services cannot be found.

Discover service’s location for a network
=========================================

Returns the service’s location for a give network.

**Only available from the ``internal`` network.**

← Request
---------

.. code-block:: bash

    GET /service/<service-id>/<network>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``<service-id>``
     - ID of the required service
   * - ``<network>``
     - A network to return location from. For example, ``internal``.

→ Response
----------

Please note that ``internal`` locations are not accessable from the
outside.

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, service location follows.
   * - ``404 Not Found``
     - No such Service found

Discover multiple services, for a network
=========================================

Returns a location for multiple services at a same time, for a given
network. Same as request above, but for multiple services.

← Request
---------

.. code-block:: bash

    GET /services/<services>/<network>

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``<services>``
     - Comma-separated list of service ID’s to return location about
   * - ``<network>``
     - A network to return locations from. For example, ``internal``.

→ Response
----------

In case of success, a JSON object with complete URLs of the services is
returned. Please note that ``internal`` locations are not accessible
from the outside.

