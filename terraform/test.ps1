az vm list-usage --location uksouth -o json | ConvertFrom-Json |
  Where-Object { ($_.name.value -like '*Family' -or $_.name.value -eq 'cores') -and ($_.limit - $_.currentValue) -ge 2 } |
  Select-Object @{n='Family';e={$_.name.localizedValue}}, @{n='Used';e={$_.currentValue}}, @{n='Limit';e={$_.limit}} |
  Sort-Object Family | Format-Table