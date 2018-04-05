
Concepts
========

This documents refers to various concepts that have been implemented in the Anthill Runtime libraries.
Despite being implemented in different languages, the idea is still the same.

.. _application-info:

Application Info
----------------

Application Info is a small object that is required to be filled before initialization of the Anthill Runtime.

.. tabs::
    .. code-tab:: cpp

        struct online::ApplicationInfo
        {
            std::string gamespace;
            std::string applicationName;
            std::string applicationVersion;
            AccessScopes requiredScopes;
            AccessScopes shouldHaveScopes;
        }

    .. code-tab:: java

        public class ApplicationInfo
        {
            public String gamespace;
            public String applicationName;
            public String applicationVersion;
            public AccessScopes requiredScopes;
            public AccessScopes shouldHaveScopes;

            ...
        }

.. glossary::

    ``gamespace``

        See :ref:`gamespace`

    ``applicationName``

        A name for the game in question. This name must be registered in :ref:`admin-tool`. See :ref:`application-name`

    ``applicationVersion``

        See :ref:`application-version`

    ``requiredScopes``

        A list of :ref:`access-scopes` the library is about to ask.

    ``shouldHaveScopes``

        A list of :ref:`access-scopes` the client should be able to obtain access to, otherwise the library will
        fail to launch. Default is a single ``*``, meaning all ``requiredScopes`` must be fulfilled.

        An example use case for this might be asking for several scopes in ``requiredScopes`` (for example,
        ``A``, ``B``, ``C``) but also define ``shouldHaveScopes`` to less range of scopes (``[A, B]``),
        so only those who have access to restricted ones (``C``) will get it.

.. _storage:

Storage
-------

Anthill Runtime might need to store some information between the applications launches. The way the data is stored
is up to the game, so the ``Storage`` is an abstract class the game engine should override.

.. tabs::
    .. code-tab:: cpp

        class Storage
        {
        ...

        public:
            virtual void set(const std::string& key, const std::string& value) = 0;
            virtual std::string get(const std::string& key) const = 0;
            virtual bool has(const std::string& key) const = 0;
            virtual void remove(const std::string& key) = 0;
            virtual void save() = 0;
        };

    .. code-tab:: java

        public abstract class Storage
        {
            public abstract void set(String key, String value);
            public abstract String get(String key);
            public abstract boolean has(String key);
            public abstract void remove(String key);
            public abstract void save();
        }


.. glossary::

    ``set``

        Will be called once some information named ``key`` with value ``value`` should be stored. The writing operations
        should not happen immediately as the method ``save`` is made for that purpose.

    ``get``

        Will be called once some information named ``key`` is needed. The overrider needs to return the data asked,
        resorting to returning empty string if there is no such data.

    ``has``

        Will be called to check if the information named ``key`` exists.

    ``remove``

        Will be called to delete the information named ``key``. If there was no such data, nothing should happen.

    ``save``

        This method call should actually store all the changes, so subsequent game launches would be able to retrieve
        that data.

.. _online-listener:

Online Listener
---------------

Depending on the application, the game might be interested in certain key events. To receive those, the game have to
override the Online Listener and pass it to the Anthill Runtime during initialization.

.. tabs::
    .. code-tab:: cpp

        class Listener
        {
        public:
            virtual void multipleAccountsAttached(
                const LoginService& service,
                const LoginService::MergeOptions options,
                LoginService::MergeResolveCallback resolve) = 0;

            virtual void servicesDiscovered(std::function<void()> proceed)
            {
                proceed();
            }

            virtual void environmentVariablesReceived(const EnvironmentInformation& variables)
            {
                //
            }

            virtual void authenticated(
                const std::string& account,
                const std::string& credential,
                const online::LoginService::Scopes& scopes)
            {
                //
            }

            virtual bool shouldHaveExternalAuthenticator()
            {
                return false;
            }

            virtual ExternalAuthenticatorPtr createExternalAuthenticator()
            {
                return nullptr;
            }

            virtual bool shouldSaveExternalStorageAccessToken()
            {
                return true;
            }
        };

    .. code-tab:: java

        public abstract class Listener
        {
            public abstract void multipleAccountsAttached(
                LoginService service,
                LoginService.MergeOptions mergeOptions,
                LoginService.MergeResolveCallback resolve);

            public void servicesDiscovered(Runnable proceed)
            {
                proceed.run();
            }

            public void environmentVariablesReceived(AnthillRuntime.EnvironmentInformation variables)
            {
                //
            }

            public void authenticated(String account, String credential, LoginService.Scopes scopes)
            {
                //
            }

            public boolean shouldHaveExternalAuthenticator()
            {
                return false;
            }

            public LoginService.ExternalAuthenticator createExternalAuthenticator()
            {
                return null;
            }

            public boolean shouldSaveExternalStorageAccessToken()
            {
                return true;
            }
        }

.. glossary::

    ``multipleAccountsAttached``

        This event will be fired on rare occasions in which a :ref:`Credential <credentials>` has been linked to
        several different :ref:`Accounts <player-account>`. In tat cases the system has to resolve that occasion by
        calling ``resolve`` callback with appropriate merge option from ``mergeOptions``.

    ``servicesDiscovered``

        This even will be fired once all required services has been discovered. The ``proceed`` callback should be
        called once the system is ready to proceed.

    ``environmentVariablesReceived``

        This even will be fired once the :ref:`Environment Variables <environment-customisation>` has been received.

    ``authenticated``

        This even will be fired once the player has been successfully authenticated. Because :ref:`access-token` is a
        raw string that should not be parsed, this method is a rare possibility to know the
        ``account``, ``credential`` and ``scopes`` from this token.

    ``shouldHaveExternalAuthenticator``

        This method indicates if the system needs :ref:`external-authenticator`.

    ``createExternalAuthenticator``

        If the system needs :ref:`external-authenticator` by design, this method should return a fresh new
        instance of it, once called.

    ``shouldSaveExternalStorageAccessToken``

        If ``true``, the system will use :ref:`storage` to save acquired :ref:`access-token` for caching purposes.

.. _external-authenticator:

External Authenticator
----------------------

By default the system authenticates with :ref:`anonymous` credentials, meaning there is no dependency on external
"social networks", but in some cases the game build might rely on them heavily.

For example, games made for Steam platform should authenticate using :ref:`steam` credentials only. For that case,
the :ref:`online-listener` should set ``shouldHaveExternalAuthenticator`` to ``true``, and then
``createExternalAuthenticator`` should return an overridden instance of the abstract External Authenticator, which
should do the authentication with :ref:`steam` credential.

.. tabs::
    .. code-tab:: cpp

        class ExternalAuthenticator
        {
        public:
            virtual std::string getCredentialType() = 0;

        protected:
            virtual void authenticate(
                LoginService& loginService,
                const std::string& gamespace,
                const LoginService::Scopes& scopes,
                const Request::Fields& other,
                LoginService::AuthenticationCallback callback,
                LoginService::MergeRequiredCallback mergeRequiredCallback,
                const LoginService::Scopes& shouldHaveScopes = {"*"}) = 0;

            virtual void attach(
                LoginService& loginService,
                const std::string& gamespace,
                const LoginService::Scopes& scopes,
                const Request::Fields& other,
                LoginService::AuthenticationCallback callback,
                LoginService::MergeRequiredCallback mergeRequiredCallback,
                const LoginService::Scopes& shouldHaveScopes = {"*"}) = 0;
        };

    .. code-tab:: java

        public static abstract class ExternalAuthenticator
        {
            public abstract String getCredentialType();

            public abstract void authenticate(
                LoginService loginService,
                String gamespace,
                LoginService.Scopes scopes,
                Request.Fields other,
                LoginService.AuthenticationCallback callback,
                LoginService.MergeRequiredCallback mergeRequiredCallback,
                LoginService.Scopes shouldHaveScopes);

            public abstract void attach(
                LoginService loginService,
                String gamespace,
                LoginService.Scopes scopes,
                Request.Fields other,
                LoginService.AuthenticationCallback callback,
                LoginService.MergeRequiredCallback mergeRequiredCallback,
                LoginService.Scopes shouldHaveScopes);
        };

.. glossary::

    ``getCredentialType``

        This method should return credential type for this external authenticator. For example, ``steam`` or ``google``.

    ``authenticate``

        This method should do the authentication. The actual authentication depends on the external system. User
        has to prepare the required data do the authentication via ``loginService``, passing ``callback`` and
        ``mergeRequiredCallback`` if necessary.

    ``attach``

        This method is used for rare cases when existing and working token's credential needs to be attached to
        the external one. The actual attaching depends on the external system. User has to prepare the required data
        do the attach via ``loginService``, passing ``callback`` and ``mergeRequiredCallback`` if necessary.
