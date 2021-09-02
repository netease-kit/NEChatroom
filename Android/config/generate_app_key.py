import sys, os

appKey = "APP_KEY="
baseUrl = "BASE_URL="

APP_KEY_FILE_PATH = sys.argv[1]
APP_KEY = sys.argv[2]
BASE_URL = sys.argv[3]

properties = appKey + str(APP_KEY) + '\n' + baseUrl + str(BASE_URL) +'\n'

f = open(APP_KEY_FILE_PATH, mode="w", encoding='utf8')
f.write(properties)
f.close()