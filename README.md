### Extract Proprietary Blobs
* Generate your first local_manifests from a list of repos using Github Action.

### Steps
* Fork this repository.
* Then, go to repository Settings > Secrets ans Variables > Action > New repository secret; in name - `PAT` and in secret - paste your `Personal Access Token`.
* Rename the text file here and edit contents to meet your needs

### Notes
* You can get your `Personal Access Token` in account Settings > Developer settings > Personal acccess token.
* This does not handle conflicts with ROM manifests, as it just generates a simple template. Fix them manually using remove-project.
* Feed it to an XML checker to ensure things are a-ok, fix it if they are not.
* Put Vendor and other heavy repos last

### Format:
Do this for as many entries as possible
```
{ "https://github.com/ROM/manifest" "branch_name" }
add "https://github.com/username/repo_number_1.git" "path/to/clone" "branch_name"
```

If you want to remove it, add a line like
```
remove "path/to/folder"

 ### Example:
```
{ "https://github.com/LineageOS/android" "lineage-21.0" }
add "https://github.com/sounddrill31/android_device_xiaomi_oxygen-3" "device/xiaomi/oxygen" "lineage-21-qpr3"
remove "hardware/qcom-caf/msm8953/audio"
```