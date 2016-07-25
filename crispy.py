#!/usr/bin/env python
# coding: utf-8

"Application launcher."

def main():
    import os
    import sys
    import crispy

    sys.path.insert(0, os.path.join(os.path.dirname(crispy.__file__), 'gui'))
    crispy.gui.canvas.main()

if __name__ == '__main__':
    main()
