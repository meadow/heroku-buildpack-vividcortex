# Heroku Buildpack: VividCortex

Installs VividCortex agents in a Heroku dyno.

## Usage

This buildpack installs VividCortex agents as part of the dyno build process. This works with PostgreSQL and MySQL, provided that pg_stat_statements or performance_schema, respectively, are enabled. Note that for PostgreSQL versions 9.2 and later it's enabled by default. This will not work with the "hobby" level Heroku PostgreSQL database offerings because they do not have "pg_stat_statements" enabled. We also support Redis and MongoDB, but only for showing charts. There's no query capture because there's no pg_stat_statements or performance_schema equivalent for them.

### Setup

You will first need a database in Heroku, for this example we will use Heroku PostgreSQL. If you don't have a database already add it from your administration page, add-on marketplace, or command line to your application project. Once added use the `heroku` command `heroku config:get DATABASE_URL` to get the credentials or get the url from your account database dashboard.

Next you will need a VividCortex account. If you don't have one, create one at [VividCortex](https://app.vividcortex.com).

On your machine create a new directory for the VividCortex agents project.

```
mkdir vc-agents
cd vc-agents
git init
echo "agents: vc-start" > Procfile
heroku create
```

Next we will add the Heroku VividCortex buildpack

```
heroku config:add BUILDPACK_URL=https://github.com/VividCortex/heroku-buildpack-vividcortex.git
```

In your account from the Hosts page add a new host by clicking the "Add New Host" button in the upper right. From "Where Is The Service You Want To Monitor?" choose the "Containerized" option. From the "Agents API Token" box copy the token and close the "Install VividCortex On A New Host" dialog.

Add the token to your Heroku config.

```
heroku config:add VC_API_TOKEN=<API_TOKEN>
```

Then commit and push this to Heroku master.

```
git add .
git commit -m "Adding VividCortex Agents"
git push heroku master
```

You should see that the build was successful. However agents will not start automatically. You will need to start them as a worker process by using the Heroku command. NOTE: Do not scale agents to more than 1. This will put unnecessary load on your database and you will be charged for additional agent licences.

```
heroku ps:scale agents=1
```

If you wish to stop agents just run.

```
heroku ps:scale agents=0
```

That's it! If everything is successful you will see "agents.1" host in the host table and the database you are trying to monitor listed.

### Monitoring Multiple Databases

You can monitor multiple databases from a single Heroku dyno. By passing in the databases urls in the DATABSE_URL variable as a comma separated values our agents will automatically register all of the databases.

Example

```
DATABASE_URL=postgres://user:pass@host1:port/db1,mysql://user:pass@host2:port/db2,mongo://user:pass@host3:port/db3,redis://user:pass@host3:port/db3
```

### Uninstalling

To remove the buildpack run the command and unset your VC_API_TOKEN.

```
heroku config:unset BUILDPACK_URL
heroku config:unset VC_API_TOKEN
```

Then remove the `agents: vc-start` definition from your Procfile.

If you run into any issues please open an issue here or contact support@vividcortex.com.
