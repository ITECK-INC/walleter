PYTHON=python2.7

ENV_DIR=.env_$(PYTHON)

ifeq ($(OS),Windows_NT)
	IN_ENV=. $(ENV_DIR)/Scripts/activate &&
else
	IN_ENV=. $(ENV_DIR)/bin/activate &&
endif

all: test lint docs artifacts

env: $(ENV_DIR)

test: build
	$(IN_ENV) nosetests -v -w tests --with-xunit --xunit-file=nosetests.xml --with-coverage --cover-erase --cover-xml  --cover-package walleter

artifacts: build_reqs rpm sdist

$(ENV_DIR):
	virtualenv -p $(PYTHON) $(ENV_DIR)

build_reqs: env
	$(IN_ENV) pip install -U sphinx pep8 coverage nose pip

build: build_reqs
	$(IN_ENV) pip install -U --editable .

sdist: build_reqs
	$(IN_ENV) python setup.py sdist

rpm: build_reqs
	$(IN_ENV) rpmbuild --define '_topdir '`pwd` -bb SPECS/*.spec

lint: pep8

pep8: build_reqs
	- $(IN_ENV) pep8 src/walleter > pep8.out

docs: build_reqs
	$(IN_ENV) pip install -r docs/requirements.txt
	$(IN_ENV) $(MAKE) -C docs html man

freeze: env
	- $(IN_ENV) pip freeze

run: build
	$(IN_ENV) walleter -l DEBUG

clean:
	- @rm -rf BUILD
	- @rm -rf BUILDROOT
	- @rm -rf RPMS
	- @rm -rf SRPMS
	- @rm -rf SOURCES
	- @rm -rf docs/build
	- @rm -rf src/*.egg-info
	- @rm -rf build
	- @rm -rf dist
	- @rm -f .coverage
	- @rm -f test_results.xml
	- @rm -f nosetests.xml
	- @rm -f coverage.xml
	- @rm -f tests/coverage.xml
	- @rm -f pep8.out
	- find -name '*.pyc' -delete
	- find -name '*.pyo' -delete
	- find -name '*.pyd' -delete

env_clean: clean
	- @rm -rf .env
	- @rm -rf .env_python2.6
	- @rm -rf $(ENV_DIR)
