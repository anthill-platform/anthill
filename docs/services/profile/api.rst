
.. title:: REST API

Get User Profile For Current User
=================================

Returns a :ref:`user-profile` for a current account.

← Request
---------

.. code-block:: bash

    GET /profile/me [/<path>]

.. list-table::
    :header-rows: 1
    :widths: 20 80

    * - Argument
      - Description
    * - ``path``
      - Optionally, adding additional directories to the request would make the service to return only part of the
        :ref:`user-profile`, by path.

Please note that ``profile`` scope is required for this request.

→ Response
----------

In case of success, a :ref:`user-profile` is returned:

.. code::

    {
        <profile object>
    }

.. list-table::
    :header-rows: 1
    :widths: 20 80

    * - Response Code
      - Description
    * - ``200 OK``
      - Everything went OK, User Profile follows.
    * - ``404 Not found``
      - This user has yet to upload a user profile, and there no such a user profile.
