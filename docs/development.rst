
Development
===========

.. note:: This document describes steps how to setup minimal environment for development or testing purposes.

Mac OS X
~~~~~~~~

To setup minimal development environment on Mac Os X, you will need:

1. Install `PyCharm <https://www.jetbrains.com/pycharm/download>`__ (Community Edition is fine)
2. Clone the `dev repository <https://github.com/anthill-platform/anthill-dev>`__:

.. code-block:: bash

    git clone -b dev https://github.com/anthill-platform/anthill-dev.git
    cd anthill-dev
    git submodule update --init --recursive

3. Run installation script

.. code-block:: bash

    cd dev/osx
    ./setup.sh

It would take awhile (up to several hours).
This will install Homebrew, and Homebrew will install all of the required components.

4. Open cloned repo in PyCharm.

5. Setup the Project Interpreter.

    To do that, go to ``Preferences``, select ``Project Interpreter``, select ``Show All`` from the dropdown,
    hit “+”, select ``Add Local``, and feed it with ``/usr/local/venv/dev/bin/python``.

6. Select ``all`` run configuration, hit Run

    .. image:: images/compound_configuration.png
        :width: 89px

7. Open http://localhost:9500 in your browser
8. Press “Proceed”, login using username ``root`` and password
   ``anthill``. You should see something like this:

    .. image:: images/admin_page.png
        :width: 400px

Happy coding!

Windows
~~~~~~~

The Windows platform is not supported and never will be.
