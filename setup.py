#!/usr/bin/env python

from distutils.core import setup

setup(name='PSZToolkit',
      version='0.1.0',
      description='Planck SZ Database Toolkit',
      author='Benjamin Bertincourt',
      author_email='bbertincourt@gmail.com',
      description='Set of utilities designed to help cosmologists handle \
      			the Planck SZ database and estimate candidate sources \
      			SZ properties.',
      url='https://github.com/bbertinc/PSZToolkit',
      packages=['psztoolkit', 'psztoolkit.test','psztoolkit.plot'],
      license='GNU GPL V3',
     )