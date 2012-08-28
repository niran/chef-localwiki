import os
os.environ["LOCALWIKI_DATA_ROOT"] = "/usr/share/localwiki/"
os.environ["DJANGO_SETTINGS_MODULE"] = "sapling.settings"

import os.path
import sys

from django.contrib.auth.models import User
from django.db.utils import DatabaseError


username = sys.argv[1]

try:
  exists = User.objects.filter(username=username).exists()
except DatabaseError:
  # The User table probably doesn't exist yet.
  exists = False

print "%s %s" % (username, "exists" if exists else "missing")

# Using this script as a not_if attribute of the appropriate command in
# database.rb is the straightforward way to do this. I can't get it to work.
#sys.exit(0 if exists else 1)

flag_file_path = os.environ["LOCALWIKI_DATA_ROOT"] + \
    "conf/superuser_created"
if exists:
  flag_file = open(flag_file_path, "w")
  flag_file.close()
elif os.path.exists(flag_file_path):
  os.unlink(flag_file_path)
