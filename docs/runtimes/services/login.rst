Login Service
=============

.. note::
    This document covers documentation for Anthill Runtime's implementation for the :doc:`../../services/login`.
    If you need the documentation for the actual service, please see :doc:`../../services/login` instead.

How To Get Instance
-------------------

.. warning::
    To use this, you must mention this service during :ref:`Library Instantiation <anthill-runtime-setup-instance>`.

.. tabs::

    .. code-tab:: cpp

        LoginServicePtr service =
            online::AnthillRuntime::Instance().get<online::LoginService>();

    .. code-tab:: java

        LoginService service =
            AnthillRuntime.Get(LoginService.ID, LoginService.class);

.. _runtimes-login-authenticate:

Authenticate
------------

Authenticates the user in the Anthill Platform

    .. tabs::

        .. code-tab:: cpp

            void authenticate(
                const std::string& credentialType,
                const std::string& gamespace,
                const Scopes& scopes,
                const Request::Fields& other,
                AuthenticationCallback callback,
                MergeRequiredCallback mergeRequiredCallback,
                const Scopes& shouldHaveScopes = {"*"});

        .. code-tab:: java

            // the last argument is optional

            public void authenticate(
                String credentialType,
                String gamespace,
                Scopes scopes,
                Request.Fields other,
                final AuthenticationCallback callback,
                MergeRequiredCallback mergeRequiredCallback,
                Scopes shouldHaveScopes)

    .. glossary::

        ``credentialType``

            A :ref:`Credential Type <credentials>` for the authentication

        ``gamespace``

            A :ref:`gamespace` (alias) this authentication goes into

        ``scopes``

            See :ref:`access-scopes`

        ``other``

            Other possible arguments that :ref:`Credential Type <credentials>` might additionally require.

        ``callback``

            The callback that would be called once the authentication completed.

        ``mergeRequiredCallback``

            The callback that would be called in rare event of :ref:`account-conflict`

        ``shouldHaveScopes``

            List of scopes the user should definitely acquire, or Forbidden error will be occur.
            Useful in cases when player is OK with not having some of scopes.
            A special case of single ``*`` (default) means ALL scopes being asked should be satisfied.

    Please see :ref:`login-service-api-auth` REST API call for more information.

.. _runtimes-login-attach:

Attach Credential
-----------------

Attaches some credential to existing account. Technically, this call is 90% equal to :ref:`runtimes-login-authenticate`,
because, by design, attach means "authenticate, but in someone's else account". The account in question is
determined by ``accessToken``.

    .. tabs::

        .. code-tab:: cpp

            void LoginService::attach(
                const std::string& accessToken,
                const std::string& credentialType,
                const std::string& gamespace,
                const Scopes& scopes,
                const Request::Fields& other,
                LoginService::AuthenticationCallback callback,
                MergeRequiredCallback mergeRequiredCallback,
                const Scopes& shouldHaveScopes)

        .. code-tab:: java

            // the last argument is optional

            public void attach(
                AccessToken accessToken,
                String gamespace,
                String credentialType,
                Scopes scopes,
                Request.Fields other,
                final AuthenticationCallback callback,
                MergeRequiredCallback mergeRequiredCallback,
                Scopes shouldHaveScopes)

    .. glossary::

        ``accessToken``

            An existing :ref:`access-token` the authentication attaches to.

        ``credentialType``

            A :ref:`Credential Type <credentials>` for the authentication.

        ``scopes``

            See :ref:`access-scopes`.

        ``other``

            Other possible arguments that :ref:`Credential Type <credentials>` might additionally require.

        ``callback``

            The callback that would be called once the authentication completed.

        ``mergeRequiredCallback``

            The callback that would be called in rare event of :ref:`account-conflict`

        ``shouldHaveScopes``

            List of scopes the user should definitely acquire, or Forbidden error will be occur.
            Useful in cases when player is OK with not having some of scopes.
            A special case of single ``*`` (default) means ALL scopes being asked should be satisfied.

    Please see :ref:`login-service-api-attach` REST API call for more information.

Resolve a Conflict
------------------

Resolves the occurred :ref:`account-conflict` event that may happen during :ref:`runtimes-login-attach` or
:ref:`runtimes-login-authenticate`.

    .. tabs::

        .. code-tab:: cpp

            void resolve(
                const std::string& resolveToken,
                const std::string& methodToResolve,
                const std::string& resolveWith,
                const Scopes& scopes,
                const Request::Fields& other,
                AuthenticationCallback callback,
                const Scopes& shouldHaveScopes = {"*"},
                const std::string& attachTo = "");

        .. code-tab:: java

            // the last two arguments are optional

            public void resolve(
                AccessToken resolveToken,
                String methodToResolve,
                String resolveWith,
                String scopes,
                Request.Fields other,
                final AuthenticationCallback callback,
                Scopes shouldHaveScopes,
                AccessToken attachTo)

    .. glossary::

        ``resolveToken``

            A Resolve Token, retrieved when the conflict occurred.

        ``methodToResolve``

            A way how to resolve this conflict.
            Should be exactly the ``Conflict Reason`` server gave in ``MergeRequiredCallback``.
            For example, ``merge_required`` or ``multiple_accounts_attached``.

        ``resolveWith``

            A way to resolve this conflict. Varies for different Conflict Reasons.

        ``other``

            Other possible arguments that :ref:`Credential Type <credentials>` might additionally require.

        ``callback``

            The callback that would be called once the authentication completed.

        ``shouldHaveScopes``

            (Optional) List of scopes the user should definitely acquire, or Forbidden error will be occur.
            Useful in cases when player is OK with not having some of scopes.
            A special case of single ``*`` (default) means ALL scopes being asked should be satisfied.

        ``attachTo``

            An existing :ref:`access-token` the account player originally was going to attach to.
            Only applicable if conflict happened during Attach Credential procedure.

    Please see :ref:`login-service-api-resolve` REST API call for more information.


Extend An Access Token
----------------------

Allows to to give additional :ref:`access-scopes` to the existing :ref:`access-token` (account of which did not
have such scopes originally), using other, more powerful account.

    .. tabs::

        .. code-tab:: cpp

            void extend(
                const std::string& accessToken,
                const std::string& extendWith,
                const Scopes& scopes,
                AuthenticationCallback callback);

        .. code-tab:: java

            public void extend(
                AccessToken accessToken,
                AccessToken extendWith,
                LoginService.Scopes scopes,
                final AuthenticationCallback callback)

    .. glossary::

        ``accessToken``

            Access token to extend (the one to be improved)

        ``extendWith``

            Access token to extend with (the one that have required scopes)

        ``scopes``

            A list of scopes to improve ``access_token`` with. A single ``*`` element can be used to have
            all scopes the scope ``extend`` have.

        ``callback``

            the callback that would be called once the token has been extended.

    Please see :ref:`login-service-api-extend` REST API call for more information.


Validate An Access Token
------------------------

Checks if the given access token is valid.

    .. tabs::

        .. code-tab:: cpp

            void validateAccessToken(
                const std::string& accessToken,
                ValidationCallback callback);

        .. code-tab:: java

            public void validateAccessToken(
                final AccessToken token,
                final ValidationCallback callback)

    .. glossary::

        ``accessToken``

            Access token to validate

        ``callback``

            The callback that would be called once the token has been validated (or not).

    Please see :ref:`login-service-api-validate` REST API call for more information.
