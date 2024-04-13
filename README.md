### Extract Proprietary Blobs
* Generate your first local_manifests from a list of repos using Github Action.

### Steps
* Fork this repository.
* Then, go to repository Settings > Secrets ans Variables > Action > New repository secret; in name - `PAT` and in secret - paste your `Personal Access Token`.
* Rename PLE.txt and edit contents to meet your needs

### Notes
* You can get your `Personal Access Token` in account Settings > Developer settings > Personal acccess token.
* This does not handle conflicts with ROM manifests, as it just generates a simple template. Fix them manually using remove-project.