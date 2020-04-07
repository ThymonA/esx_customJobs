# FiveM Custom ESX Jobs By TIGO
![Custom ESX Jobs](https://i.imgur.com/GtVGZ0c.png)
[![Thymon](https://i.imgur.com/3EquTNl.jpg)](https://www.tigodev.com)

[![Developer](https://img.shields.io/badge/Developer-TigoDevelopment-darkgreen)](https://github.com/TigoDevelopment)
[![Discord](https://img.shields.io/badge/Discord-Tigo%239999-purple)](https://discordapp.com/users/636509961375055882)
[![Version](https://img.shields.io/badge/Version-1.0.0-darkgreen)](https://github.com/TigoDevelopment/esx_customJobs/blob/master/version)
[![Version](https://img.shields.io/badge/License-MIT-darkgreen)](https://github.com/TigoDevelopment/esx_customJobs/blob/master/LICENSE)

### About Custom ESX Jobs

Custom ESX Jobs is a resource created by TIGO which combine all jobs in one working script. By modifying ESX and expanding es_extended, it is possible to work with permissions and adjust everything in real time. Jobs can be edited or added while the server is running (deleting a job must be done manually).

### Requirement
- **es_extended** | [GitHub](https://github.com/ESX-Org/es_extended)
- **mysql-async** | [GitHub](https://github.com/brouznouf/fivem-mysql-async)
- **async** | [GitHub](https://github.com/ESX-Org/async)
- **esx_skin** | [GitHub](https://github.com/ESX-Org/esx_skin)
- **esx_identity** | [GitHub](https://github.com/ESX-Org/esx_identity)

### Get Started
1) Copy **esx_customJobs** to your FXServer resource folder
2) Run the **esx_customJobs.sql** file in your FXServer database
3) Rename **esx_customJobs** to **esx_customjobs** (all lowercase)
4) Add **esx_customjobs** to your **sever.cfg** file
5) Start your server or resource

⚠️ **esx_customJobs.sql** adds table `job_account`, `job_safe` and `job_weapon`

### Add `esx:updateJob` to `es_extended`
To update jobs in real time, you need to modify your `es_extended`.
Add the function to `@es_extended/server/common.lua`.
```lua
AddEventHandler('esx:updateJob', function(job, grades)
	ESX.Jobs[job.name] = job
	ESX.Jobs[job.name].grades = grades

	if (ESX.Table.SizeOf(ESX.Jobs[job.name].grades) == 0) then
		ESX.Jobs[job.name] = nil
		print(('[es_extended] [^3WARNING^7] Ignoring job "%s" due to no job grades found'):format(job.name))
	end

	for source, xPlayer in pairs(ESX.Players) do
		if (xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == job.name) then
			local currentGrade = xPlayer.job.grade or 0
			local playerGradeExists = ESX.Jobs[job.name] ~= nil and ESX.Jobs[job.name].grades[tostring(currentGrade)] ~= nil

			if (playerGradeExists) then
				xPlayer.setJob(job.name, currentGrade)
			else
				xPlayer.setJob('unemployed', 0)
			end
		end
	end
end)
```

### Overview of all permissions in `esx_customJobs`
PermissionGroup | Permission | Description
:---------------|:-----------|:-----------
`safe.item.*` | `safe.item.add` | You can put items in the safe
`safe.item.*` | `safe.item.remove` | You can remove items from the safe
`safe.item.*` | `safe.item.buy` | You can buy items for the safe
`safe.weapon.*` | `safe.weapon.add` | You can put weapons in the safe
`safe.weapon.*` | `safe.weapon.remove` | Your can remove weapons from the safe
`safe.weapon.*` | `safe.weapon.buy` | You can buy weapons for the safe
`safe.account.*` | `safe.account.add` | You can add account money
`safe.account.*` | `safe.account.remove` | You can remove account money
`wardrobe.*` | `wardrobe.use` | You can use the wardrobe
`vehicle.*` | `vehicle.spawn` | You can spawn job vehicles
`vehicle.*` | `vehicle.park` | You can despawn vehicles

### Overview of all new triggers in `esx_customJobs`

##### [Server Event] esx_jobs:setJobMoney
When the balance of a job has been updated
Argument | Data Type | Optional | Default Value | Explanation
:--------|:----------|:---------|:--------------|:-----------
jobName | string | false | 'unknown' | Name of the organisation
account | string | false | | Account that has been updated
money | number | false | 0 | New balance of account

```lua
AddEventHandler('esx_jobs:setJobMoney', function(jobName, account, money)
    ....
end)
```

##### [Server Event] esx_jobs:addMoney
When money has been added to a job account balance
Argument | Data Type | Optional | Default Value | Explanation
:--------|:----------|:---------|:--------------|:-----------
jobName | string | false | 'unknown' | Name of the organisation
account | string | false | | Account that has been added
money | number | false | 0 | Added money

```lua
AddEventHandler('esx_jobs:addMoney', function(jobName, account, money)
    ....
end)
```

##### [Server Event] esx_jobs:removeMoney
When money has been removed from a job account balance
Argument | Data Type | Optional | Default Value | Explanation
:--------|:----------|:---------|:--------------|:-----------
jobName | string | false | 'unknown' | Name of the organisation
account | string | false | | Account that has been removed
money | number | false | 0 | Removed money

```lua
AddEventHandler('esx_jobs:removeMoney', function(jobName, account, money)
    ....
end)
```

##### [Server Event] esx_jobs:setMoney
When a new balance is set to job account
Argument | Data Type | Optional | Default Value | Explanation
:--------|:----------|:---------|:--------------|:-----------
jobName | string | false | 'unknown' | Name of the organisation
account | string | false | | Account that has been set
money | number | false | 0 | New account balance

```lua
AddEventHandler('esx_jobs:setMoney', function(jobName, account, money)
    ....
end)
```

##### [Server Event] esx_jobs:setJobItem
When the number of job items has been updated
Argument | Data Type | Optional | Default Value | Explanation
:--------|:----------|:---------|:--------------|:-----------
jobName | string | false | 'unknown' | Name of the organisation
itemName | string | false | | Item that has been updated
count | number | false | 0 | New count of item

```lua
AddEventHandler('esx_jobs:setJobItem', function(jobName, itemName, count)
    ....
end)
```

##### [Server Event] esx_jobs:addItem
When items has been added to job item
Argument | Data Type | Optional | Default Value | Explanation
:--------|:----------|:---------|:--------------|:-----------
jobName | string | false | 'unknown' | Name of the organisation
itemName | string | false | | Item that has been added
count | number | false | 0 | Number of added items

```lua
AddEventHandler('esx_jobs:addItem', function(jobName, itemName, count)
    ....
end)
```

##### [Server Event] esx_jobs:removeItem
When items has been removed to job item
Argument | Data Type | Optional | Default Value | Explanation
:--------|:----------|:---------|:--------------|:-----------
jobName | string | false | 'unknown' | Name of the organisation
itemName | string | false | | Item that has been removed
count | number | false | 0 | Number of removed items

```lua
AddEventHandler('esx_jobs:removeItem', function(jobName, itemName, count)
    ....
end)
```

##### [Server Event] esx_jobs:setItem
When a new count is set to job item
Argument | Data Type | Optional | Default Value | Explanation
:--------|:----------|:---------|:--------------|:-----------
jobName | string | false | 'unknown' | Name of the organisation
itemName | string | false | | Item that has been set
count | number | false | 0 | New count of item

```lua
AddEventHandler('esx_jobs:setItem', function(jobName, itemName, count)
    ....
end)
```

### License
MIT License

Copyright (c) 2020 Thymon Arens (TigoDevelopment)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


### Disclamer
---
This resource was created by me with all the knowledge at the time of writing. The request for new functionality is allowed but it does not mean that it will be released. Further development of this resource is permitted.
