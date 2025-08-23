# NeoMutt

Mutt is a text-based mail client renowned for its powerful features. NeoMutt is a command line mail reader (or MUA). It’s a fork of Mutt with added features.

## Server

### Installation

#### Get a Domain Name (https://landchad.net/basic/domain/)

##### Terms

- Domain name
  The name of a website that you type in an address bar. This site's domain name is LandChad.net.
- Top-level domain (TLD)
  The extension of a domain name, like .com, .net, .xyz, etc.
- Registrar
  A service authorized to reserve a domain name for you.

When domain names first sell, they usually sell for very cheap, but once someone buys one, they have the rights to it until they decide to sell it, often for much, much more money. Therefore, it's a good idea to reserve a domain name ASAP, even if you didn't intend on doing anything big with it.

So let's register your domain name!

##### How

Domains can be registered at any accredited registrar and there are a lot to choose from. Some major names are Host Gator, Blue Host, Name Cheap or Dream Host.

There are also sites that are more private, like Njalla and Cheap Privacy, which register a domain for you under their name, but still allow you access to it. (Normally all websites must be registered with the ICANN with a real name and address, but these sites allow you to bypass that.)

Choosing a registrar is not permanent, and you can transfer domains to a different registrar if you get a better deal later, so in most cases, you can just choose one and let’s head on…

**Basic info about domain names**

- Domain names usually require a very small yearly fee to keep registered, usually around $12 for most generic TLDs. There are some "specialty" TLDs that are more expensive, but .com, .xyz and other basic TLDs are that cheap.
- Once you own a domain, it is yours as long as you pay the yearly fee, but you can also sell it to someone for however much you want.
- Domain names do not hold your data or your website; instead, you add "DNS settings" that direct people connecting to your domain to your IP address. The purpose of a domain name is so that people don't have to remember your IP address to find your website!

**Looking for domain names**

Let's go to our registrar’s site and you can search for domain names.

You can look for whatever domain name you want. Domains that are already bought and owned by someone else might have the option to "Backorder," but it's always best to get one that is unowned, like these:
Searching for a domain name

Note the differences in prices. Some "specialty" TLDs like .game and .io charge a much larger fee, although you might want one. Some domains above, like .xyz and .org have reduced prices for the first year.

Choose the domain you want and buy it. These .xyz domains are a steal now on sale.
Buying a domain name

That's all you have to do to own a domain name! As you register a domain, you can also setup an automatic payment to pay your fee yearly to keep your domain. Easy as pie.

Now we will get a server to host your website on.

#### Get a Server

Once you have a domain name, you'll need a server to host all your website files on. In general, a server is just a computer that is constanly broadcasting some services on the internet.

Servers connected to the internet can be extremely useful with or without proper websites attached to them. You can be your own website, email, file-sharing service and much more.

##### Getting a VPS

A Virtual Personal Server (VPS) is a very cheap and easy way to get a web server. Without you having to buy expensive equipment. There are a lot of online businesses that have massive server farms with great internet connection and big power bills that allow you to rent a VPS in that farm for pocket change.

A VPS usually costs $5 a month. Sometimes slightly more, sometimes slightly less. That's a good price for some internet real-estate, but in truth, you can host a huge number of websites and services on a single VPS, so you get a lot more. I might have a dozen websites, an email server, a chat server and a file-sharing services on one VPS.

The VPS provider that I'll be using for this guide is Vultr, since that is what I use. Vultr provides a free one-month $100 credit to anyone who starts an account through this referral link of mine so you can play around with their services with impunity.

##### Starting your server in two minutes or less

[Start an account on Vultr](https://www.vultr.com/?ref=8384069-6G) and let's get started.

Vultr (and other VPS providers) usually give you a choice in where and what exactly your VPS is.

**Server Location**

In general, it doesn't hugely matter what physical location you have your server in. You might theoretically want it close to where you or your audience might be, but if you host a server in Singapore for an American audience, they won't have to be waiting a perceptibly longer time to load the site.

**Some locations might have different abilities and plans than others. For example, in Vultr, their New York location has optional DDOS protection and also has some cheaper $3.50 servers.**

**Operating System/Server Type**

I especially recommend **Debian 11** for an operating system for your server. Debian is the "classic" server OS and as such, **I make my guides on this site for Debian 11**. If you use another OS, just know that your millage may vary in terms of you might need to change some instructions here minorly.

Server size

You finally have a choice in how beefy a server you want. On Vultr, I recommend getting the cheapest option that is not IPv6 only.

Web hosting and even moderately complicated sites do not use huge amounts of RAM or CPU power. If you start doing more intensive stuff than hosting some webpages and an email server and such, you can always bump up your plan on Vultr without data loss (it's not so easy to bump down).

**Additional features**

On Vultr, there are some final checkboxes you can select additional options. You will want to check Enable IPv6 and also Block Storage Compatible.

We will be setting up IPv6 because it's important for future-proofing your website as more of the web moves to the IPv6 protocol. Block storage is the ability (if you want) to later rent large storage disks to connect to your VPS if desired. You just might want that as an option, so it's worth activating now.
Done!

Once you select those settings, your server will automatically be deployed. Momentarily, you will be able to see your server's IP addresses which will be used for the next brief step:

#### Connect Your Domain and Server with DNS Records

##### The Gist

Now that we have a domain and a server, we can connect the two using DNS records. DNS (domain name system) records are usually put into your registrar and direct people looking up your website to the server where your website and other things will be.

Get your IPv4/IPv6 addresses from your VPS provider and put them into A/AAAA records on your registrar. Simple process, takes a minute, but here's a guide with a million images just so you know.

##### Open up your Registrar

As before, we will be using any registrar of your choice and Vultr as a server host. Go ahead and log into your accounts on both. Open up your registrar, or your registrar, and click on your domain and then a choice for "DNS records." You’ll want to see something like this on your registrar’s site.

Note that we are on the "External Hosts (A, AAAA)" tab by default. There may be default settings set by your registrar. If there are, you can go ahead and delete them so they look clean like the picture above.

**All we have to do now is get our IP addresses from Vultr and add new DNS records that will send connections to our server.**

Keep the registrar tab open and open Vultr and we will copy-and-paste our IP addresses in.

##### Find your server's IP addresses

Looking at your server in the Vultr menu, you should see a number next to it. Mine here is 104.238.126.105 as you can see below the server name (which I have named landchad.net after the domain I will soon attach to it). That is my **IPv4** address.

Copy your IPv4 address and on your registrar’s site, click the "Add Record" record button and add two A entries pasting in your IPv4 address like I've done for mine here.

I add two entries. One has nothing written in the "Host" section. This will direct connections to landchad.net over IPv4 to our IP address. The second has a \* in the "Host" section. This will direct connections to all possible subdomains to the right place too, I mean mail.landchad.net or blog.landchad.net and any other subdomain we might want to add later.

Now let's get our IPv6 address, which is a little more hidden for some reason. IPv6 is important because we are running out of IPv4 addresses, so it is highly important to allow connections via IPv6 as it will be standard in the future. Anyway, now back on Vultr, click on the server name.

On the server settings, **click on settings** and we will see we are on a submenu labeled "IPv4" where we see our IPv4 address again.

Now just click on the **IPv6** submenu to reveal your IPv6 address.

That ugly looking sequence of numbers and letters with colons in between (2001:19f0:5:ccc:5400:03ff:fe58:324a) is my **IPv6** address. Yours will look something like it. Now let's put it into your registrar’s site. This time, be sure to select to put in AAAA records as below:

Now just click "Save Changes." It might take a minute for the DNS settings to propagate across the internet.

##### Test it out!

Now we should have our domain name directing to our new server. We can check by pinging our domain name, check this out:

As you can see, our ping to landchad.net is now being directed to 104.238.128.105. That means we have successfully set up our DNS records! You can also run the command host if you have it, which will list both IPv4 and IPv6 addresses for a domain name.

#### Setting Up an NginX Webserver

At this point, we should have a domain name and a server and the domain name should direct to the IP address of the server with DNS records. As I said in previous articles, the instructions I will give will be for Debian. In this article, other distributions might work a little differently.

##### Logging in to the server

We first want to log into our VPS to get a command prompt where we can set up the web server. I am assuming you are using either MacOS or GNU/Linux and you know how to open a terminal. On Windows, you can also use either PuTTY or the Windows Subsystem for Linux.

Now on Vultr's site, you can click on your VPS and you will see that there is an area that shows you the password for your server at the bottom here.

Now pull up a terminal and type:

```bash
ssh root@example.org
```

This command will attempt to log into your server. It should prompt you for your password, and you can just copy or type in the password from Vultr's site.

If you get an error here, you might not have done your DNS settings right. Double check those. Note you can also replace the example.org with your IP address, but you'll want to fix your DNS settings soon.

##### Installing the Webserver: Nginx

If the program runs without an error, ssh has now logged you into your server. Let's start by running the following commands.

```bash
apt update
apt upgrade
apt install nginx
```

The first command checks for packages that can be updated and the second command installs any updates.

The third command installs nginx (pronounced Engine-X), which is the web server we'll be using, along with some other programs.

**Our nginx configuration file**

nginx is your webserver. You can make a little website or page, put it on your VPS and then tell nginx where it is and how to host it on the internet. It's simple. Let's do it.

nginx configuration files are in /etc/nginx/. The two main subdirectories in there (on Debian and similar OSes) are /etc/nginx/sites-available and /etc/nginx/sites-enabled. The names are descriptive. The idea is that you can make a site configuration file in sites-available and when it's all ready, you make a link/shortcut to it in sites-enabled which will activate it.

First, let's create the settings for our website. You can copy and paste (with required changes) but I will also explain what the lines do.

Create a file in /etc/nginx/sites-available by doing this:

```bash
nano /etc/nginx/sites-available/mywebsite
```

Note that "nano" is a command line text editor. You will now be able to create and edit this file. By saving, this file will now appear. Note also I name the file mywebsite, but you can name it whatever you'd like.

I'm going to add the following content to the file. The content like this will be different depending on what you want to call your site.

```bash
server {
        listen 80 ;
        listen [::]:80 ;
        server_name example.org ;
        root /var/www/mysite ;
        index index.html index.htm index.nginx-debian.html ;
        location / {
                try_files $uri $uri/ =404 ;
        }
}
```

**Explanation of those settings**

The listen lines tell nginx to listen for connections on both IPv4 and IPv6.

The server_name is the website that we are looking for. By putting landchad.net here, that means whenever someone connects to this server and is looking for that address, they will be directed to the content in this block.

root specifies the directory we're going to put our website files in. This can theoretically be wherever, but it is conventional to have them in /var/www/. Name the directory in that whatever you want.

index determine what the "default" file is; normally when you go to a website, say landchad.net, you are actually going to a file at landchad.net/index.html. That's all that is. Note that that this in concert with the line above mean that /var/www/landchad/index.html, a file on our computer that we'll create, will be the main page of our website.

Lastly, the location block is really just telling the server how to look up files, otherwise throw a 404 error. Location settings are very powerful, but this is all we need them for now.

**Create the directory and index for the site**

We'll actually start making a "real" website later, but let's go ahead and create a little page that will appear when someone looks up the domain.

```base
mkdir /var/www/mysite
```

Now let's create an index file inside of that directory, which will appear when the website is accessed:

```bash
nano /var/www/mysite/index.html
```

I'll add the following basic content, but you can add whatever you want. This will appear on your website.

```bash
<!DOCTYPE html>
<h1>My website!</h1>
<p>This is my website. Thanks for stopping by!</p>
<p>Now my website is live!</p>
```

**Enable the site**

Once you save that file, we can enable it making a link to it in the sites-enabled directory:

```bash
ln -s /etc/nginx/sites-available/mywebsite /etc/nginx/sites-enabled
```

Now we can just reload or restart to make nginx service the new configuration:

```bash
systemctl reload nginx
```

##### The Firewall

Vultr and some other VPSes automatically install and enable ufw, a firewall program. This will block basically everything by default, so we have to change that. If you don't have ufw installed, you can skip this section.

We must open up at least ports 80 and 443 as below:

```bash
ufw allow 80
ufw allow 443
```

Port 80 is the canonical webserver port, while 443 is the port used for encrypted connections. We will certainly need that for the next page.

> As you add more services to your website, they might need you to open more ports, but that will be mentioned on individual articles. (It should be noted that some local services run only for other services on your machine, so you don’t need to open ports for every process running locally, only those that directly interact with the internet, although it’s common to run those through Nginx for simplicity and security.)

##### Nginx security hint

By default, Nginx and most other webservers automatically show their version number on error pages. It's a good idea to disable this from happening because if an exploit comes out for your server software, someone could exploit it. Open the main Nginx config file /etc/nginx/nginx.conf and find the line # server_tokens off;. Uncomment it, and reload Nginx.

Remember to _keep your server software up to date_ to get the latest security fixes!

##### We now have a running website!

At this point you can now type in your website in your browser and this webpage will appear!
The webpage as it appears.

Note the "Not secure" notification. The next brief step is securing encrypted connections to your website.

#### Certbot and HTTPS

Once you have a website, it is extremely important to enable encrypted connections over HTTPS/SSL. You might have no idea what that means, but it's easy to do now that we've set our web server up.

Certbot is a program that automatically creates and deploys the certificates that allow encrypted connections. It used to be painful (and often expensive) to do this, but now it's all free and automatic.

##### Why is encryption important?

- With HTTPS, users' ISPs cannot snoop on what they are looking at on your website. They know that they have connected, but the particular pages they visit are private as everything is encrypted. HTTPS increases user privacy.
- If you later create usernames and passwords for any service on your site, lack of encryption can compromise that private data! Most well-designed software will automatically prevent any unencrypted connections over the internet.
- Search engines like Google favor pages with HTTPS over unencrypted HTTP.
- You get the official-looking green 🔒 symbol in the URL bar in most browsers which makes normies subtly trust your site more.

##### Let's do it!

Note in this picture that a browser accessing your site will say "Not secure" or something else to notify you that we are using an unencrypted HTTP connection rather than an encrypted HTTPS one.

##### Installation

Just run:

```bash
apt install python3-certbot-nginx
```

And this will install certbot and its module for nginx.

##### Run

As I mentioned in the previous article, firewalls might interfere with certbot, so you will want to either disable your firewall or at least ensure that it allows connections on ports 80 and 443:

```bash
ufw allow 80
ufw allow 443

```

Now let's run certbot:

```bash
certbot --nginx
```

The command will ask you for your email. This is so when the certificates need to be renewed in three months, you will get an email about it. You can set the certificates to renew automatically, but it's a good idea to check it the first time to ensure it renewed properly. You can avoid giving your email by running the command with the --register-unsafely-without-email option as well.

Agree to the terms, and optionally consent to give your email to the EFF (I recommend against this obviously).

Once all that is done, it will ask you what domains you want a certificate for. You can just press enter to select all.
activate HTTPS for a site with certbot

It will take a moment to create the certificate, but afterwards, you will be asked if you want to automatically redirect all connections to be encrypted. Since this is preferable, choose 2 to Redirect.
redirecting http to encrypted https with certbot

##### Checking for success

You should now be able to go to your website and see that there is a 🔒 lock icon or some other notification that you are now on an encrypted connection.
A 🔒 symbol symbolizing our new HTTPS layer for our website!

##### Setting up certificate renewal

As I mentioned in passing, the Certbot certificates last for 3 months. To renew certificates, you just have to run certbot --nginx renew and it will renew any certificates close to expiry.

Of course, you don't want to have to remember to log in to renew them every three months, so it's easy to tell the server to automatically run this command. We will use a _cronjob_ for this. Run the following command:

```bash
crontab -e
```

There might be a little menu that pops up asking what text editor you prefer when you run this command. If you don't know how to use vim, choose nano, the first option.

This crontab command will open up a file for editing. A crontab is a list of commands that your operating system will run automatically at certain times. We are going to tell it to automatically try to renew our certificates every month so we never have to.

Create a new line at the end of the file and add this content:

```bash
0 0 1 * * certbot --nginx renew
```

Save the file and exit to activate this cronjob.

For more on cron and crontabs please _click here!_

You now have a live website on the internet. You can add to it what you wish.

As you add content to your site, there are many other things you can also install linked on _the main page_, and many more improvements, tweaks and bonuses.

### Add Users

```bash
$ sudo useradd -G mail -m <username>
$ sudo passwd <username>
```

### Delete Users

```bash
$ sudo userdel -r <username>
```

## Client (mutt-wizard)

Muttwizard is a tool that automatically sets up a neomutt-based minimal email system.

### Add Users

```bash
$ mw -a <user>@<domain>
```

### Delete Users

```bash
$ mw -d <user>@<domain>
```

## Warning

There is a warning is as follow:

> Warning: SSLType is deprecated. Use TLSType instead.

To resolve this warning, simply replace `SSLType` with `TLSType` in your `~/.config/mbsync/config` file.

```bash
SSLType IMAPS
```

with:

```bash
TLSType IMAPS
```
