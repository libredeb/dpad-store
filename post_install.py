#!/usr/bin/env python3

import os
import subprocess

prefix = os.environ.get('MESON_INSTALL_PREFIX', '/usr')
hicolor = os.path.join(prefix, 'share', 'icons', 'hicolor')
applications = os.path.join(prefix, 'share', 'applications')

if os.environ.get('DESTDIR'):
    print('DESTDIR is set, skipping post-install steps.')
else:
    steps = [
        ('Updating icon cache...', ['gtk-update-icon-cache', '-q', '-t', '-f', hicolor]),
        ('Updating desktop database...', ['update-desktop-database', '-q', applications]),
    ]
    for message, cmd in steps:
        print(message)
        if subprocess.call(cmd) == 0:
            print('  Done.')
        else:
            print('  Failed: ' + ' '.join(cmd))
