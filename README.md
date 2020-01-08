Using assembly language, I tried to detect a character, Waldo, in a pixel art image by looping through all the parts of pictures which have the same size as the template---Waldo's face.

This at first was achieved at a really slow speed, then I unrolled the inner most loop to speed up the code and I reduced needed memory accesses and conflict misses.

I also measured the cache performance (using instruction counters and data cache stimulator) and tested with three mapping way of caches.
