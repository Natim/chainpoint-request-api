.. _api-utilities:

Utility endpoints for OPS and Devs
##################################

GET /
=====

The returned value is a JSON mapping containing:

.. versionchanged:: 2.12

- ``project_name``: the name of the service (e.g. ``"reading list"``)
- ``project_docs``: The URL to the service documentation. (this document!)
- ``project_version``: complete application/project version (``"3.14.116"``)
- ``http_api_version``: the MAJOR.MINOR version of the exposed HTTP API (``"1.1"``)
  defined in configuration.
- ``url``: absolute URI (without a trailing slash) of the API (*can be used by client to build URIs*)
- ``eos``: date of end of support in ISO 8601 format (``"yyyy-mm-dd"``, undefined if unknown)

.. note::

    The ``project_version`` contains the source code version, whereas the ``http_api_version`` contains the exposed :term:`HTTP API` version.

    The source code of the service can suffer changes and have its *project version*
    incremented, without impacting the publicly exposed HTTP API.


GET /__heartbeat__
==================

Return the status of each service the application depends on. The
returned value is a JSON mapping containing:

- ``database`` true if the database backend is operational


GET /__lbheartbeat__
====================

Always return ``200`` with empty body.

Unlike the ``__heartbeat__`` health check endpoint, which return an error
when backends and other upstream services are unavailable, this should
always return 200.

This endpoint is suitable for a load balancer membership test.
It the load balancer cannot obtain a response from this endpoint, it will
stop sending traffic to the instance and replace it.
