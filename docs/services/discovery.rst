Discovery Service
=================

Some things never change. Most of them do: as the game grows, you often
need to move servers around. This service allows to discover each
service dynamically, at runtime.

Each service is represented by few things: service ``ID`` and service
locations.

.. seealso::
   `Source Code <https://github.com/anthill-platform/anthill-discovery>`_

Multiple networks
-----------------

Not only players use discovery service, but other services do. If some
service needs some other service location, it uses discovery API to find
out.

Yet often services need to use internal routes to communicate with other
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

Disclaimer
----------

.. warning:: This service does not acts as a load balancer. Services in question need
   to be behind a load balancer themselves, for example behind ``nginx``.

REST API
--------

.. toctree::
   :maxdepth: 1

   discovery/api
