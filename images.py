import os
import cv2 
rootdir = './images/'

for subdir, dirs, files in os.walk(rootdir):
    for file in files:
        filename = os.path.join(subdir, file)
        ext = filename.split(".")[-1]
        if ext == "png":
            im = cv2.imread(filename)
            x, y, ch = im.shape
            if x <= 8 or y <= 8:
                print(filename, im.shape)