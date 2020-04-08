# Variables for common values
$resourceGroup = "Nikunj_test_RG"
$location = "westus"
$vmName = "test-win-01"
$virtual_net = "Nikunj-vnet"
$network_range = 10.1.0.0/16
$subnet_range = 10.1.1.0/24
$SubnetName = "subnet1"
$AllocationMethod = "Static" 
$IdleTimeoutInMinutes = 4
$myNetworkSecurityGroupRuleRDP = "myNetworkSecurityGroupRuleRDP"
$Protocol = "Tcp"
$Direction_Inbound = "Inbound"
$Inbound_Priority = 1000 
$DestinationPortRange = 3389
$Access = "Allow"
$myNetworkSecurityGroup = "myNetworkSecurityGroup"
$NIC_name = "myNic"
$VMSize = "Standard_D1"
$PublisherName = "MicrosoftWindowsServer"
$Offer = "WindowsServer"
$Skus = "2016-Datacenter"
$Version = "latest"

# Create user object
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create a resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $subnet_range

# Create a virtual network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
  -Name $virtual_net -AddressPrefix $network_range -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name "mypublicdns$(Get-Random)" -AllocationMethod $AllocationMethod -IdleTimeoutInMinutes $IdleTimeoutInMinutes

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name $myNetworkSecurityGroupRuleRDP  -Protocol $Protocol `
  -Direction $Direction_Inbound -Priority $Inbound_Priority -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange $DestinationPortRange -Access $Access

# Create a network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
  -Name $myNetworkSecurityGroup -SecurityRules $nsgRuleRDP

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name $NIC_name -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VMSize | `
Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
Set-AzVMSourceImage -PublisherName $PublisherName -Offer $Offer -Skus $Skus -Version $Version | `
Add-AzVMNetworkInterface -Id $nic.Id

# Create a virtual machine
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
