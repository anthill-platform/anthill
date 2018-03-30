
anonymous
=========

A special way to authenticate without asking a player for usernames and
passwords. In order to authenticate, client application randomly
generates unique username and password, and stores it in secure storage
locally.

Is there’s no such username, a new one will be created.

These arguments are expected during authentication:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``username``
     - A random username (for example, a UUID)
   * - ``key``
     - A random password with considerable length

dev
===

Same as above, but cannot be created client side. Used for
administrative credentials, tools etc.

These arguments are expected during authentication:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``username``
     - A username
   * - ``key``
     - A password, the stronger is better

google
======

A way to authenticate using a Google account.

To enable this feature, please do the following:

    1. Create the Web Application OAuth Client ID at the Google API Console;
    2. Add the application website (for example, ``http(s)://example.com/``)
       into the ``Authorized redirect URIs`` list.
    3. Open the :ref:`admin-tool` and select the Login service;
    4. Select the section “Keys” and click “Add New Key”;
    5. Select ``google`` as Key Type, click Proceed
    6. Fill Client ID and Client Secret fields according to your
       credentials:

    .. image:: google_key.png
        :width: 330px

    After these steps, login using Google accounts will be available.

These arguments are expected during authentication:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``code``
     - OAuth 2.0 authentication code.
   * - ``redurect_uri``
     - OAuth 2.0 redirect location.

.. seealso::
    :ref:`oauth`

facebook
========

A way to authenticate using a Facebook account.

To enable this feature, please do the following:

    1. Create a New Application at the Facebook Developers section;
    2. Add the application website (for example, ``http(s)://example.com/``)
       into the ``Valid OAuth redirect URIs`` section (under Facebook Login
       product);
    3. Open the :ref:`admin-tool` and select the Login service;
    4. Select the section “Keys” and click “Add New Key”;
    5. Select in ``facebook`` as a Key Type.
    6. Fill the App ID and App Secret respectively:

    .. image:: facebook_key.png
        :width: 330px

    After these steps, login using Facebook accounts will be available.

These arguments are expected during authentication:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``code``
     - OAuth 2.0 authentication code.
   * - ``redurect_uri``
     - OAuth 2.0 redirect location.

.. seealso::
    :ref:`oauth`

vk
==

A way to authenticate using a VKontakte (vk.com) account.

To enable this feature, please do the following:

    1. Create a New Application at the Developers section;
    2. Add the application website (for example, ``http(s)://example.com/``)
       into the ``Authorized redirect URI``;
    3. Open the :ref:`admin-tool` and select the Login service;
    4. Select the section “Keys” and click “Add New Key”;
    5. Type in ``vk`` as a Key Type;
    6. Fill Application ID and Secure Key respectively:

    .. image:: vk_key.png
        :width: 330px

    After these steps, login using VK accounts will be available.

These arguments are expected during authentication:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``code``
     - OAuth 2.0 authentication code.
   * - ``redurect_uri``
     - OAuth 2.0 redirect location.

.. seealso::
    :ref:`oauth`

gamecenter
==========

A way to authenticate using a Apple’s Game Center. Please note, this way
is only possible on ``iOS``.

This way may look complicated, however it can be described in a few
steps:

    1. Generate a signature for the player;
    2. At the return, you will have such: ``publicKeyUrl``, ``signature``,
       ``salt`` and ``timestamp``;
    3. Pass them respectively as the expected arguments.

These arguments are expected during authentication:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``public_key``
     - A ``publicKeyUrl`` returned from generation process
   * - ``signature``
     - A generated ``signature``
   * - ``salt``
     - A generated ``salt``
   * - ``timestamp``
     - A generated ``timestamp``
   * - ``bundle_id``
     - Bundle ID of your Application
   * - ``username``
     - A playerID retreived from iOS

steam
=====

A way to authenticate using a Steam Account.

To enable this feature, a WebAPI key should be used:

    1. Create a WebAPI key;
    2. Open the :ref:`admin-tool` and select the Login service;
    3. Select the section “Keys” and click “Add New Key”;
    4. Select ``steam`` as a Key Type;
    5. Fill Steam Game ID and Encrypted App Ticket Key respectively:

    .. image:: steam_key.png
        :width: 330px

    After these steps, login using steam accounts will be available.

These arguments are expected during authentication:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``ticket``
     - Session ticket acquired from Steam API
   * - ``app_id``
     - Application ID (``app_id.txt``) to authenticate for

mailru
======

A way to authenticate using Mail.Ru Games Service (via @Mail.Ru
Launcher).

To enable this feature, a Secret should be used:

    1. Create a Game Project;
    2. Open the :ref:`admin-tool` and select the Login service;
    3. Select the section “Keys” and click “Add New Key”;
    4. Select ``mailru`` as a Key Type;
    5. Fill Game ID and Secret respectively:

    .. image:: mailru_key.png
        :width: 330px

    After these steps, login using Mail.Ru Games accounts will be available.

These arguments are expected during authentication:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Argument
     - Description
   * - ``uid``
     - UID received from @Mail.Ru Launcher
   * - ``hash``
     - OTP hash received from @Mail.Ru Launcher

token
=====

A special way to authenticate, using existing token (for example, you
would like to request more scopes, but don’t want to process a full
authentication again)

These arguments are expected during authentication:
