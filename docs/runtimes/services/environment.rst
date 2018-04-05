Environment Service
===================

.. note::
    This document covers documentation for Anthill Runtime's implementation for the :doc:`../../services/environment`.
    If you need the documentation for the actual service, please see :doc:`../../services/environment` instead.

How To Get Instance
-------------------

.. tabs::

    .. code-tab:: cpp

        EnvironmentServicePtr service =
            online::AnthillRuntime::Instance().get<online::EnvironmentService>();

    .. code-tab:: java

        EnvironmentService service =
            AnthillRuntime.Get(EnvironmentService.ID, EnvironmentService.class);

Get Environment Information
---------------------------

Returns the environment information based on the application version.

    .. note:: The environment service location, along with game name and version should be hardcoded inside the game.

    .. tabs::

        .. code-tab:: cpp

            void getEnvironmentInfo(EnvironmentInfoCallback callback);

        .. code-tab:: java

            public void getEnvironmentInfo(final EnvironmentInfoCallback callback)

    .. glossary::

        ``callback``

            the callback that would be called once the environment information has been received.

    Please see :ref:`environment-service-api-get-environment` REST API call for more information.
