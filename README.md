This is a spin on the gfid-to-dirname.sh tool by Ravishankar N (https://github.com/itisravi). 

Should only work on 3.12+ Glusterfs if quota's aren't turned on for the volume. Requires that
the trusted.gfid2path xattr exists.
