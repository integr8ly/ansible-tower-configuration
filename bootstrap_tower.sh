###################################################
# Authenticate with tower
TOWER_HOST="example.com"
TOWER_ADMIN_USER="admin"
TOWER_ADMIN_PASSWORD="really secure"

tower-cli config host $TOWER_HOST
tower-cli login $TOWER_ADMIN_USER --password "$TOWER_ADMIN_PASSWORD"



##################################################
# Configure Authentication via Github
tower-cli setting modify SOCIAL_AUTH_GITHUB_ORG_NAME "github_organisation"
tower-cli setting modify SOCIAL_AUTH_GITHUB_ORG_KEY "key"
tower-cli setting modify SOCIAL_AUTH_GITHUB_ORG_SECRET "secret"
tower-cli setting modify SOCIAL_AUTH_GITHUB_ORG_ORGANIZATION_MAP "{'integreately-eng': {'admins': True, 'users': True}}"
tower-cli setting modify SOCIAL_AUTH_GITHUB_ORG_TEAM_MAP "{'integreately-eng-team': {'organization': 'integreately-eng', 'users': True}}"



###################################################
# Create credentials
github_cred_inputs='username: ""
password: ""
ssh_key_unlock: "Do you need a password to unlock this github key?"
ssh_key_data: |
  -----BEGIN RSA PRIVATE KEY-----
  If you have a private key that you need to use to access some private github repo
  etc, then fire it in here.
  -----END RSA PRIVATE KEY-----'

tower-cli credential create --name "awx_playbook_testing_github" --credential-type "Source Control" --organization "integreately-eng" --inputs "$github_cred_inputs"

machine_cred_inputs='username: ""
password: ""
ssh_key_data: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  If you have a private key that Tower might use to make SSH connections to infrastructure
  then put it in here maybe.
  -----END OPENSSH PRIVATE KEY-----'

tower-cli credential create --name "awx_playbook_testing_ssh" --credential-type "Machine" --organization "integreately-eng" --inputs "$machine_cred_inputs"

vault_cred_inputs='{"vault_password": "vault"}'
tower-cli credential create --name "awx_playbook_testing_vault" --credential-type "Vault" --organization "integreately-eng" --inputs "$vault_cred_inputs"

vault_cred_inputs='{"vault_password": "If you have a vault password to decrypt your variables put it here etc"}'
tower-cli credential create --name "sendgrid_vault" --credential-type "Vault" --organization "integreately-eng" --inputs "$vault_cred_inputs"


##################################################
# Create Project
tower-cli project create --name "awx_playbook_testing" --organization "integreately-eng" --scm-type "git" --scm-url "https://github.com/integr8ly/ansible-tower-configuration.git" --scm-credential "awx_playbook_testing_github" --scm-branch "master" --scm-update-cache-timeout 60
tower-cli project update --name "awx_playbook_testing" --wait



##################################################
# Create Inventory
tower-cli inventory create --name "gr8-sre" --organization "integreately-eng" 
tower-cli inventory_source create --name "gr8-sre_source" --inventory "gr8-sre" --source "scm" --source-project "awx_playbook_testing" --source-path "inventory/hosts" --update-on-project-update true
tower-cli inventory_source update "gr8-sre_source" --wait



##################################################
# Create Job Templates
tower-cli job_template create --name "Sample Ansible Vault" --job-type "run" --inventory "gr8-sre" --project "awx_playbook_testing" --playbook "playbooks/ansible_vault_example.yml" --credential "awx_playbook_testing_ssh" --vault-credential "awx_playbook_testing_vault"

# Create intermediate, success, fail Job Templates
tower-cli job_template create --name "Intermediate Job" --job-type "run" --inventory "gr8-sre" --project "awx_playbook_testing" --playbook "playbooks/intermediate_playbook.yml" --credential "awx_playbook_testing_ssh" 2>&1 | tee output.log
INTERMEDIATE_ID=$(grep "Intermediate Job" output.log | cut -d' ' -f1)
echo "intermediate_id id: $INTERMEDIATE_ID"

tower-cli job_template create --name "on_success" --job-type "run" --inventory "gr8-sre" --project "awx_playbook_testing" --playbook "playbooks/on_success.yml" --credential "awx_playbook_testing_ssh" 2>&1 | tee output.log
ON_SUCCESS_ID=$(grep "on_success" output.log | cut -d' ' -f1)
echo "on_success id: $ON_SUCCESS_ID"

tower-cli job_template create --name "on_fail" --job-type "run" --inventory "gr8-sre" --project "awx_playbook_testing" --playbook "playbooks/on_fail.yml" --credential "awx_playbook_testing_ssh" 2>&1 | tee output.log
ON_FAIL_ID=$(grep "on_fail" output.log | cut -d' ' -f1)
echo "on_fail id: $ON_FAIL_ID"

tower-cli job_template create --name "Sendgrid Integreatly POC Notification" --job-type "run" --inventory "gr8-sre" --project "awx_playbook_testing" --playbook "playbooks/integreatly_sendgrid_poc_provision.yml" --vault-credential "sendgrid_vault"

tower-cli job_template create --name "Create RHPDS Inventory" --job-type "run" --inventory "gr8-sre" --project "awx_playbook_testing" --playbook "playbooks/integreatly_create_rhpds_inventory.yml" --vault-credential "sendgrid_vault"


# create Workflow job, and add multiple steps to the workflow
tower-cli workflow create --name="Sample Workflow Template" --organization "integreately-eng"
tower-cli node create -W "Sample Workflow Template" --job-template="Intermediate Job" 2>&1 | tee output.log
INT_NODE_ID=$(grep -oP '^.\d+' output.log)
tower-cli node create -W "Sample Workflow Template" --job-template="on_fail" 2>&1 | tee output.log
FAIL_NODE_ID=$(grep -oP '^.\d+' output.log)
tower-cli node create -W "Sample Workflow Template" --job-template="on_success" 2>&1 | tee output.log
SUCCESS_NODE_ID=$(grep -oP '^.\d+' output.log)
tower-cli node associate_success_node $INT_NODE_ID $SUCCESS_NODE_ID -W "Sample Workflow Template"
tower-cli node associate_failure_node $INT_NODE_ID $FAIL_NODE_ID -W "Sample Workflow Template"

# Add survey to the job
tower-cli workflow modify --name="Sample Workflow Template" --survey-spec=@survey_spec.json --survey-enabled=true
