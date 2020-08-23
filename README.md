# dxatscale101 starter pack
---

> This starter pack is forked [salesforce dreamhouse-lwc](https://github.com/trailheadapps/dreamhouse-lwc) and converted into mdapi format

## Deploy starter pack to Developer Edition Org or a Trailhead Playground

1. If you haven't connected your playground already, authorize your playground and provide it with an alias

```
sfdx force:auth:web:login -d -a playground-1
```

2. Deploy starter pack to playground using alias

```
sfdx force:mdapi:deploy -u playgound-1 -d mdapi -w 30
```

3. Assign the dreamhouse permission set to the default user.

```
sfdx force:user:permset:assign -u playgound-1 -n dreamhouse
```

4. Import some sample data.
   
```
sfdx force:data:tree:import -p ./data/sample-data-plan.json -u playgound-1
```

5. If your org isn't already open, open it now: 
 
```
sfdx force:org:open -u playgound-1
```