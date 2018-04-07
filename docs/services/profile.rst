Profile Service
===============

A service designed to store player profiles.

.. seealso::
   :anthill-service-source:`Source Code <profile>`

.. _user-profile:

User Profile
------------

User Profile is a JSON :ref:`profile-object` that applied to store Player's data on the server backend.
It can be altered concurrently, or as a whole JSON object, depending on your requirements.

Profile Access
--------------

Profile service has a system to define access levels to some fields of :ref:`user-profile` in the :ref:`admin-tool`,
per :ref:`gamespace`.

.. note::
    1. The access levels might be applied only to the root fields of the :ref:`user-profile`.
    2. Same field might be listed in multiple access lists, thus getting mixed results.

.. _profile-access-public:

Public Fields
~~~~~~~~~~~~~

Fields, listed in this list, will have public access, meaning other users would be able to read these fields.
Fields, not listed in this list, will not be accessible to other users.

.. warning::
    Other users would not be able to receive certain fields from a User Profile, unless they are listed here.

.. _profile-access-private:

Private Fields
~~~~~~~~~~~~~~

Fields, listed in this list will be listed and updated only with ``profile_private`` :ref:`Scope <access-scopes>`,
meaning there might be fields that only the server has access to.

.. _profile-access-protected:

Protected Fields
~~~~~~~~~~~~~~~~

Fields, listed in this list can be listed to the player only, but even the player cannot change it.
Like with Private Fields, the ``profile_private`` :ref:`Scope <access-scopes>` is required to change this field.

REST API
--------

.. toctree::
   :maxdepth: 1

   profile/api
