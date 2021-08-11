# Managing, sheltering, grooming and nurturing your own custom Archipelago 

Now that you have your base Archipelago Live Deployment running (Do you? if not [go back!](../README.md)) you may be wondering about things like:

1. What happens when i need to update to the next release?
2. How do i keep my Drupal and Modules updated inbetween releases?
3. Can i add Drupal Modules?
2. Will a new release overwrite all my customizations?
3. What things are safe to customize?
4. How do i keep my very own things in Version Control and safe from others?
5. And many (many) other similar questions

## 1. Keep your Archipelago under Version Control via Github

`Archipelagos` are live beings. They evolve and become beautiful, closer and closer to your needs. Because of that `resetting` 
your particularities on every `Archipelago` code release is not a good idea nor even recommended. 
What you want is to keep your own `Drupal Settings` safe and be able to restore all in case something goes wrong. 
Your facets, your themes, your Solr fields, your own modules and all their configurations. 

The ones we ship with every Release will `reset` your Archipelago's settings to Factory defaults if applied `wildly`.

This is where `Github` comes in place.

### Basic steps

Pre requisites:
- Have an Archipelago Deployment Live instance running
- Have Terminal access to your Live Instance
- Have a Github account
- Have a personal Github [Access Token Created](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- Run `git config --global --edit` on your Live Instance and Set your user name/email/etc 
  -  Note: Opens in `Vi`! in case of emergency/panic press `ESC` and type `:x` to escape and/or run away in terror. To edit Press `i` and uncomment the lines. Once Done press `ESC` and type `:x` to save.

### 1.1 Start by creating a Git Fork
Let's fork https://github.com/esmero/archipelago-deployment-live under **your own Account** via the web. 
Happy Note: Since 2021 keeping also forked branches in sync with the origin can be done via the UI directly.

### 1.2 Connect your Live instance terminal. 
Move to your repository's base folder, and let's start by adding your New Forks as a secondary Git `Origin`.
Replace in this command `yourOwnAccount` with (guess what?) ** your own account**

```Shell
git remote add upstream https://github.com/yourOwnAccount/archipelago-deployment-live
````

Now check if you have two remotes (`origin` => This repository, `upstream` => your own fork)

```Shell
git remote -v
````

You will see this:

```Shell
origin	https://github.com/esmero/archipelago-deployment-live (fetch)
origin	https://github.com/esmero/archipelago-deployment-live (push)
upstream	https://github.com/yourOwnAccount/archipelago-deployment-live (fetch)
upstream	https://github.com/yourOwnAccount/archipelago-deployment-live (push)
```

Good!

### 1.3 Now let's create from your current Live Instance a new Branch.
We will push this branch into your Fork and it will be all yours to maintain
Please replace `yourOwnOrg` with any Name you want for this. We like to keep the current Branch name in place after your personal
prefix.

```Shell
git checkout -b yourOwnOrg-1.0.0-RC3
```

Good you now have a new `local` branch named `yourOwnOrg-1.0.0-RC3` and its time to decide what we are going to push into github.

### 1.4 Push the Basics.
By default our deployment strategy (this repository) ignores a few files you want to have in Github. 
Also, there are things like the Installed Drupal Modules and PHP Libraries (the Source Code), the Database, Caches and also your Secrets (`.env` file and your drupal `settings.php`) file
you **FOR SURE** do **not** want to have in Github and are better suited for a private Backup Storage.

Let's start by `push`ing what you have (no commits, your new `yourOwnOrg-1.0.0-RC3` as it is) to your new Fork. From there on we can add new Commits and files.

```Shell
git push upstream yourOwnOrg-1.0.0-RC3
```

And Git will respond with. Use your `yourOwnAccount` personal Github Access Token as password
```Shell
Username for 'https://github.com': yourOwnAccount
Password for 'https://yourOwnAccount@github.com': 
Total 0 (delta 0), reused 0 (delta 0)
remote: 
remote: Create a pull request for 'yourOwnOrg-1.0.0-RC3' on GitHub by visiting:
remote:      https://github.com/yourOwnAccount/archipelago-deployment-live/pull/new/yourOwnOrg-1.0.0-RC3
remote: 
To https://github.com/yourOwnAccount/archipelago-deployment-live
 * [new branch]      yourOwnOrg-1.0.0-RC3 -> yourOwnOrg-1.0.0-RC3
 ```

### 1.5 First Commit
Right now this new Branch (go and checkit out at https://github.com/yourOwnAccount/archipelago-deployment-live/tree/yourOwnOrg-1.0.0-RC3)
will not differ at all from 1.0.0-RC3. That is Ok. For that to happen what we want is to "commit" our changes. How do we do this?

Let's add our `composer.json` and `composer.lock` to our change list. Both of this files are quite personal and as you add
more Drupal Modules, dependencies or Upgrade your Archipelgo and/or Drupal Core and Module's they will change. See the `-f`?
Because our base deployment ignores that file and you want it, we "Force" add it. 
Note: At this stage `composer.lock` won't be added at all because its
still the same as before. So you can only "add" files that have changes.

```Shell
git add drupal/composer.json 
git add -f drupal/composer.lock
```

Now we can see what is new and will be committed by executing

```Shell
git status
```

You may see something like this
```Shell
On branch yourOwnOrg-1.0.0-RC3 
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   drupal/composer.json

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   drupal/scripts/archipelago/deploy.sh
	modified:   drupal/scripts/archipelago/update_deployed.sh

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	deploy/ec2-docker/docker-compose.yml
	drupal/.editorconfig
	drupal/.gitattributes
```

If you do not want to add each `Changes not staged for commit` individually (WE recommend you only commit what you need, we warned) you can also issue an `git add .` which means all.

```Shell
git add drupal/scripts/archipelago/deploy.sh
git add drupal/scripts/archipelago/update_deployed.sh
git add deploy/ec2-docker/docker-compose.yml
```

In this case we are also committing `docker-compose.yml` which you may have customized and the modified to your domain (See Install Guide) `deploy.sh` and `update_deployed.sh` scripts
If you ever need to avoid tracking at all certain files you can edit `.gitignore` file and add more patterns to it (Look at it, its fun)

```Shell
git commit -m "Fresh Install of Archipelago for yourOwnOrg"
```

If you had your email/user account setup correctly (see Pre requisites) you will see:

```Shell
Fresh Install of Archipelago yourOwnOrg
 4 files changed, 360 insertions(+), 46 deletions(-)
 create mode 100644 deploy/ec2-docker/docker-compose.yml
 create mode 100644 drupal/composer.json
```

And now finally you can push this back to your Fork

```Shell
git push upstream yourOwnOrg-1.0.0-RC3
```

And Git will respond with. Use your `yourOwnAccount` personal Github Access Token as password

```Shell

Username for 'https://github.com': yourOwnAccount
Password for 'https://yourOwnAccount@github.com': 
Enumerating objects: 18, done.
Counting objects: 100% (18/18), done.
Compressing objects: 100% (10/10), done.
Writing objects: 100% (10/10), 2.26 KiB | 2.26 MiB/s, done.
Total 10 (delta 5), reused 0 (delta 0)
remote: Resolving deltas: 100% (5/5), completed with 5 local objects.
To https://github.com/yourOwnAccount/archipelago-deployment-live
   d9fa835..3427ce5  yourOwnOrg-1.0.0-RC3 -> yourOwnOrg-1.0.0-RC3
```

And done.

TO BE CONTINUED ...


