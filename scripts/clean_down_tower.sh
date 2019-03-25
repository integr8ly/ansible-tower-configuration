echo "Deleting job templates"
for i in $(tower-cli job_template list | awk '{print $1}' | grep -v id | grep -v ===); do tower-cli job_template delete $i; done
echo ""
echo "Deleting workflows"
for i in $(tower-cli workflow list | awk '{print $1}' | grep -v id | grep -v ===); do tower-cli workflow delete $i; done
echo ""
echo "Deleting projects"
for i in $(tower-cli project list | awk '{print $1}' | grep -v id | grep -v ===); do tower-cli project delete $i; done
echo ""
echo "Deleting credentials"
for i in $(tower-cli credential list | awk '{print $1}' | grep -v id | grep -v ===); do tower-cli credential delete $i; done
echo ""
echo "Deleting inventories"
for i in $(tower-cli inventory list | awk '{print $1}' | grep -v id | grep -v ===); do tower-cli inventory delete $i; done
echo ""
echo "Deleting organizations"
for i in $(tower-cli organization list | awk '{print $1}' | grep -v id | grep -v ===); do tower-cli organization delete $i; done
echo ""
echo "Deleting custom credential"
tower-cli credential_type delete -n le_privatekey
