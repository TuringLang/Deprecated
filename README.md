# Deprecated Utility Packages for Turing.jl

This repository contains *deprecated* utility packages for Turing.jl.  
These packages have either:
- Been upstreamed into Turing.jl,
- Been superseded by new features in Turing.jl itself,
- Or replaced by other packages in the Julia ecosystem.

## Planned Deprecations

| Package | Status | Documentation | Prerequisite |
|:--------|:-------|:---------------|:------|
| `AdvancedPS.jl` | ⬜ Planned | *(pending)* | Need to upstream AdvancedPS to Turing.jl |
| `TuringBenchmarking.jl` | ✅ Merged | [Documentation](https://turinglang.org/Deprecated/TuringBenchmarking/) | NIL |
| `TuringCallbacks.jl` | ⬜ Planned | *(pending)* | Need to upstream callbacks to AbstractMCMC as an extension |
| `ParetoSmooth.jl` | ⬜ Planned | *(pending)* | https://github.com/TuringLang/Turing.jl/issues/2534 |
| `DistributionsAD.jl` | ⬜ Planned | *(pending)* |  https://github.com/TuringLang/DistributionsAD.jl/issues/282 |


## Guide: Adding Packages While Preserving Commit History

The following steps describe how to migrate a standalone package into this repository while preserving its full Git history, using `git subtree`.

### Step 1: Clone this repository

```bash
git clone https://github.com/TuringLang/deprecated.git
cd deprecated
```

### Step 2: Create a new branch

You can always create a feature branch for each imported package.

```bash
git checkout -b migrate-<package-name>
```
Example:
```bash
git checkout -b migrate-advancedps
```

### Step 3: Add the source repository as a remote

```bash
git remote add <remote-name> <url-to-original-repo>
git fetch <remote-name>
```
Example:
```bash
git remote add advancedps https://github.com/TuringLang/AdvancedPS.jl.git
git fetch advancedps
```

### Step 4: Add the package using `git subtree`

Import the package under a subfolder while preserving history.

```bash
git subtree add --prefix=<target-folder-name> <remote-name>/<branch-name>
```
Example:
```bash
git subtree add --prefix=AdvancedPS advancedps/main
```

This will automatically create a new commit, preserving the full commit history within the subfolder.

### Step 5: Check if all registered versions exist
Before opening a Pull Request, verify that all registered versions of the package are present locally.
In Julia REPL, run:
```julia
using RegistryInstances, UUIDs, Git

const GENERAL_UUID = UUID("23338594-aafe-5451-b93e-139f81909106")

pretty_print_row(row) = println(row.pkg_name, ": v", row.version, " ", row.found ? "found" : "is missing")
pretty_print_table(table) = foreach(pretty_print_row, table)

function check_all_found(table)
    idx = findfirst(row -> !row.found, table)
    idx === nothing && return nothing
    row = table[idx]
    error(string("Repository missing v", row.version, " of package $(row.pkg_name)"))
end

function check_packages_versions(pkg_names, repo_url; registry_uuid=GENERAL_UUID, verbose=true, throw=true)
    if isdir(repo_url)
        dir = repo_url
    else
        dir = mktempdir()
        run(`$(git()) clone $(repo_url) $dir`)
    end

    registry = only(filter!(r -> r.uuid == registry_uuid, reachable_registries()))

    table = @NamedTuple{pkg_name::String, version::VersionNumber, found::Bool, tree_sha::Base.SHA1}[]

    for pkg_name in pkg_names
        pkg = registry.pkgs[only(uuids_from_name(registry, pkg_name))]
        versions = registry_info(pkg).version_info
        for version in sort(collect(keys(versions)))
            tree_sha = versions[version].git_tree_sha1
            found = success(`$(git()) -C $dir rev-parse -q --verify "$(tree_sha)^{tree}"`)

            push!(table, (; pkg_name, version, found, tree_sha))
        end
    end
    verbose && pretty_print_table(table)
    throw && check_all_found(table)
    return table
end

check_package_versions(pkg_name, repo_url; kw...) = check_packages_versions([pkg_name], repo_url; kw...)
```
Reference: [JuliaRegistries/General Contributing Guide](https://github.com/JuliaRegistries/General/blob/ce7010d91d2805182c4ed9539658ead03956e510/CONTRIBUTING.md#appendix-checking-if-a-repository-contains-all-registered-versions-of-a-package)

Then check if all registered versions exist:
```julia
julia> check_package_versions("AdvancedPS", ".")
```

### Step 6: Push your feature branch

```bash
git push origin migrate-<package-name>
```

Example:
```bash
git push origin migrate-advancedps
```

### Step 7: Open a Pull Request

- Open a Pull Request from your feature branch (e.g., `migrate-advancedps`) into the `main` branch.
- Get it reviewed and merged.

### Step 8: Add all versioned docs
Once the PR is merged, add all versioned docs from the gh-pages branch of the original repository to the gh-pages branch of this repository in the package folder. 

```bash
git fetch origin
git checkout gh-pages
git pull origin gh-pages
```

Make sure that your Git is configured to allow symlinks:
```bash
git config core.symlinks true
```
(This should be set before cloning, but good to double-check.)
Otherwise, symlinks will be cloned as plain text files.

#### Create a temporary folder
```bash
mkdir temp-gh-pages
cd temp-gh-pages

# Clone only the gh-pages branch of the original repo
git clone --branch gh-pages --single-branch --depth 1 <original-repo-url> .
```

Make sure to add these files and folders to the correct location:
- All v* folders should be added to the root of the package folder.
- versions.js should be replaced with versions.js from the original repository.
- All symlinks should be added to the root of the package folder. Ensure that your Git has symlinks enabled.

Finally, delete the temporary folder, add, commit the changes and push to the gh-pages branch of the deprecated repository:
```bash
git add -A
git commit -m "Add versioned docs for AdvancedPS"
git push origin gh-pages
```

## Notes

- `git subtree add` automatically creates a commit.  
- Tags from the original repository are **not automatically transferred**.  
  If needed, important tags should be manually recreated after migration.
- Please avoid pushing directly to `main`. Always work via a feature branch and a Pull Request.

## Redirect links of deprecated package to correct location

Follow these steps to add HTML redirects for deprecated documentation such as `TuringBenchmarking.jl` to the `turinglang.github.io` repo's `gh-pages` branch.

#### 1. Checkout `gh-pages` branch of `turinglang.github.io`

```bash
git checkout gh-pages
git pull origin gh-pages
```

#### 2. Save and run the redirect script

Save the following script as `redirects.sh` and update the `Config` in it:

```bash
#!/bin/bash

# === Config ===
SRC_REPO="https://github.com/TuringLang/TuringBenchmarking.jl.git"
SRC_BRANCH="gh-pages"
SRC_TMP_DIR="tmp_TuringBenchmarking"
DEST_PREFIX="/Deprecated/TuringBenchmarking"
DEST_BASE_DIR="TuringBenchmarking.jl"

# === Clean previous temp clone ===
rm -rf "$SRC_TMP_DIR"
git clone --branch "$SRC_BRANCH" --depth 1 "$SRC_REPO" "$SRC_TMP_DIR"

cd "$SRC_TMP_DIR" || exit 1

# === Match dev, stable, v*, and symlinks ===
MATCHED_DIRS=$(
  find . -maxdepth 1 \( -type d -o -type l \) \
  ! -name "." \
  -exec bash -c '
    for d; do
      base=$(basename "$d")
      [[ "$base" == "dev" || "$base" == "stable" || "$base" == v* ]] && echo "$base"
    done
  ' _ {} +
)

cd ..

# === Create minimal redirect folders ===
mkdir -p "$DEST_BASE_DIR"
for path in $MATCHED_DIRS; do
  dest_dir="${DEST_BASE_DIR}/${path}"
  mkdir -p "$dest_dir"
  cat > "${dest_dir}/index.html" <<EOF
<meta http-equiv="refresh" content="0; url=${DEST_PREFIX}/${path}/" />
EOF
  echo "✅ Created redirect for: $path"
done

# === Create root redirect to stable ===
cat > "${DEST_BASE_DIR}/index.html" <<EOF
<meta http-equiv="refresh" content="0; url=${DEST_PREFIX}/stable/" />
EOF
echo "✅ Created root redirect: /TuringBenchmarking.jl/ → /Deprecated/TuringBenchmarking/stable/"

# === Cleanup ===
rm -rf "$SRC_TMP_DIR"
echo "🎉 All redirects created in ./$DEST_BASE_DIR/"

# === Self-destruct this script ===
rm -- "$0"
```

Then make it executable and run:

```bash
chmod +x redirects.sh
./redirects.sh
```

This creates a `TuringBenchmarking.jl/` folder with minimal `index.html` files to redirect `stable/`, `dev/`, `v*`, and the root URL.

#### 3. Add any manual redirects if needed

If you know of any additional special-case redirects (e.g. `latest/`, `oldstable/`, custom aliases), you can manually create those similarly:

```bash
mkdir -p TuringBenchmarking.jl/latest
echo '<meta http-equiv="refresh" content="0; url=/Deprecated/TuringBenchmarking/stable/" />' > TuringBenchmarking.jl/latest/index.html
```

#### 4. Commit and push the changes

```bash
git add TuringBenchmarking.jl
git commit -m "Added redirects for deprecated TuringBenchmarking.jl documentation"
git push origin gh-pages
```

---

This ensures **all known URLs** like:

* `https://turinglang.org/TuringBenchmarking.jl/`
* `.../stable/`
* `.../dev/`
* `.../v0.5/`
  continue working after deprecation, and point cleanly to the new location in `/Deprecated/`.
