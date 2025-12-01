import os
import os.path
import re
from string import Template
from getpass import getpass
from subprocess import check_output


# If you don't feel like taking our word for this being legitimate,
# check against https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem
ca_file = "/etc/cert/digicert-g2.pem"
ca_cert = """\
-----BEGIN CERTIFICATE-----
MIIDjjCCAnagAwIBAgIQAzrx5qcRqaC7KGSxHQn65TANBgkqhkiG9w0BAQsFADBh
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSAwHgYDVQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBH
MjAeFw0xMzA4MDExMjAwMDBaFw0zODAxMTUxMjAwMDBaMGExCzAJBgNVBAYTAlVT
MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
b20xIDAeBgNVBAMTF0RpZ2lDZXJ0IEdsb2JhbCBSb290IEcyMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuzfNNNx7a8myaJCtSnX/RrohCgiN9RlUyfuI
2/Ou8jqJkTx65qsGGmvPrC3oXgkkRLpimn7Wo6h+4FR1IAWsULecYxpsMNzaHxmx
1x7e/dfgy5SDN67sH0NO3Xss0r0upS/kqbitOtSZpLYl6ZtrAGCSYP9PIUkY92eQ
q2EGnI/yuum06ZIya7XzV+hdG82MHauVBJVJ8zUtluNJbd134/tJS7SsVQepj5Wz
tCO7TG1F8PapspUwtP1MVYwnSlcUfIKdzXOS0xZKBgyMUNGPHgm+F6HmIcr9g+UQ
vIOlCsRnKPZzFBQ9RnbDhxSJITRNrw9FDKZJobq7nMWxM4MphQIDAQABo0IwQDAP
BgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNVHQ4EFgQUTiJUIBiV
5uNu5g/6+rkS7QYXjzkwDQYJKoZIhvcNAQELBQADggEBAGBnKJRvDkhj6zHd6mcY
1Yl9PMWLSn/pvtsrF9+wX3N3KjITOYFnQoQj8kVnNeyIv/iPsGEMNKSuIEyExtv4
NeF22d+mQrvHRAiGfzZ0JFrabA0UWTW98kndth/Jsw1HKj2ZL7tcu7XUIOGZX1NG
Fdtom/DzMNU+MeKNhJ7jitralj41E6Vf8PlwUHBHQRFXGU7Aj64GxJUTFy8bJZ91
8rGOmaFvE7FBcf6IKshPECBV1/MUReXgRPTqh5Uykw7+U0b6LJ3/iyK5S9kJRaTe
pLiaWN0bfVKfjllDiIGknibVb63dDcY3fe0Dkhvld1927jyNxF1WW6LZZm6zNTfl
MrY=
-----END CERTIFICATE-----
"""

wpa_supplicant_file = "/etc/wpa_supplicant/eduroam.conf"
wpa_supplicant_conf = """\
update_config=1
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev

network={
    ssid="eduroam"
    scan_ssid=1
    key_mgmt=WPA-EAP
    eap=PEAP
    ca_cert="${cert_file}"
    phase1="peaplabel=0"
    phase2="auth=MSCHAPV2"
    anonymous_identity="@ic.ac.uk"
    identity="${user}@ic.ac.uk"
    password=hash:${password_hash}
}
"""

interface_file = "/etc/network/interfaces.d/wlan0"
interface_conf = """\
allow-hotplug wlan0
auto wlan0
iface wlan0 inet dhcp
  wpa-conf /etc/wpa_supplicant/eduroam.conf
"""


def write_file(file, text):
    os.makedirs(os.path.dirname(file), exist_ok=True)
    write=True
    if os.path.exists(file):
        yn = input(f"{file} already exists. Overwrite? [Y/n]")
        if yn != "" and yn.lower() != "y":
            write = False
    if write:
        open(file, "w").write(text)


print("""\
==== IMPORTANT SECURITY NOTICE ====

Your Imperial College password will not be stored in plaintext on the PYNQ
board, but because eduroam uses a bad (old) authentication standard, it will
only be hashed using a weak unsalted MD4 hash. The brute force cracking speed
is about 125 GH/s on a RTX 3090 [1] (very fast).

If you don't want it to be possible for anyone who has access to this board
(e.g. your lab partners) to steal your password, you should make sure your
password is AT MINIMUM as strong as 10 random ASCII characters, or 5 random
words [2]. (It would then take around 2 years to crack on a RTX 3090).

With access to this hash, anyone can access eduroam pretending to be you, but
cracking the hash is required to access other things that use the same password.

[1]: https://link.springer.com/chapter/10.1007/978-3-032-00236-5_30
[2]: https://xkcd.com/936/

==== END SECURITY NOTICE ====
""")

user = input("Enter your Imperial user ID (e.g. abc12): ")
password = getpass("Enter your Imperial password: ")
password_hash = check_output(
    r"tr -d '\n' | iconv -t utf16le | openssl dgst -md4 -provider legacy",
    input=password,
    shell=True, text=True,
).strip().split(" ")[-1]
if not re.match(r"^[0-9a-f]{32}$", password_hash):
    print("Something went wrong hashing password")
    exit(1)

write_file(ca_file, ca_cert)
write_file(wpa_supplicant_file, Template(wpa_supplicant_conf).substitute(
    cert_file=ca_file,
    user=user,
    password_hash=password_hash,
))
write_file(interface_file, interface_conf)
print("All done. Unplug and replug USB WiFi dongle to connect to network.")
