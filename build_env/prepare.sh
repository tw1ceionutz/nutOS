echo "Dist Root: ${DIST_ROOT:?}"
echo "LFS: ${LFS:?}"

mkdir -p $LFS/sources

for f in $(cat $DIST_ROOT/build_env/build_env_list)
do
    bn=$(basename $f)
    
    if ! test -f $LFS/sources/$bn ; then
        wget $f -O $LFS/sources/$bn
    fi

done;

mkdir -pv $LFS/{bin,etc,lib,sbin,usr,var,lib64,tools}

if ! test $(id -u chiff) ; then

groupadd chiff
useradd -s /bin/bash -g chiff -m -k /dev/null chiff
passwd chiff
chown -v chiff $LFS/{usr,lib,var,etc,bin,sbin,tools,lib64,sources}

echo "chiff ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers_chiff

chhome=$(eval echo "~chiff")

cat > $chhome/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > $chhome/.bashrc << EOF
set +h
umask 022
LFS=$LFS
export DIST_ROOT=$DIST_ROOT
EOF

cat >> $chhome/.bashrc << "EOF"
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS="-j$(nproc)"
EOF

fi
