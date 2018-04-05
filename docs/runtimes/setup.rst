
Setup
=====

This document describes the setup process Anthill Runtime library in your project code base, if you need to install
it first, see :doc:`installation`.

Global Reference
----------------

Store a global reference to the library in some "root" place. That might be your game singleton object, or a static
object.

.. tabs::

    .. code-tab:: cpp

        #include <anthill/AnthillRuntime.h>

        class TheGame {
            ...
        private:
            online::AnthillRuntimePtr m_anthillRuntime;
        };

    .. code-tab:: java

        import org.anthillplatform.runtime;

        class TheGame {
            ...
            private AnthillRuntime anthillRuntime;
        }

Setup the Application Info
--------------------------

Please see :ref:`application-info` for more information. Pick :ref:`application-name` and :ref:`application-version`
and register those in :ref:`admin-tool`. Depending on the application, you might also ask for :ref:`access-scopes`
with ``requiredScopes`` and ``shouldHaveScopes`` fields.


.. tabs::

    .. code-tab:: cpp

        #include <anthill/ApplicationInfo.h>

        online::ApplicationInfo app;
        app.gamespace = "thegame:desktop";
        app.applicationName = "thegame";
        app.applicationVersion = "0.1";
        app.requiredScopes = {"game"};

    .. code-tab:: java

        ApplicationInfo app = new ApplicationInfo(
            "thegame:desktop", "thegame", "0.1", new AccessScopes("game"));


Override the Storage class
--------------------------

Anthill Runtime will need to store few things between game launches. Unfortunately, Anthill Runtime only manages
*what* data is stored, but the game engine would need to implement *how* it's stored.


.. toggle-header::
    :header: Override example **See**

        .. tabs::

            .. code-tab:: cpp

                // h

                #include <anthill/Storage.h>

                class TheGameStorage: public online::Storage
                {
                public:
                    virtual void set(const std::string& key, const std::string& value) override;
                    virtual std::string get(const std::string& key) const override;
                    virtual bool has(const std::string& key) const override;
                    virtual void remove(const std::string& key) override;
                    virtual void save() = 0;
                };

                // cpp

                void TheGameStorage::set(const std::string& key, const std::string& value)
                {
                    //
                }

                std::string TheGameStorage::get(const std::string& key)
                {
                    //
                }

                bool TheGameStorage::has(const std::string& key)
                {
                    //
                }

                void TheGameStorage::remove(const std::string& key)
                {
                    //
                }

                void TheGameStorage::save()
                {
                    //
                }

            .. code-tab:: java

                public class TheGameStorage extends Storage
                {

                    @Override
                    public void set(String key, String value)
                    {
                        //
                    }

                    @Override
                    public String get(String key)
                    {
                        //
                    }

                    @Override
                    public boolean has(String key)
                    {
                        //
                    }

                    @Override
                    public void remove(String key)
                    {
                        //
                    }

                    @Override
                    public void save()
                    {
                        //
                    }
                }

.. note:: Please refer to :ref:`storage` for additional documentation on the methods of this class.

(Optionally) Override a global listener
---------------------------------------

Depending on the application, the game might be interested in certain key events. To receive those, the game have to
override the :ref:`online-listener` and pass it to the Anthill Runtime during initialization.

If you do not need those kind of events, you can skip this step.

.. _anthill-runtime-setup-instance:

Create a library instance
-------------------------

At some point of loading of the game, instantiate the library to the global variable.

.. tabs::

    .. code-tab:: cpp

        #include <anthill/AnthillRuntime.h>

        void TheGame::load()
        {
            online::ApplicationInfo applicationInfo = ...;

            online::StoragePtr storage = online::StoragePtr(new TheGameStorage());

            // you can skip this and do "online::ListenerPtr listener = nullptr;"
            online::ListenerPtr listener = online::ListenerPtr(new TheGameListener());

            // pick a list of services you'll need
            std::set<std::string> services = {
                online::LoginService::ID,
                online::ProfileService::ID,
                online::GameService::ID
            };

            m_anthillRuntime = online::AnthillRuntime::Create(
                // environment service location
                "http://localhost:9503",

                // things we've done earlier
                services,
                storage,
                listener,
                applicationInfo
            );
        };

    .. code-tab:: java

        import org.anthillplatform.runtime;

        class TheGame {
            ...
            public void load()
            {
                ApplicationInfo applicationInfo = ...;

                Storage storage = new TheGameStorage();

                // you can skip this and do "Listener listener = null;"
                Listener listener = new TheGameListener();

                // pick a list of services you'll need
                Set<String> services = new HashSet<String>();

                services.add(LoginService.ID);
                services.add(ProfileService.ID);
                services.add(GameService.ID);

                anthillRuntime = AnthillRuntime.Create(
                    // environment service location
                    "http://localhost:9503",

                    // things we've done earlier
                    services,
                    storage,
                    listener,
                    applicationInfo
                );
            }
        }
