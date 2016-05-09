.. _endpoints:

##################
Resource endpoints
##################

All :term:`endpoints` URLs are prefixed by the major version of the :term:`HTTP API`
(e.g /v0/ for 0.1).

e.g. the URL for all the endpoints is structured as follows:::

    https://<server name>/<api MAJOR version>/<further instruction>


The full URL prefix will be implied throughout the rest of this document and
it will only describe the **<further instruction>** part.


GET /proofs
===========

**Requires authentication**

Returns the list of proofs and their status.

The returned value is a JSON mapping containing:

- ``data``: the list of proofs, with exhaustive fields;

A ``Total-Records`` response header indicates the total number of records
of the collection.

A ``Last-Modified`` response header provides a human-readable (rounded to second)
of the current collection timestamp.

For cache and concurrency control, an ``ETag`` response header gives the
value that consumers can provide in subsequent requests using ``If-Match``
and ``If-None-Match`` headers (see :ref:`section about timestamps <server-timestamps>`).

**Request**:

.. code-block:: http

    GET /proofs HTTP/1.1
    Accept: application/json
    Authorization: Basic bWF0Og==
    Host: localhost:8000

**Response**:

.. code-block:: http

    HTTP/1.1 200 OK
    Access-Control-Allow-Origin: *
    Access-Control-Expose-Headers: Backoff, Retry-After, Alert, Content-Length, ETag, Next-Page, Total-Records, Last-Modified
    Content-Length: 436
    Content-Type: application/json; charset=UTF-8
    Date: Tue, 28 Apr 2015 12:08:11 GMT
    Last-Modified: Mon, 12 Apr 2015 11:12:07 GMT
    ETag: "1430222877724"
    Total-Records: 2

    {
        "data": [
            {
                "id": "dc86afa9-a839-4ce1-ae02-3d538b75496f",
                "last_modified": 1430222877724,
                "hash": "9151f629f6ce298f5a218ddfe49c317f2a6f10b40abaad59470780f62103d57e",
				"algorithm": "sha256",
                "metadata": {"filename": "20160521-file.pdf"}
            },
            {
                "id": "23160c47-27a5-41f6-9164-21d46141804d",
                "last_modified": 1430140411480,
                "hash": "6ce20976d4590131fbdc181e1c8855cb06e3cfa19812569c0f7d4a134163e752",
                "algorithm": "sha256",
				"metadata": {"filename": "20160423-file.odf"}
            }
        ]
    }


Counting
--------

In order to count the number of records, for a specific field value for example,
without fetching the actual collection, a ``HEAD`` request can be
used. The ``Total-Records`` response header will then provide the
total number of records.


Polling for changes
-------------------

The ``_since`` parameter is provided as an alias for ``gt_last_modified``.

* ``/proofs?_since=1437035923844``

If the ``If-None-Match: "<timestamp>"`` request header is provided as described in
the :ref:`section about timestamps <server-timestamps>` and if the
collection was not changed, a ``304 Not Modified`` response is returned.

.. note::

    ``_since`` also accept a value between quotes (``"``) as
    it would be returned in the ``ETag`` response header
    (see :ref:`response timestamps <server-timestamps>`).

**Request**:

.. code-block:: http

    GET /proofs?_since=1437035923844 HTTP/1.1
    Accept: application/json
    Authorization: Basic bWF0Og==
    Host: localhost:8000

**Response**:

.. code-block:: http

    HTTP/1.1 200 OK
    Access-Control-Allow-Origin: *
    Access-Control-Expose-Headers: Backoff, Retry-After, Alert, Content-Length, ETag, Next-Page, Total-Records, Last-Modified
    Content-Length: 436
    Content-Type: application/json; charset=UTF-8
    Date: Tue, 28 Apr 2015 12:08:11 GMT
    Last-Modified: Mon, 12 Apr 2015 11:12:07 GMT
    ETag: "1430222877724"
    Total-Records: 2

    {
        "data": [
            {
                "id": "dc86afa9-a839-4ce1-ae02-3d538b75496f",
                "last_modified": 1430222877724,
                "hash": "9151f629f6ce298f5a218ddfe49c317f2a6f10b40abaad59470780f62103d57e",
				"algorithm": "sha256",
                "metadata": {"filename": "20160521-file.pdf"}
            },
            {
                "id": "23160c47-27a5-41f6-9164-21d46141804d",
                "last_modified": 1430140411480,
                "hash": "6ce20976d4590131fbdc181e1c8855cb06e3cfa19812569c0f7d4a134163e752",
                "algorithm": "sha256",
				"metadata": {"filename": "20160423-file.odf"}
            }
        ]
    }


Paginate
--------

If the ``_limit`` parameter is provided, the number of records returned is limited.

If there are more records for this collection than the limit, the
response will provide a ``Next-Page`` header with the URL for the
Next-Page.

When there is no more ``Next-Page`` response header, there is nothing
more to fetch.

Pagination works with sorting, filtering and polling.

.. note::

    The ``Next-Page`` URL will contain a continuation token (``_token``).

    It is recommended to add precondition headers (``If-Match`` or
    ``If-None-Match``), in order to detect changes on collection while
    iterating through the pages.


Partial response
----------------

If the ``_fields`` parameter is provided, only the fields specified are returned.
Fields are separated with a comma.

This is vital in mobile contexts where bandwidth usage must be optimized.

Nested objects fields are specified using dots (e.g. ``address.street``).

.. note::

    The ``id`` and ``last_modified`` fields are always returned.

**Request**:

.. code-block:: http

    GET /proofs?_fields=hash,algorithm
    Accept: application/json
    Authorization: Basic bWF0Og==
    Host: localhost:8000

**Response**:

.. code-block:: http

    HTTP/1.1 200 OK
    Access-Control-Allow-Origin: *
    Access-Control-Expose-Headers: Backoff, Retry-After, Alert, Content-Length, ETag, Next-Page, Total-Records, Last-Modified
    Content-Length: 436
    Content-Type: application/json; charset=UTF-8
    Date: Tue, 28 Apr 2015 12:08:11 GMT
    Last-Modified: Mon, 12 Apr 2015 11:12:07 GMT
    ETag: "1430222877724"
    Total-Records: 2

    {
        "data": [
            {
                "id": "dc86afa9-a839-4ce1-ae02-3d538b75496f",
                "last_modified": 1430222877724,
                "hash": "9151f629f6ce298f5a218ddfe49c317f2a6f10b40abaad59470780f62103d57e",
				"algorithm": "sha256"
            },
            {
                "id": "23160c47-27a5-41f6-9164-21d46141804d",
                "last_modified": 1430140411480,
                "hash": "6ce20976d4590131fbdc181e1c8855cb06e3cfa19812569c0f7d4a134163e752",
                "algorithm": "sha256"
            }
        ]
    }


List of available URL parameters
--------------------------------

- ``_since``: polling changes
- ``_limit``: pagination max size
- ``_token``: pagination token
- ``_fields``: filter the fields of the records


Filtering, sorting, partial responses and paginating can all be combined together.

* ``/proofs?_sort=-last_modified&_limit=100&_fields=title``


HTTP Status Codes
-----------------

* ``200 OK``: The request was processed
* ``304 Not Modified``: Collection did not change since value in ``If-None-Match`` header
* ``400 Bad Request``: The request querystring is invalid
* ``401 Unauthorized``: The request is missing authentication headers
* ``403 Forbidden``: The user is not allowed to perform the operation, or the
  resource is not accessible
* ``406 Not Acceptable``: The client doesn't accept supported responses Content-Type
* ``412 Precondition Failed``: Collection changed since value in ``If-Match`` header


POST /proofs
============

**Requires authentication**

Used to create a record in the collection. The POST body is a JSON mapping
containing:

- ``data``: the values of the resource schema fields;

The POST response body is a JSON mapping containing:

- ``data``: the newly created record, if all posted values are valid;

If the ``If-Match: "<timestamp>"`` request header is provided as described in
the :ref:`section about timestamps <server-timestamps>`, and if the collection has
changed meanwhile, a ``412 Precondition failed`` error is returned.

If the ``If-None-Match: *`` request header is provided, and if the provided ``data``
contains an ``id`` field, and if there is already an existing record with this ``id``,
a ``412 Precondition failed`` error is returned.


**Request**:

.. code-block:: http

    POST /proofs HTTP/1.1
    Accept: application/json
    Authorization: Basic bWF0Og==
    Content-Type: application/json; charset=utf-8
    Host: localhost:8000

    {
        "data": {
            "hash": "da237013ec0cc224f758d5ebef4bdfe76c440eddd542de08bdfecbdc7a110f22",
            "algorithm": "sha256",
            "metadata": {"filename": "20160321-diploma.pdf"}
        }
    }

**Response**:

.. code-block:: http

    HTTP/1.1 201 Created
    Access-Control-Allow-Origin: *
    Access-Control-Expose-Headers: Backoff, Retry-After, Alert, Content-Length
    Content-Length: 422
    Content-Type: application/json; charset=UTF-8
    Date: Tue, 28 Apr 2015 12:35:02 GMT

    {
        "data": {
            "id": "d10405bf-8161-46a1-ac93-a1893d160e62",
            "last_modified": 1430224502529,
            "hash": "da237013ec0cc224f758d5ebef4bdfe76c440eddd542de08bdfecbdc7a110f22",
            "algorithm": "sha256",
            "metadata": {"filename": "20160321-diploma.pdf"}
        }
    }


Validation
----------

If the posted values are invalid (e.g. *field value is not an integer*)
an error response is returned with status ``400``.

See :ref:`details on error responses <error-responses>`.


Conflicts
---------

Since some fields can be defined as unique per collection, some conflicts
may appear when creating records.

.. note::

    Empty values are not taken into account for field unicity.

If a conflict occurs, an error response is returned with status ``409``.
A ``details`` attribute in the response provides the offending record and
field name. See :ref:`dedicated section about errors <error-responses>`.


Timestamp
---------

When a record is created, the timestamp of the collection is incremented.

It is possible to force the timestamp if the specified record has a
``last_modified`` field.

If the specified timestamp is in the past, the collection timestamp does not
take the value of the created record but is bumped into the future as usual.


HTTP Status Codes
-----------------

* ``200 OK``: This record already exists, the one stored on the database is returned
* ``201 Created``: The record was created
* ``400 Bad Request``: The request body is invalid
* ``401 Unauthorized``: The request is missing authentication headers
* ``403 Forbidden``: The user is not allowed to perform the operation, or the
  resource is not accessible
* ``406 Not Acceptable``: The client doesn't accept supported responses Content-Type
* ``409 Conflict``: Unicity constraint on fields is violated
* ``412 Precondition Failed``: Collection changed since value in ``If-Match`` header
* ``415 Unsupported Media Type``: The client request was not sent with a correct Content-Type


GET /proofs/<id>
================

**Requires authentication**

Returns a specific record by its id. The GET response body is a JSON mapping
containing:

- ``data``: the record with exhaustive schema fields;

If the ``If-None-Match: "<timestamp>"`` request header is provided, and
if the record has not changed meanwhile, a ``304 Not Modified`` is returned.

**Request**:

.. code-block:: http

    GET /proofs/d10405bf-8161-46a1-ac93-a1893d160e62 HTTP/1.1
    Accept: application/json
    Authorization: Basic bWF0Og==
    Host: localhost:8000

**Response**:

.. code-block:: http

    HTTP/1.1 200 OK
    Access-Control-Allow-Origin: *
    Access-Control-Expose-Headers: Backoff, Retry-After, Alert, Content-Length, ETag, Last-Modified
    Content-Length: 438
    Content-Type: application/json; charset=UTF-8
    Date: Tue, 28 Apr 2015 12:42:42 GMT
    ETag: "1430224945242"

    {
        "data": {
            "id": "d10405bf-8161-46a1-ac93-a1893d160e62",
            "last_modified": 1430224945242,
            "hash": "da237013ec0cc224f758d5ebef4bdfe76c440eddd542de08bdfecbdc7a110f22",
            "algorithm": "sha256",
            "metadata": {"filename": "20160321-diploma.pdf"}
        }
    }


HTTP Status Code
----------------

* ``200 OK``: The request was processed
* ``304 Not Modified``: Record did not change since value in ``If-None-Match`` header
* ``401 Unauthorized``: The request is missing authentication headers
* ``403 Forbidden``: The user is not allowed to perform the operation, or the
  resource is not accessible
* ``406 Not Acceptable``: The client doesn't accept supported responses Content-Type
* ``412 Precondition Failed``: Record changed since value in ``If-Match`` header


PATCH /proofs/<id>
==================

**Requires authentication**

Modify a specific record metadata by its id. The PATCH body is a JSON mapping containing:

- ``data``: a subset of the resource schema fields (*key-value replace*);

The PATCH response body is a JSON mapping containing:

- ``data``: the modified record (*full by default*);

**Request**:

.. code-block:: http

    PATCH /proofs/d10405bf-8161-46a1-ac93-a1893d160e62 HTTP/1.1
    Accept: application/json
    Authorization: Basic bWF0Og==
    Content-Type: application/json; charset=utf-8
    Host: localhost:8000

    {
        "data": {
            "metadata": {
                "title": "Diplôme de réussite en HTML"
            }
        }
    }

**Response**:

.. code-block:: http

    HTTP/1.1 200 OK
    Access-Control-Allow-Origin: *
    Access-Control-Expose-Headers: Backoff, Retry-After, Alert, Content-Length
    Content-Length: 439
    Content-Type: application/json; charset=UTF-8
    Date: Tue, 28 Apr 2015 12:46:36 GMT
    ETag: "1430225196396"

    {
        "data": {
            "id": "d10405bf-8161-46a1-ac93-a1893d160e62",
            "last_modified": 1430225196396,
            "hash": "da237013ec0cc224f758d5ebef4bdfe76c440eddd542de08bdfecbdc7a110f22",
            "algorithm": "sha256",
            "metadata": {
                "title": "Diplôme de réussite en HTML"
            }
        }
    }


If the record is missing, a ``404 Not Found`` error is returned.
The consumer might decide to ignore it.

If the ``If-Match: "<timestamp>"`` request header is provided as described in
the :ref:`section about timestamps <server-timestamps>`, and if the record has
changed meanwhile, a ``412 Precondition failed`` error is returned.


.. note::

    ``last_modified`` is updated to the current server timestamp, only if a
    field value was changed.

Read-only fields
----------------

If a read-only field is modified, a ``400 Bad request`` error is returned.

Metadata fields are the only ones that can be updated after a proof
have been added.


Conflicts
---------

If changing a record field violates a field unicity constraint (on the
hash for instance), a ``409 Conflict`` error response is returned (see
:ref:`error channel <error-responses>`).


Timestamp
---------

When a record is modified, the timestamp of the collection is incremented.

It is possible to force the timestamp if the specified record has a
``last_modified`` field.

If the specified timestamp is less or equal than the existing record,
the value is simply ignored and the timestamp is bumped into the future as usual.


HTTP Status Code
----------------

* ``200 OK``: The record was modified
* ``400 Bad Request``: The request body is invalid, or a read-only field was
  modified
* ``401 Unauthorized``: The request is missing authentication headers
* ``403 Forbidden``: The user is not allowed to perform the operation, or the
  resource is not accessible
* ``406 Not Acceptable``: The client doesn't accept supported responses Content-Type.
* ``409 Conflict``: If modifying this record violates a field unicity constraint
* ``412 Precondition Failed``: Record changed since value in ``If-Match`` header
* ``415 Unsupported Media Type``: The client request was not sent with a correct Content-Type.
