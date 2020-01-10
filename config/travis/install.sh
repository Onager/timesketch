#!/bin/bash
#
# Script to set up Travis-CI test VM.

DPKG_PYTHON2_DEPENDENCIES="python-alembic python-altair python-amqp python-aniso8601 python-asn1crypto python-attr python-bcrypt python-billiard python-blinker python-bs4 python-celery python-certifi python-cffi python-chardet python-click python-configparser python-cryptography python-datasketch python-dateutil python-editor python-elasticsearch python-entrypoints python-enum34 python-flask python-flask-bcrypt python-flask-login python-flask-migrate python-flask-restful python-flask-script python-flask-sqlalchemy python-flask-wtf python-gunicorn python-idna python-ipaddress python-itsdangerous python-jinja2 python-jsonschema python-jwt python-kombu python-mako python-markupsafe python-neo4jrestclient python-numpy python-pandas python-parameterized python-pycparser python-pyrsistent python-redis python-requests python-six python-sqlalchemy python-toolz python-typing python-tz python-urllib3 python-vine python-werkzeug python-wtforms python-yaml python-oauthlib python-google-auth";
DPKG_PYTHON2_TEST_DEPENDENCIES="python-flask-testing python-funcsigs python-mock python-nose python-pip python-pbr python-setuptools";

DPKG_PYTHON3_DEPENDENCIES="python3-alembic python3-altair python3-amqp python3-aniso8601 python3-asn1crypto python3-attr python3-bcrypt python3-billiard python3-blinker python3-bs4 python3-celery python3-certifi python3-cffi python3-chardet python3-click python3-cryptography python3-datasketch python3-dateutil python3-editor python3-elasticsearch python3-entrypoints python3-flask python3-flask-bcrypt python3-flask-login python3-flask-migrate python3-flask-restful python3-flask-script python3-flask-sqlalchemy python3-flask-wtf python3-gunicorn python3-idna python3-ipaddress python3-itsdangerous python3-jinja2 python3-jsonschema python3-jwt python3-kombu python3-mako python3-markupsafe python3-neo4jrestclient python3-numpy python3-pandas python3-parameterized python3-pycparser python3-pyrsistent python3-redis python3-requests python3-six python3-sqlalchemy python3-toolz python3-tz python3-urllib3 python3-vine python3-werkzeug python3-wtforms python3-yaml python3-oauthlib python3-google-auth";
DPKG_PYTHON3_TEST_DEPENDENCIES="python3-distutils python3-flask-testing python3-mock python3-nose python3-pip python3-pbr python3-setuptools";

# Exit on error.
set -e;

#if test -n "${UBUNTU_VERSION}";
if test ${MODE} = "dpkg"; then
	CONTAINER_NAME="ubuntu${UBUNTU_VERSION}";
	docker pull ubuntu:${UBUNTU_VERSION};
	docker run --name=${CONTAINER_NAME} --detach -i ubuntu:${UBUNTU_VERSION};

	# Install add-apt-repository and locale-gen.
	docker exec ${CONTAINER_NAME} apt-get update -q;
	docker exec -e "DEBIAN_FRONTEND=noninteractive" ${CONTAINER_NAME} sh -c "apt-get install -y locales software-properties-common";
	docker exec ${CONTAINER_NAME} add-apt-repository universe -y;

	# Add additional apt repositories.
	if test ${TARGET} = "pylint";
	then
		docker exec ${CONTAINER_NAME} add-apt-repository ppa:gift/pylint3 -y;
	fi
	docker exec ${CONTAINER_NAME} add-apt-repository ppa:gift/dev -y;

	docker exec ${CONTAINER_NAME} apt-get update -q;

	# Set locale to US English and UTF-8.
	docker exec ${CONTAINER_NAME} locale-gen en_US.UTF-8;

	# Install packages.
	DPKG_PACKAGES="git";

	if test ${TARGET} = "pylint"; then
		DPKG_PACKAGES="${DPKG_PACKAGES} python3-distutils pylint";
	fi

	if test ${TRAVIS_PYTHON_VERSION} = "2.7"; then
		DPKG_PACKAGES="${DPKG_PACKAGES} python ${DPKG_PYTHON2_DEPENDENCIES} ${DPKG_PYTHON2_TEST_DEPENDENCIES}";
	else
		DPKG_PACKAGES="${DPKG_PACKAGES} python3 ${DPKG_PYTHON3_DEPENDENCIES} ${DPKG_PYTHON3_TEST_DEPENDENCIES}";
	fi

	docker exec -e "DEBIAN_FRONTEND=noninteractive" ${CONTAINER_NAME} sh -c "apt-get install -y ${DPKG_PACKAGES}";
	docker cp ../timesketch ${CONTAINER_NAME}:/

elif test ${MODE} = "pypi"; then
	pip install -r requirements.txt;
	pip install -r test_requirements.txt;

elif test ${TRAVIS_OS_NAME} = "linux"; then
	pip install -r requirements.txt;
	pip install -r test_requirements.txt;
fi
