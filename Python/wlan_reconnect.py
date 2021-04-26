import os, platform, subprocess, logging, logging.handlers, time

''' ----------
CONFIG
my_wifi:
	SSID of ur Network u want to connect with

minutes_to_watch:
	How long to check 
	if the network is still available after successful connection
---------- '''
my_wifi = "WLAN-124271"
minutes_to_watch = 3

# Initial setup
try:
    os.mkdir("/Users/Checker8763/Documents/logs")
except Exception:
    pass

f = open(os.path.join("/","Users","Checker8763", "Documents","logs", "wifi.log"), "w")
f.close()


formatter = logging.Formatter(logging.BASIC_FORMAT)

handler = logging.handlers.WatchedFileHandler("/Users/Checker8763/Documents/logs/wifi.log")
handler.setFormatter(formatter)

root = logging.getLogger()
root.setLevel("INFO")
root.addHandler(handler)

logging.info(f"{time.asctime()}")

if platform.system().lower() != "windows":
    logging.exception("Other Os than Windows are not supported")
    exit(1)

command = ['netsh', 'interface', 'show', 'interface']
result = subprocess.run(command, capture_output=True, shell=True).stdout.decode('utf-8') #https://stackoverflow.com/questions/4760215/running-shell-command-and-capturing-the-output
logging.info("Inerfaces:")
logging.info(result)

if result.find("WLAN") == -1:
    logging.error("No Wifi interface found")
    exit(2)

command = ['netsh', 'wlan', 'show', 'networks']
result = subprocess.run(command, capture_output=True, shell=True).stdout.decode('utf-8', 'ignore') #https://stackoverflow.com/questions/4760215/running-shell-command-and-capturing-the-output
logging.info("Networks:")
logging.info(result)

if result.find(my_wifi) == -1:
    logging.error(f"specified network ({my_wifi}) not found")
    exit(3)

def ping(host):
    # Credit to https://stackoverflow.com/questions/2953462/pinging-servers-in-python

    """
    Returns True if host (str) responds to a ping request.
    Remember that a host may not respond to a ping (ICMP) request even if the host name is valid.
    """

    # Option for the number of packets as a function of
    param = '-n' if platform.system().lower()=='windows' else '-c'

    # Building the command. Ex: "ping -c 1 google.com"
    command = ['ping', param, '1', host]

    return subprocess.call(command) == 0

def check_wifi_connection():
    ping_check = ping("google.de")
    # logging.info(f"Initial Pingcheck returned: {ping_check}")
    if  ping_check != True:
        logging.warning("detected no internet connection!")
        try_count = 0
        success = False
        while not success:
            try_count = try_count +1

            logging.info("disconnecting from wifi")
            os.system("netsh wlan disconnect")

            logging.info("reconnecting to wifi")
            os.system(f"netsh wlan connect {my_wifi}")

            seconds = 20 * try_count
            logging.info(f"Waiting for {seconds} seconds")
            time.sleep(seconds)

            ping_check = ping("google.de")
            # logging.info(f"Pingcheck returned: {ping_check}")

            if ping_check == True:
                logging.info(f"Ping successful after {try_count} tries")
                success = True
    else:
        logging.info("wifi is working")

for i in range(minutes_to_watch + 1): #Plus one so it looks the first (0) time and then the wanted amount afterwards
    logging.info(f"Watching if internet is stable: {i} minute")
    check_wifi_connection()
    if i != minutes_to_watch:
         time.sleep(60)