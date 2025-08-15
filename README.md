### Generate Local Manifests
* Generate your first local_manifests from a list of repos using Github Action.

### Steps
* Fork this repository.
* Then, go to repository Settings > Secrets and Variables > Action > New repository secret; in name - `PAT` and in secret - paste your `Personal Access Token`.
* Go to Actions tab, and if prompted, enable workflows.
* Go back to the Code screen(default tab)
* Rename the text file here to your device name(oxygen.txt) and edit contents to meet your needs

#### OR

* `git clone https://github.com/sounddrill31/actions_generate_local_manifests`
* Edit your devicename.txt
* `bash adapt.sh devicename.txt`
Now, a local_manifests.xml will appear
### Notes
* You can get your `Personal Access Token` in account Settings > Developer settings > Personal acccess token.
* This does not handle conflicts with ROM manifests, as it just generates a simple template. Fix them manually using remove-project.
* Feed it to an XML checker to ensure things are a-ok, fix it if they are not.
* Put Vendor and other heavy repos last

### Format:
Do this for as many entries as you need

repo init line is needed for removals and testing.
```
repo init -u https://github.com/YourProject/android.git -b ROM_Branch --git-lfs
git clone https://github.com/username/repo_number_1.git path/to/clone -b branch_name
git clone https://github.com/username/repo_number_2.git path/to/clone -b branch_name
git clone https://github.com/username/repo_number_3.git path/to/clone -b branch_name
```

If you want to remove it, add a line like
```
rm -rf "path/to/folder"
```

This is optional because script automatically checks for conflicts!

 ### Example:
```
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
git clone https://github.com/sounddrill31/android_device_xiaomi_oxygen-3 device/xiaomi/oxygen -b lineage-21-qpr3
rm -rf "hardware/qcom-caf/msm8953/audio"
```
