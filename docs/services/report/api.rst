
Upload a Report
===============

Uploads a report to the service. Once done, can be viewed in :ref:`admin-tool`.

← Request
---------

.. code-block:: bash

    POST /upload/<application-name>/<application-version>

.. list-table::
    :header-rows: 1

    * - Argument
      - Description
    * - ``application-name``
      - See :ref:`application-name`
    * - ``application-version``
      - See :ref:`application-version`
    * - ``message``
      - A simple title that describes report as whole.
        That could be an exception type, for a crash report, or user name, for user reports.
    * - ``category``
      - A category for report, can be used to filter reports by category.
    * - ``format``
      - Can be one of these: ``binary``, ``text``, ``json``.
    * - ``info``
      - (Optional) A JSON object with additional information about the report, for example, username, OS version etc,
        can be used to filter reports by these.

Please note that ``report_upload`` scope is required for this request.

→ Response
----------

In case of success, a report ID is returned:

.. code:: json

    {
        "id": 12345
    }

.. list-table::
    :header-rows: 1

    * - Response Code
      - Description
    * - ``200 OK``
      - Everything went OK, report ID follows.
    * - ``429 Too Many Requests``
      - A rate limit for the reports upload has been exceeded for this user.
