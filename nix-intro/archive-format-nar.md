https://nixos.org/nix/manual/#operation-dump

Create directory t1 with a file called yo.txt inside of it
```
> cd /tmp/
> mkdir t1
> cd t1/
> echo "hi" > yo.txt
> ls -l t1/
total 4
-rw-rw-r-- 1 kanishka kanishka 3 Nov  9 21:03 yo.txt
```

Create archive (similar to tar, but more deterministic) from folder t1
```
> cd /tmp
> nix-store --dump t1/ > yo.nar
```

Extract archive from .nar file to directory output2
```
> cat yo.nar | nix-store --restore output2
> cat output2/yo.txt 
> ls -l output2/
total 4
-rw-r--r-- 1 kanishka kanishka 3 Nov  9 21:05 yo.txt
```

The timestamp is has changed?
