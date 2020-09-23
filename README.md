# EE AUTh Assignments for Multimedia Systems and Virtual Reality 2019-2020

Assignments for the Multimedia Systems and Virtual Reality course. 'MAT Files' folder contains the .mat files needed by the scripts in order to demonstrate the results of their functions.

## Description

The above code practically implements the compression and decompression of an image, following the JPEG standard (in a bit more simplified form).
The procedure followed for the successful compression is:

Raw Image Values in RGB -> Conert to YCbCr -> Split to blocks -> Apply DCT -> Quantize the DCT blocks -> Apply Run Length Encoding -> Apply Huffman encoding -> Convert the resulted encoded image to a bitsream according to the JPEG Standard -> Write the bitstream to a '.jpg' file

For decompression, the exact inverse method is followed. 

For more info on the JPEG Standard (ITU-T81), take a look here: https://www.w3.org/Graphics/JPEG/itu-t81.pdf
