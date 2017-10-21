$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

New-AzureRmResourceGroup -Name myResourceGroupFromImage -Location EastUS

$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
   -Name mySubnet `
   -AddressPrefix 192.168.1.0/24

$vnet = New-AzureRmVirtualNetwork `
   -ResourceGroupName myResourceGroupFromImage `
   -Location EastUS `
   -Name MYvNET `
   -AddressPrefix 192.168.0.0/16 `
   -Subnet $subnetConfig

$pip = New-AzureRmPublicIpAddress `
   -ResourceGroupName myResourceGroupFromImage `
   -Location EastUS `
   -Name "mypublicdns$(Get-Random)" `
   -AllocationMethod Static `
   -IdleTimeoutInMinutes 4

 $nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig `
   -Name myNetworkSecurityGroupRuleWeb `
   -Protocol Tcp `
   -Direction Inbound `
   -Priority 1000 `
   -SourceAddressPrefix * `
   -SourcePortRange * `
   -DestinationAddressPrefix * `
   -DestinationPortRange 80 `
   -Access Allow

 $nsg = New-AzureRmNetworkSecurityGroup `
   -ResourceGroupName myResourceGroupFromImage `
   -Location EastUS `
   -Name myNetworkSecurityGroup `
   -SecurityRules $nsgRuleWeb

$nic = New-AzureRmNetworkInterface `
   -Name myNic `
   -ResourceGroupName myResourceGroupFromImage `
   -Location EastUS `
   -SubnetId $vnet.Subnets[0].Id `
   -PublicIpAddressId $pip.Id `
   -NetworkSecurityGroupId $nsg.Id

$vmConfig = New-AzureRmVMConfig `
   -VMName myVMfromImage `
   -VMSize Standard_D1 | Set-AzureRmVMOperatingSystem -Linux `
       -ComputerName myComputer `
       -Credential $cred

# Here is where we create a variable to store information about the image
$image = Get-AzureRmImage `
   -ImageName myImage `
   -ResourceGroupName myResourceGroup

# Here is where we specify that we want to create the VM from and image and provide the image ID
$vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig -Id $image.Id

$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

New-AzureRmVM `
   -ResourceGroupName myResourceGroupFromImage `
   -Location EastUS `
   -VM $vmConfig
