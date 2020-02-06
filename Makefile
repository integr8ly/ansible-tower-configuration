SHELL=/bin/bash

.PHONY test/e2e:
test/e2e:
	echo "e2e test will go here"

.PHONY test/e2e/local:
test/e2e/local:
	scripts/e2e.sh