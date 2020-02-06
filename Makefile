SHELL=/bin/bash
GIT_REF=$(shell sh -c "git rev-parse --short HEAD")
export TOWER_OPENSHIFT_PROJECT=tower-e2e-${GIT_REF}

.PHONY test/e2e/prow:
test/e2e/prow: export TOWER_OPENSHIFT_PROJECT=tower-e2e-${OPENSHIFT_BUILD_NAMESPACE}
test/e2e/prow: export OPENSHIFT_MASTER=$(shell cat /usr/local/integr8ly-tower-secrets/OPENSHIFT_MASTER)
test/e2e/prow: export TOWER_LICENSE=$(shell cat /usr/local/integr8ly-tower-secrets/TOWER_LICENSE)
test/e2e/prow: export TOWER_OPENSHIFT_PASSWORD=$(shell cat /usr/local/integr8ly-tower-secrets/TOWER_OPENSHIFT_PASSWORD)
test/e2e/prow: export TOWER_OPENSHIFT_USERNAME=$(shell cat /usr/local/integr8ly-tower-secrets/TOWER_OPENSHIFT_USERNAME)
test/e2e/prow: export TOWER_PASSWORD=$(shell cat /usr/local/integr8ly-tower-secrets/TOWER_PASSWORD)
test/e2e/prow: export TOWER_USERNAME=$(shell cat /usr/local/integr8ly-tower-secrets/TOWER_USERNAME)
test/e2e/prow: test/e2e

.PHONY test/e2e:
test/e2e:
	scripts/e2e.sh