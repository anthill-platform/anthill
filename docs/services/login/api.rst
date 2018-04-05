
.. title:: REST API

.. _oauth:

OAuth 2.0
=========

Some “external” credentials (``facebook``, ``google``, ``vk`` etc)
follow OAuth 2.0 protocol in order of the authorization to proceed. This
authorization can be achieved with a simple flow:

1. User has the corresponding social network’s “login page” shown,
   asking user consent for the authorization.
2. After approval, the browser gets redirected back to the special
   ``redirect_uri`` location, with the special ``code`` argument.
3. This redirect is caught and the code is extracted as an argument for
   the actual authorization in the login service.

In practice, each social service has different location of the “login
page”, so login service encapsulates it with a convenient call. Open
this URL in the application’s in-app browser:

.. code-block:: bash

    http(s)://<login-service-location>/auth/<credential>?redirect_uri=<redirect_uri>&gamespace=<gamespace>

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``credential``
     - A credential type of the social service (for example, ``google``)
   * - ``redirect_uri``
     - Application’s main domain page, for example, ``http://example.com/``. It’s important to have ``/`` at the end.
   * - ``gamespace``
     - A gamespace name (alias) to authenticate in. See Authenticate call for more details.

Please note that ``redirect_uri`` value has to be added into the allowed
“REDIRECT URIs” list in each social service’s settings page of your
application.

-  This call will automatically redirect to the corresponding social
   service authorization form on which the user is asked for login and
   password.
-  After successful authorization, the browser is redirected to the
   ``redirect_uri`` page, according to the OAuth 2.0 standard.
-  This redirect will have a query argument ``code``, and the
   application has to catch the redirect, extract the ``code``, closing
   the browser.
-  Then ``code`` and ``redirect_uri`` has to be used during the
   last-step authentication call to the login service.

Admin Tool
----------

You can log in into the :ref:`admin-tool` using these credentials, but the
``http(s)://<login-service-location>/auth/oauth2callback`` has to be
added as a ``redirect_uri`` (see above).

.. _authenticate:
.. _login-service-api-auth:

Authenticate
============

Authenticates the user in the Anthill Platform

← Request
---------

.. code-block:: bash

    POST /auth

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``credential``
     - Credential type
   * - ``scopes``
     - Comma-separates list of access scopes to request
   * - ``gamespace``
     - A gamespace name (alias) to authenticate in

Optional arguments:

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
     - Default value
   * - ``should_have``
     - Comma-separated list of scopes the user should definitely acquire, or ``403 Forbidden`` will be returned. Useful in cases when player is OK with not having some of scopes.
     - ``*``, everything requested should be retrurned.
   * - ``info``
     - A JSON object of the additional info would be attached to account (for example, device ID)
     - ``{}``
   * - ``attach_to``
     - Access token of the account to proceed the attach procedure. See Attach Credential for more information.
     -
   * - ``unique``
     - Should the access token be unique (meaning no two tokens of the same name could exists). Setting to ``false`` would require a special access scope ``auth_non_unique``.
     - ``true``
   * - ``as``
     - A name for the token. Only one token of the same name could exist at the same time (if ``unique`` is ``true``)
     - ``def``
   * - ``full``
     - Return more information about the token returned (if form of a JSON object instead of just token)
     - ``false``

→ Response
----------

In case of success, an access token is returned:

::

    "token string"

**Warning**: token string format could be changed at any moment, so the
client application should not rely on this response, and should threat
it like a simple string.

If the argument ``full`` is set to ``true``, a JSON object is returned
instead:

::

    {
        "token": "<token string>",
        "account": "<account ID>",
        "credential": "<credential>",
        "scopes": [<array of allowed scopes>]
    }

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Everything went OK, service location follows.
   * - ``404 Bad Arguments``
     - Some arguments are missing or wrong.
   * - ``403 Forbidden``
     - Failed to acquire a token, either username/password is wrong, or access is denied.
   * - ``409 Conflict``
     - A merge conflict is happened, a Conflict Resolve is required

.. _login-service-api-attach:

Attach Credential
=================

If you login with a credential for the first time, a fresh new account
is created. However, sometimes it is not the case. For example, a player
have already authenticated into credential ``anonymous:XX-XX-XX``, so
the account ``A`` is created.

::

        anonymous:XX-XX-XX -> A

But if player also wants to login using ``facebook``, he will end up
with a different account.

::

        anonymous:XX-XX-XX -> A
        facebook:12345678  -> B

To avoid this, credential can be attached to a same account instead of
creating new one.

::

        anonymous:XX-XX-XX -> A
        facebook:12345678  -> A

Simplest way to do so is to pass ``attach_to`` argument while doing
Authenticate call:

1. Authenticate, using first credential (say ``anonymous:XX-XX-XX``),
   account ``A`` will be used (or created);
2. Authenticate, using second credential (say ``facebook:12345678``).
   While doing that, pass the access token from a previous
   authentication, as ``attach_to`` argument;
3. The system will try to attach credential ``facebook:12345678`` to
   account ``A`` as long as credential is not used elsewhere;

.. _account-conflict:

Account Conflict
================

In case credential ``facebook:12345678`` has already attached to a
different account, or already has multiple accounts attached, a conflict
will occur:

::

    {
        "result_id": "<Conflict Reason>",
        // other useful information about the conlict
    }

In response to conflict, server may return ``resolve_token`` to Resolve
Conflict. Possible conflict reasons:

- ``merge_required``

    Credential, you are trying to attach is already attached to a different
    account. Possible account solutions along with their profiles (if exist)
    are described in field ``accounts``.

    ::

        {
            "result_id": "merge_required",
            "resolve_token": "<a resolve token>",
            "accounts": {
                "local": {
                    "account": <account N>,
                    "credential": <credentian N>,
                    "profile": { a possible profile JSON object }
                },
                "remote": {
                    "account": <account N>,
                    "credential": <credentian N>,
                    "profile": { a possible profile JSON object }
                }
            }
        }

    Profile fields may be used to describe to the Player information about
    the accounts (level reached, currency have, avatar etc). On of the
    solutions should be used as ``resolve_with`` when dealing with Resolve
    Conflict.

- ``multiple_accounts_attached``

    Credential, you are trying to attach is already attached to a multiple
    accounts. One of them is required to be detached first. Please note that
    this may happen during normal authentication.

    ::

        {
            "result_id": "multiple_accounts_attached",
            "resolve_token": "<a resolve token>",
            "accounts": [
                {
                    "account": <account number>,
                    "profile": { a possible profile JSON object }
                },
                {
                    "account": <account number>,
                    "profile": { a possible profile JSON object }
                },
                ...
            ]
        }

    On of the account numbers should be used as ``resolve_with`` when
    dealing with Resolve Conflict.

.. _login-service-api-resolve:

Resolve Conflict
================

I case of conflict, a Resolve Conflict method may be used to solve the
conflict situation.

← Request
---------

.. code-block:: bash

    POST /resolve

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``access_token``
     - A Resolve Token, retrieved when the conflict occurred.
   * - ``resolve_method``
     - A way how to resolve this conflict. Should be exactly the Conflict Reason server gave.
       For example, ``merge_required`` or ``multiple_accounts_attached``.
   * - ``scopes``
     - Access scopes to be acquired like in Authenticate procedure.
   * - ``resolve_with``
     - A way to resolve this conflict. Varies for different Conflict Reasons

Optional arguments:

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``attach_to``
     - Access Token to the account player originally was going to attach to. Only applicable if conflict happened during Attach Credential procedure.
   * - ``full``
     - Return more information about the token returned (if form of a JSON object instead of just token)

→ Response
----------

In case of success, an access token is returned:

::

    "token string"

**Warning**: token string format could be changed at any moment, so the
client application should not rely on this response, and should threat
it like a simple string.

If the argument ``full`` is set to ``true``, a JSON object is returned
instead:

::

    {
        "token": "<token string>",
        "account": "<account ID>",
        "credential": "<credential>",
        "scopes": [<array of allowed scopes>]
    }

.. _login-service-api-validate:

Validate Access Token
=====================

Checks if the given access token is valid

← Request
---------

.. code-block:: bash

    GET /validate

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``access_token``
     - Access token to validate.

→ Response
----------

This request has no response body.

.. list-table::
   :header-rows: 1

   * - Response
     - Description
   * - ``200 OK``
     - Access token is valid.
   * - ``404 Bad Arguments``
     - Some arguments are missing or wrong.
   * - ``403 Forbidden``
     - Token is not valid.

.. _extend-access-token:
.. _login-service-api-extend:

Extend Access Token
===================

Allows to to give additional Access Scopes to the existing access token
(account of which did not have such scopes originally), using other,
more powerful account.

1. Say there’s account ``A`` with scopes ``S1`` and ``S2`` allowed.
2. There’s account ``B`` with scope ``S10`` that ``A`` has no access to.
3. ``A`` authenticates, requesting scope ``S1``.
4. ``B`` authenticates, requesting scope ``S10``.
5. Access token of ``B`` extends access token ``A`` using scope he had
   ``S10``.
6. A working access token for ``A`` with scopes ``S1`` and ``S10`` is
   now available.

This flow is primarily used for trusted game servers to do strict
actions server side. For example,

1. User Authenticates asking for ``profile`` scope. This scope allows
   only to read user profile, but not to write;
2. The Game Server Authenticates itself using ``dev`` credential with
   ``profile_write`` scope;
3. User give the access token to the server is a secure way;
4. The Game Server extends this token to the more powerful one, so
   server can write the profile in behalf of the user;
5. At the same time, user still have perfectly working access token,
   without such possibility;

← Request
---------

.. code-block:: bash

    POST /extend

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
   * - ``access_token``
     - Access token to extend (the one to be improved)
   * - ``extend``
     - Access token to extend with (the one that have required scopes)
   * - ``scopes``
     - Scopes to improve ``access_token`` with. Default ``*`` – to use all scopes the scope ``extend`` have. Otherwise, a comma-separate list of Access Scopes.

→ Response
----------

A JSON object with a new token and it’s expiration date.

::

    {
        "token": "<improved access token>",
        "scopes": [<scopes of improved token>],
        "account": "<account of the original access_token>",
        "expires_in": <time, in seconds, for the new token to expire>
    }

Please note that the original access token is still valid. Also, tokens
have to be in a same gamespace.

