Quickstart
==========

Run `make all` to automatically build the image and run all tests.
`make` without parameters shows more information.

Detailed description
====================

In this package a Docker container with SSH and HTTP services is created.
Makefile uses variables `IMAGENAME`, `PASSWORD` and `MAXCONNECTIONS`
to configure the name of the image, root password and number of concurrent
connections used in the test.

To build the image, type `make image`.

To run the container in background, type `make run`.

Testing is done via Python's `unittest`. The script (`runtests.py`) uses
two non-standard libraries: `paramiko` - for ssh connections and `locust` -
for stress-testing the web server. Test script must be run in virtualenv,
preferably by `make tests`.

Tests
=====

`test_ssh` simply makes sure that the client is able to open a connection to
the server.

`test_http` checks if the client is able to open the root document, by
confirming that the status is 200.

`test_many` is a little more sophisticated. It uses `locust` to simultanously
open `MAXCONNECTIONS` clients, which try to access both existing and
non-existing resources. `locust` leaves a CSV file with test statistics, which
is further used to make sure that there were no failed connections to the
existing resource and that all connections to a non-existing resource have
failed.

