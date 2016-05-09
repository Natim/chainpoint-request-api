################
Batch operations
################

.. _batch:

POST /batch
===========

**Requires authentication**

The POST body is a mapping, with the following attributes:

- ``requests``: the list of requests
- ``defaults``: (*optional*) default requests values in common for all requests

 Each request is a JSON mapping, with the following attribute:

- ``method``: HTTP verb
- ``path``: URI
- ``body``: a mapping
- ``headers``: (*optional*), otherwise take those of batch request


.. code-block:: http

    POST /batch HTTP/1.1
    Accept: application/json
    Accept-Encoding: gzip, deflate
    Content-Length: 728
    Host: localhost:8888
    User-Agent: HTTPie/0.9.2

    {
      "defaults": {
        "method" : "POST",
        "path" : "/proofs",
      },
      "requests": [
        {
          "body" : {
            "data" : {
              "hash": "8700d48bd3f1b92feda79599e2ee34763ccb2df56e0b15887e6d06d94a53e791",
              "algorithm": "sha256",
            }
          }
        },
        {
          "body" : {
            "data" : {
              "hash": "562371b00d0412975d771fca38202cce3a245f94589cb0d693e293dfdad83011",
              "algorithm": "sha256",
            }
          }
        }
      ]
    }


The response body is a list of all responses:

.. code-block:: http

    HTTP/1.1 200 OK
    Access-Control-Expose-Headers: Retry-After, Content-Length, Alert, Backoff
    Content-Length: 1674
    Date: Wed, 17 Feb 2016 18:44:39 GMT
    Server: waitress

    {
      "responses": [
        {
          "status": 201,
          "path" : "/proofs",
          "body" : {
            "data" : {
              "id": "9a5fbff2-1600-11e6-83c0-3c970ede22b0",
              "hash": "8700d48bd3f1b92feda79599e2ee34763ccb2df56e0b15887e6d06d94a53e791",
              "algorithm": "sha256",
              ...
            }
          },
          "headers": {
            ...
          }
        },
        {
          "status": 201,
          "path" : "/proofs",
          "body" : {
            "data" : {
              "id": "a7b57278-1600-11e6-884f-3c970ede22b0",
              "hash": "562371b00d0412975d771fca38202cce3a245f94589cb0d693e293dfdad83011",
              "algorithm": "sha256",
              ...
            }
          },
          "headers": {
            ...
          }
        }
      ]
    }

HTTP Status Codes
-----------------

* ``200 OK``: The request has been processed
* ``400 Bad Request``: The request body is invalid
* ``50X``: One of the sub-request has failed with a ``50X`` status

.. warning::

    Since the requests bodies are necessarily mappings, posting arbitrary data
    (*like raw text or binary*) is not supported.

.. note::

     Responses are executed and provided in the same order than requests.


About transactions
------------------

The whole batch of requests is executed under one transaction only.

In order words, if one of the sub-request fails with a 503 status for example, then
every previous operation is rolled back.

.. important::

    With the current implementation, if a sub-request fails with a 4XX status
    (eg. ``412 Precondition failed`` or ``403 Unauthorized`` for example) the
    transaction is **not** rolled back.
