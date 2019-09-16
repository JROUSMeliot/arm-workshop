#Aide memoire

#Login to Azure
Az login
Pause

#check account
Az account show 

#Connect to Azure
Connect-AzAccount

#voir les subscriptions
Get-AzSubscription

#changer context to IT Primary
Get-AzSubscription -SubscriptionId "823c312b-c266-4f6b-a93e-4b71bf0af10e" -TenantId "bd2ac3b4-122a-4000-ac98-779c8efd4722" | Set-AzContext

#See Resource Groups
Get-AzResourceGroup * | Format-Table #See All
Get-AzResourceGroup -location 'West Europe' | Format-Table #See WestEurope

#See VMs (With Status)
get-azvm -resourcegroupname zeu1-bis-prd-testdc* -status
get-azvm -resourcegroupname zeu1-bis-prd-testdc* -status | select Name,Powerstate

#See Disk for a VM
$RG='zeu1-bis-prd-testdc-rg'
$VM='zeu1spdc02'
$vm_current = Get-AzVM -Name $VM
$disk_name = $vm_current.StorageProfile.OsDisk.Name
get-azdisk $RG $disk_name | select Name,DiskSizeGB

Get-AzVM -name zeu1spdc01
Get-AzDisk  | select ResourceGroupName,TimeCreated,OsType,DiskSizeGB

#Create ResourceGroup in NON-PROD
$tagsRG=(Get-AzResourceGroup -Name zeu1-bis-prd-testdc-rg).tags
New-AzResourceGroup -Name zeu1-bis-npd-testdc-rg -Location "West Europe" -tag $tagsRG

#Create AvailabilitySet PROD App
$tag_as=(Get-AzAvailabilitySet -resourcegroupname zeu1-bis-prd-testdc-rg -Name zeu1-bis-prd-testdc-appdc-as).Tags
New-AzAvailabilitySet -ResourceGroupName zeu1-bis-prd-testdc-rg -name zeu1-bis-prd-testdc-appdc-as -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 3 -Location westeurope -Sku Aligned -tag $tag_as

#Create AvailabilitySet PROD Data
$tag_as=(Get-AzAvailabilitySet -resourcegroupname zeu1-bis-prd-testdc-rg -Name zeu1-bis-prd-testdc-appdc-as).Tags
New-AzAvailabilitySet -ResourceGroupName zeu1-bis-prd-testdc-rg -name zeu1-bis-prd-testdc-datadc-as -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 3 -Location westeurope -Sku Aligned -tag $tag_as

#Create AvailabilitySet NON-PROD App
$tag_as=(Get-AzAvailabilitySet -resourcegroupname zeu1-bis-prd-testdc-rg -Name zeu1-bis-prd-testdc-appdc-as).Tags
New-AzAvailabilitySet -ResourceGroupName zeu1-bis-npd-testdc-rg -name zeu1-bis-npd-testdc-appdc-as -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 3 -Location westeurope -Sku Aligned -tag $tag_as

#Create AvailabilitySet NON-PROD Data
$tag_as=(Get-AzAvailabilitySet -resourcegroupname zeu1-bis-npd-testdc-rg -Name zeu1-bis-npd-testdc-appdc-as).Tags
New-AzAvailabilitySet -ResourceGroupName zeu1-bis-npd-testdc-rg -name zeu1-bis-npd-testdc-datadc-as -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 3 -Location westeurope -Sku Aligned -tag $tag_as

#Deployment DC01 in PROD App
New-AzResourceGroupDeployment -ResourceGroupName zeu1-bis-prd-testdc-rg -TemplateFile AzureVM.json -TemplateParameterFile ValidVM_PROD_App.parameters.json

#Deployment DC002 in PROD Data
New-AzResourceGroupDeployment -ResourceGroupName zeu1-bis-prd-testdc-rg -TemplateFile AzureVM.json -TemplateParameterFile ValidVM_PROD_Data.parameters.json

#Deployment DC003 in NON-PROD App
New-AzResourceGroupDeployment -ResourceGroupName zeu1-bis-npd-testdc-rg -TemplateFile AzureVM.json -TemplateParameterFile ValidVM_NPD_App.parameters.json

#Deployment DC04 in NON-PROD data
New-AzResourceGroupDeployment -ResourceGroupName zeu1-bis-npd-testdc-rg -TemplateFile AzureVM.json -TemplateParameterFile ValidVM_NPD_data.parameters.json