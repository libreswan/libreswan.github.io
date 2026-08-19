_This is optional._

If the machine is to run nightly test runs then it can be set up as a
web server.  See the [nightly test
results](http://testing.libreswan.org) for an example.

## Dependencies

Fedora
```
sudo dnf install -y jq typescript httpd
```
Debian (untested)
```
sudo apt-get install -y jq node-typescript httpd
```

## Setup The Server

```
sudo mkdir /var/www/html/results/
sudo chown $(id -un) /var/www/html/results/
sudo chmod 755 /var/www/html/results/
sudo sh -c 'echo "AddType text/plain .diff" >/etc/httpd/conf.d/diff.conf'
```

to run the web server until the next reboot:

```
sudo firewall-cmd --add-service=http
sudo systemctl start httpd
```

to make the web server permanent:

```
sudo systemctl enable httpd
sudo firewall-cmd --add-service=http --permanent
```

If you want it to be the main page of the website, you can create the
file /var/www/html/index.html containing:

```
cat <<EOF
     <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
     <html>
       <head>
         <meta http-equiv="REFRESH" content="0;url=/results/">
      </head>
       <BODY>
      </BODY>
     </HTML>
EOF
```
