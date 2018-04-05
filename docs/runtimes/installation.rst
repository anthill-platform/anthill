
Installation
============

.. contents::
   :local:
   :depth: 1

This document describes the actual installation of the Anthill Runtime library in your project, if you have installed
it and would like to setup the classes, see :doc:`setup`.

Java
----

Java Runtime is build with Maven, so installation is pretty straightforward.

Gradle-based project
~~~~~~~~~~~~~~~~~~~~

   1. Add the JitPack repository to your ``build.gradle`` file.

   ::

      allprojects {
          repositories {
              ...
              maven { url "https://jitpack.io" }
          }
      }

   2. Add the dependency.

   ::

      dependencies {
         compile 'com.github.anthill-platform:anthill-runtime-java:0.1.4'
      }

Maven-based project
~~~~~~~~~~~~~~~~~~~

   1. Add the JitPack repository to your ``pom.xml`` file.

   .. code-block:: xml

      <repositories>
         <repository>
            <id>jitpack.io</id>
            <url>https://jitpack.io</url>
         </repository>
      </repositories>

   2. Add the dependency:

   .. code-block:: xml

      <dependency>
          <groupId>com.github.anthill-platform</groupId>
          <artifactId>anthill-runtime-java</artifactId>
          <version>0.1.4</version>
      </dependency>

.. _cpp-runtime:

C++
---

CMake-based project
~~~~~~~~~~~~~~~~~~~

    C++ Runtime uses CMake. If you are not familiar with CMake and have no intentions to use it in your project,
    see :ref:`cpp-prebuilt`.

    Unfortunately, CMake cannot download dependencies automatically for you.
    You would have to install several dependencies.

    Ideally, you can put all them in same directory (for example, ``externals``) as Git submodules.

    .. list-table::
       :header-rows: 1

       * - Library
         - Recommended directory name
         - Repository URL
       * - Anthill C++ Runtime itself
         - anthill-runtime-cpp
         - ``https://github.com/anthill-platform/anthill-runtime-cpp.git``
       * - cURL
         - curl
         - ``https://github.com/curl/curl.git``
       * - curlcpp
         - curlcpp
         - ``https://github.com/JosephP91/curlcpp.git``
       * - jsoncpp
         - jsoncpp
         - ``https://github.com/open-source-parsers/jsoncpp.git``
       * - libuv
         - libuv
         - ``https://github.com/jen20/libuv-cmake.git``
       * - uWebSockets
         - uWebSockets
         - ``https://github.com/anthill-utils/uWebSockets.git``

    Other dependencies that you might need to install: ``openssl``, ``zlib``.

    At the end of the day you might have directory structure like this::

        externals/
            anthill-runtime-cpp/
                ...
            curl/
                ...
            curlcpp/
                ...
            jsoncpp/
                ...
            libuv/
                ...
            uWebSockets/
                ...

    .. note::
        Some of the submodules have submodules themselves, so this oneliner is required:

        .. code-block:: bash

            git submodule update --init --recursive

    Setup a ``CMakeFiles.txt`` for your project:

    .. code-block:: cmake

        cmake_minimum_required(VERSION 2.8.11)

        set(CURL_MIN_VERSION "7.28.0")

        set(LIBUV_INCLUDE_DIR "${PROJECT_BINARY_DIR}/external/libuv/libuv/include")
        set(CURLCPP_INCLUDE_DIR "${PROJECT_BINARY_DIR}/external/curlcpp/include")
        set(JSONCPP_INCLUDE_DIR "${PROJECT_BINARY_DIR}/external/jsoncpp/include")
        set(UWS_DIR "${PROJECT_BINARY_DIR}/external/uWebSockets")

        add_subdirectory("${PROJECT_BINARY_DIR}/external/anthill-runtime-cpp" "build/anthill-runtime-cpp")

        add_subdirectory("${PROJECT_BINARY_DIR}/external/curl" "build/curl")
        add_subdirectory("${PROJECT_BINARY_DIR}/external/curlcpp" "build/curlcpp")
        add_subdirectory("${PROJECT_BINARY_DIR}/external/jsoncpp" "build/jsoncpp")
        add_subdirectory("${PROJECT_BINARY_DIR}/external/libuv" "build/libuv")
        add_subdirectory("${PROJECT_BINARY_DIR}/external/uWebSockets" "build/uWebSockets")

        # setup your project from now on, don't forget to link with ${ANTHILL_LIBRARY}

.. _cpp-prebuilt:

Prebuilt library binaries
~~~~~~~~~~~~~~~~~~~~~~~~~

    If you have not intentions to use CMake in your C++ project what so ever, you can download prebuilt static library
    (along with dependant libraries) and simply import them in your project, as well as add include directories.

    .. todo:: Make prebuilt library