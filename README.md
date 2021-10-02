This is a spin on the gfid-to-dirname.sh tool by Ravishankar N (https://github.com/itisravi). 

Requires the trusted.gfid2path xattr exists, so should only work on 3.12+ Glusterfs if quota's
aren't turned on for the volume as I understand it. If there is any doubt run you can check with:

```
# getfattr -d -m . -e text /brick/path/.glusterfs/xx/xx/gfid
```
