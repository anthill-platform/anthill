
.. title:: REST API

Get User Profile
================

Returns a :ref:`user-profile` for an account.

← Request
---------

.. code-block:: bash

    GET /profile/<account> [/<path>]

.. list-table::
    :header-rows: 1
    :widths: 20 80

    * - Argument
      - Description
    * - ``account``
      - Account number of the user's profile. A special value ``me`` refers to current user.
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

Get User Profiles Of Multiple Accounts
======================================

Returns a :ref:`user-profile` objects for several accounts. Useful when you have a list of users, and need User Profiles
for them (for example, a player list).

← Request
---------

.. code-block:: bash

    GET /profiles

.. list-table::
    :header-rows: 1
    :widths: 20 80

    * - Argument
      - Description
    * - ``accounts``
      - A JSON list of account numbers of the user's profiles (``["1", "20", "444"]``)

.. note::
    Only :ref:`profile-access-public` will be returned.

Please note that ``profile`` scope is required for this request.

→ Response
----------

In case of success, an object of :ref:`User Profiles <user-profile>` is returned. Those accounts who miss a profile,
will return an empty object ``{}``.

.. code::

    {
        "<account-id>": { profile object },
        "<account-id>": { profile object },
        "<account-id>": { profile object },

        ...
    }

.. list-table::
    :header-rows: 1
    :widths: 20 80

    * - Response Code
      - Description
    * - ``200 OK``
      - Everything went OK, User Profiles follow.

Update User Profile
===================

Updates a :ref:`user-profile` for an account.

← Request
---------

.. code-block:: bash

    POST /profile/<account> [/<path>]

.. list-table::
    :header-rows: 1
    :widths: 20 80

    * - Argument
      - Description
    * - ``account``
      - Account number of the user's profile. A special value ``me`` refers to current user.
    * - ``data``
      - A :ref:`profile-object` with updates to the :ref:`user-profile`
    * - ``merge``
      - If ``true``, the fields of the :ref:`profile-object` will be merged with old values, otherwise the values
        that are not mentioned in updates will be deleted as well.
    * - ``path``
      - Optionally, adding additional directories to the request would make the service to update only part of the
        :ref:`user-profile`, by path.

Please note that ``profile_write`` scope is required for this request.

→ Response
----------

In case of success, a :ref:`user-profile` is updated, and updated value is returned:

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
    * - ``400 Profile Error``
      - Some of the :ref:`profile-object-functions` might have failed
    * - ``404 Not found``
      - This user has yet to upload a user profile, and there no such a user profile.
