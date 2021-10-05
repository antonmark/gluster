This is a spin on the gfid-to-dirname.sh tool by Ravishankar N (https://github.com/itisravi). 

Requires the trusted.gfid2path xattr exists. It should without any special options enabled in
Glusterfs 3.12+, or with quota's on prior to that version.

```
# getfattr -d -m . -e text /brick/path/.glusterfs/xx/xx/gfid
```
