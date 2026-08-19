# IKEv1 is obsolete, please migrate to IKEv2

Libreswan's IKE daemon **pluto** can use pam for XAUTH authentication
(xauthby=pam). One Time Passwords (OTP) can be supported via pam
directives. The following example is for using Google Authenticator. It
requires that username's are actual unix system users on the VPN
gateway, as their google authenticator files are stored in their home
directory. Change the /etc/pam.d/pluto file to include the Google
Authenticator directives:

    #%PAM-1.0

    # /etc/pam.d/pluto with google authenticator

    auth required pam_google_authenticator.so forward_pass

    auth include system-auth use_first_pass
    account required pam_nologin.so
    account include system-auth
    password include system-auth
    session optional pam_keyinit.so force revoke
    session include system-auth
    session required pam_loginuid.so

As root, create the user and generate their QRCODE / link:

    [root@vpn #] useradd paul
    [root@vpn #] su - paul
    [paul2@vpn ~]$ google-authenticator
    Do you want authentication tokens to be time-based (y/n) y
    https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/paul@vpn.nohats.ca%3Fsecret%3DEPS4O5H4YO665V2L

    ![QR Code](/imagesQrcode.png)

    Your new secret key is: EPS4O5H4YO665V2L
    Your verification code is 265293
    Your emergency scratch codes are:
      23358457
      86045401
      59342655
      93987954
      72038389
    Do you want me to update your "/home/paul/.google_authenticator" file (y/n) y

    Do you want to disallow multiple uses of the same authentication
    token? This restricts you to one login about every 30s, but it increases
    your chances to notice or even prevent man-in-the-middle attacks (y/n) y

    By default, tokens are good for 30 seconds and in order to compensate for
    possible time-skew between the client and the server, we allow an extra
    token before and after the current time. If you experience problems with poor
    time synchronization, you can increase the window from its default
    size of 1:30min to about 4min. Do you want to do so (y/n) y

    If the computer that you are logging into isn't hardened against brute-force
    login attempts, you can enable rate-limiting for the authentication module.
    By default, this limits attackers to no more than 3 login attempts every 30s.
    Do you want to enable rate-limiting (y/n) y

The qrcode or the URL can be given to the user, for instance for their
iphone google authenticator application

![GAiphone](/imagesGAiphone.png)

### Using the OTP code

XAUTH only supports a username and password. To specify the OTP, you
concatenate it after the password. There is no separator character.

{{ ambox \| nocat=true \| type=important \| text = If you wish to
support IPsec on phones, you cannot practically use Google Authenticator
on that same phone. Apart from not really offering security, it's next
to impossible to switch between the applications to get the OTP code
into the password field of the VPN application. }}