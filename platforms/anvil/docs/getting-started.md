## 1. Understand the login format
You do **NOT** log in with your normal ACCESS username/password. Anvil requires:
- your Anvil username (usually starts with x-)
- an SSH key
- the host: anvil.rcac.purdue.edu

on terminal or command line: `ssh x-yourusername@anvil.rcac.purdue.edu`

For example: ssh x-pnara@anvil.rcac.purdue.edu

## 2. Create a key and copy your public key

Refer to [Pre-reqs](docs/prereqs.md) on how to create a SSH key

## 3. First-time login through OnDemand

Before SSH works directly, Purdue wants you to use the web portal once. Go to [Anvil Open OnDemand](https://ondemand.anvil.rcac.purdue.edu/)
Log in with:
- ACCESS username
- ACCESS password
- Duo MFA

## 4. Add your SSH public key to Anvil
Inside the OnDemand shell terminal:
- Create the SSH directory: `mkdir -p ~/.ssh`
Edit the authorized keys file: `nano ~/.ssh/authorized_keys`
Paste the entire public key line into the file.
Save and exit.

## 5. SSH directly from your terminal
Now from your local machine: `ssh x-yourusername@anvil.rcac.purdue.edu`
If successful, you’ll see the Anvil welcome banner.