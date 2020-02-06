SHELL=/bin/bash
GIT_REF=$(shell sh -c "git rev-parse --short HEAD")
export TOWER_OPENSHIFT_PROJECT=tower-e2e-${GIT_REF}

.PHONY test/e2e/prow:
test/e2e/prow:
	export TOWER_OPENSHIFT_PROJECT=tower-e2e-${OPENSHIFT_BUILD_NAMESPACE}
	make test/e2e

.PHONY test/e2e:
test/e2e:
	scripts/e2e.sh