# ================================ Helper FXNS ===============================
download_dataset() {

    if [ -f "tars/$2" ]; then
        echo "tars/$2 exists."
    else 
        echo "tars/$2 does not exist."
        echo "Downloading..."
        
        # Torrent dataset
        command="ctorrent downloads/$1.torrent"
        log="downloads/$1_prog.log"
        match="Download complete."

        $command > "$log" 2>&1 &
        pid=$!

        while (true)
        do
            if fgrep "$match" "$log"
            then
                kill $pid
                break
            fi
        done

        mv $2 tars
        rm $log
    fi
    
}

untar_files() {
    # Untar files
    if [ -d "data/$1" ]; then
        echo "tar already extracted to data/$1"
    else
        echo "untaring too data/$1..."
        mkdir -p data/$1 && tar -xvf tars/$2 -C data/$1
    fi

}
# ============================== // Helper FXNS =============================

# ================================== MAIN ==================================
# Check for ctorrent
if apt list --installed | grep ctorrent; then
    echo "ctorrent already on system."
else
    echo "Downloading ctorrent..."
    sudo apt-get install ctorrent
fi

# Make dirs
mkdir -p downloads
mkdir -p tars
mkdir -p data

# Validation
VAL_TORRENT_URL="http://academictorrents.com/download/5d6d0df7ed81efd49ca99ea4737e0ae5e3a5f2e5.torrent"
VAL_TAR_FILENAME="ILSVRC2012_img_val.tar"
wget -O downloads/val.torrent $VAL_TORRENT_URL
download_dataset 'val' $VAL_TAR_FILENAME

# Untar files
untar_files 'val' $VAL_TAR_FILENAME

# Reorganize validation files
#if [find data/val -maxdepth 1 -name "*.JPEG"]; then
echo "Running validation set reorganization..."
cd data/val && wget -O- https://raw.githubusercontent.com/soumith/imagenetloader.torch/master/valprep.sh | bash
cd ../..
#fi


# Training
TRAIN_TORRENT_URL="http://academictorrents.com/download/a306397ccf9c2ead27155983c254227c0fd938e2.torrent"
TRAIN_TAR_FILENAME="ILSVRC2012_img_train.tar"
wget -O downloads/train.torrent $TRAIN_TORRENT_URL
download_dataset 'train' $TRAIN_TAR_FILENAME


# Untar files
untar_files 'train' $TRAIN_TAR_FILENAME

cd data/train && find . -name "*.tar" | while read NAME ; do mkdir -p "${NAME%.tar}"; tar -xvf "${NAME}" -C "${NAME%.tar}"; rm -f "${NAME}"; done
cd ../..
