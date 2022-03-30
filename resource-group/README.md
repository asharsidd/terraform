This Terraform template will deploy two resource Groups in Azure
The variables file have two 'String' variables declared with default values. 
You may wish to remove default and pass on fresh values at the time of execution with -var parameter.

The main.tf have locals decalred which will take the value from variables.tf and then within resource group block we are running
a count for two loops so creating two Resource Groups in Azure