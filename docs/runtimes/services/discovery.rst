Discovery Service
=================

.. note::
    This document covers documentation for Anthill Runtime's implementation for the :doc:`../../services/discovery`.
    If you need the documentation for the actual service, please see :doc:`../../services/discovery` instead.

How To Get Instance
-------------------

.. tabs::

    .. code-tab:: cpp

        DiscoveryServicePtr service =
            online::AnthillRuntime::Instance().get<online::DiscoveryService>();

    .. code-tab:: java

        DiscoveryService service =
            AnthillRuntime.Get(DiscoveryService.ID, DiscoveryService.class);

Discover Services
-----------------

Looks up services.

    .. tabs::

        .. code-tab:: cpp

            void discoverServices(const std::set<std::string>& services, DiscoveryInfoCallback callback);

        .. code-tab:: java

            public void discoverServices(String[] services, final DiscoveryInfoCallback callback)

    .. glossary::

        ``services``

            a set of service's services too lookup

        ``callback``

            the callback that would be called once the services have been found
            (or not, depending on the status argument in the callback)

    Please see :ref:`discovery-service-api-discover` REST API call for more information.
