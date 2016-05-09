VIRTUALENV = virtualenv
SPHINX_BUILDDIR = docs/build
VENV := $(shell echo $${VIRTUAL_ENV-.venv})
PYTHON = $(VENV)/bin/python
DEV_STAMP = $(VENV)/.dev_env_installed.stamp

.IGNORE: clean distclean maintainer-clean
.PHONY: all install virtualenv tests

OBJECTS = .venv .coverage

all: install-dev

install-dev: $(DEV_STAMP)
$(DEV_STAMP): $(PYTHON) requirements.txt
	$(VENV)/bin/pip install -Ur requirements.txt
	touch $(DEV_STAMP)

virtualenv: $(PYTHON)
$(PYTHON):
	$(VIRTUALENV) $(VENV)
	$(VENV)/bin/pip install -U pip

clean:
	find . -name '*.pyc' -delete
	find . -name '__pycache__' -type d | xargs rm -fr
	rm -fr $(SPHINX_BUILDDIR)

maintainer-clean: clean
	rm -fr .venv/

docs: install-dev
	$(VENV)/bin/sphinx-build -a -n -b html -d $(SPHINX_BUILDDIR)/doctrees docs/source/ $(SPHINX_BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(SPHINX_BUILDDIR)/html/index.html"
