SHR_DIR=/usr/share
dirs="gtk-doc locale doc"

for dir in $dirs ; do
    echo "Converting $SHR_DIR/$dir into a tarball mountpoint..."
    sudo tar czf $SHR_DIR/$dir.tgz -C $SHR_DIR/$dir .
    sudo rm -R $SHR_DIR/$dir/{.*,*} 2> /dev/null
    sudo archivemount $SHR_DIR/$dir.tgz $SHR_DIR/$dir -o default_permissions,allow_other
done

SIZE_DIR=`du -bs $SHR_DIR/$dir 2>/dev/null | cut -f1`
SIZE_TGZ=`du -bs $SHR_DIR/$dir.tgz 2>/dev/null | cut -f1`

echo "$SHR_DIR/$dir has been converted into a tarball. This saved $(((SIZE_DIR-SIZE_TGZ)/1024/1024))M."

## Need auto-mount on system boot for:
# /usr/share/doc
# /usr/share/gtk-doc
# /usr/share/locale