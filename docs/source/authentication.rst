##############
Authentication
##############

.. _authentication:


By default, a relatively secure *Basic Auth* is enabled.


Basic Auth
==========

When creating an account, an ``api_key`` and an ``api_secret`` will be
associated to your account.

You will be able to use them to authenticate to the API.

Please add the ``Authorization`` HTTP header to your HTTP request::

    Authorization: Basic <basic_token>

The token shall be built using this formula ``base64("<api_key>:<api_secret>")``.

If the token has an invalid format, this will result in a ``401`` error response.

In case the ``api_key`` and ``api_secret`` does not match a ``401``
error response will be returned to not leak any information about the
``api_key`` existance.
